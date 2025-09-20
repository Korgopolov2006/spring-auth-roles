package com.example.springmodels.controllers;

import com.example.springmodels.models.*;
import com.example.springmodels.repos.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Controller
public class ElectronicsStoreController {

    @Autowired
    private ProductRepository productRepository;
    
    @Autowired
    private CategoryRepository categoryRepository;
    
    @Autowired
    private ManufacturerRepository manufacturerRepository;
    
    @Autowired
    private CartItemRepository cartItemRepository;
    
    @Autowired
    private OrderRepository orderRepository;
    
    @Autowired
    private OrderItemRepository orderItemRepository;
    
    @Autowired
    private UserRepository userRepository;

    // Главная страница магазина
    @GetMapping("/store/home")
    public String home(Model model) {
        // Получаем популярные товары
        List<Product> featuredProducts = productRepository.findByIsFeaturedTrueAndIsActiveTrue();
        model.addAttribute("featuredProducts", featuredProducts);
        
        // Получаем категории
        List<Category> categories = categoryRepository.findByIsActiveTrue();
        model.addAttribute("categories", categories);
        
        return "store/home";
    }

    // Каталог товаров
    @GetMapping("/catalog")
    public String catalog(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "12") int size,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) Long manufacturerId,
            @RequestParam(required = false) String search,
            @RequestParam(defaultValue = "name") String sortBy,
            @RequestParam(defaultValue = "asc") String sortDir,
            Model model) {
        
        Pageable pageable = PageRequest.of(page, size, 
            Sort.by(sortDir.equals("desc") ? Sort.Direction.DESC : Sort.Direction.ASC, sortBy));
        
        Page<Product> products;
        
        if (categoryId != null) {
            products = productRepository.findByCategoryIdAndIsActiveTrue(categoryId, pageable);
        } else if (manufacturerId != null) {
            products = productRepository.findByManufacturerIdAndIsActiveTrue(manufacturerId, pageable);
        } else if (search != null && !search.trim().isEmpty()) {
            products = productRepository.findByNameContainingIgnoreCaseAndIsActiveTrue(search, pageable);
        } else {
            products = productRepository.findByIsActiveTrue(pageable);
        }
        
        model.addAttribute("products", products);
        model.addAttribute("categories", categoryRepository.findByIsActiveTrue());
        model.addAttribute("manufacturers", manufacturerRepository.findByIsActiveTrue());
        model.addAttribute("currentCategoryId", categoryId);
        model.addAttribute("currentManufacturerId", manufacturerId);
        model.addAttribute("currentSearch", search);
        model.addAttribute("currentSort", sortBy);
        model.addAttribute("currentSortDir", sortDir);
        
        return "store/catalog";
    }

    // Страница товара
    @GetMapping("/product/{id}")
    public String productDetails(@PathVariable Long id, Model model) {
        Optional<Product> productOpt = productRepository.findById(id);
        if (productOpt.isPresent()) {
            Product product = productOpt.get();
            model.addAttribute("product", product);
            model.addAttribute("relatedProducts", 
                productRepository.findByCategoryIdAndIsActiveTrueAndIdNot(product.getCategory().getId(), id, PageRequest.of(0, 4)));
            return "store/product-details";
        }
        return "redirect:/catalog";
    }

    // Корзина
    @GetMapping("/cart")
    public String cart(Authentication authentication, Model model) {
        if (authentication != null && authentication.isAuthenticated()) {
            String username = authentication.getName();
            ModelUser user = userRepository.findByUsername(username);
            if (user != null) {
                List<CartItem> cartItems = cartItemRepository.findByUser(user);
                model.addAttribute("cartItems", cartItems);
                
                BigDecimal total = BigDecimal.ZERO;
                for (CartItem cartItem : cartItems) {
                    BigDecimal itemTotal = cartItem.getProduct().getPrice().multiply(BigDecimal.valueOf(cartItem.getQuantity()));
                    total = total.add(itemTotal);
                }
                model.addAttribute("total", total);
            }
        }
        return "store/cart";
    }

    // Добавить в корзину
    @PostMapping("/cart/add")
    @ResponseBody
    public String addToCart(@RequestParam Long productId, @RequestParam(defaultValue = "1") int quantity, Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return "error:not_authenticated";
        }
        
        String username = authentication.getName();
        ModelUser user = userRepository.findByUsername(username);
        if (user == null) {
            return "error:user_not_found";
        }
        
        Optional<Product> productOpt = productRepository.findById(productId);
        if (!productOpt.isPresent()) {
            return "error:product_not_found";
        }
        
        Product product = productOpt.get();
        if (product.getStockQuantity() < quantity) {
            return "error:insufficient_stock";
        }
        
        CartItem existingItem = cartItemRepository.findByUserAndProduct(user, product);
        if (existingItem != null) {
            existingItem.setQuantity(existingItem.getQuantity() + quantity);
            cartItemRepository.save(existingItem);
        } else {
            CartItem cartItem = new CartItem();
            cartItem.setUser(user);
            cartItem.setProduct(product);
            cartItem.setQuantity(quantity);
            cartItemRepository.save(cartItem);
        }
        
        return "success";
    }

    // Обновить количество в корзине
    @PostMapping("/cart/update")
    @ResponseBody
    public String updateCartItem(@RequestParam Long cartItemId, @RequestParam int quantity, Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return "error:not_authenticated";
        }
        
        String username = authentication.getName();
        ModelUser user = userRepository.findByUsername(username);
        if (user == null) {
            return "error:user_not_found";
        }
        
        Optional<CartItem> cartItemOpt = cartItemRepository.findById(cartItemId);
        if (!cartItemOpt.isPresent()) {
            return "error:item_not_found";
        }
        
        CartItem cartItem = cartItemOpt.get();
        if (!cartItem.getUser().getIdUser().equals(user.getIdUser())) {
            return "error:unauthorized";
        }
        
        if (quantity <= 0) {
            cartItemRepository.delete(cartItem);
        } else {
            cartItem.setQuantity(quantity);
            cartItemRepository.save(cartItem);
        }
        
        return "success";
    }

    // Удалить из корзины
    @PostMapping("/cart/remove")
    @ResponseBody
    public String removeFromCart(@RequestParam Long cartItemId, Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return "error:not_authenticated";
        }
        
        String username = authentication.getName();
        ModelUser user = userRepository.findByUsername(username);
        if (user == null) {
            return "error:user_not_found";
        }
        
        Optional<CartItem> cartItemOpt = cartItemRepository.findById(cartItemId);
        if (!cartItemOpt.isPresent()) {
            return "error:item_not_found";
        }
        
        CartItem cartItem = cartItemOpt.get();
        if (!cartItem.getUser().getIdUser().equals(user.getIdUser())) {
            return "error:unauthorized";
        }
        
        cartItemRepository.delete(cartItem);
        return "success";
    }

    // Оформление заказа
    @GetMapping("/checkout")
    public String checkout(Authentication authentication, Model model) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return "redirect:/login";
        }
        
        String username = authentication.getName();
        ModelUser user = userRepository.findByUsername(username);
        if (user != null) {
            List<CartItem> cartItems = cartItemRepository.findByUser(user);
            if (cartItems.isEmpty()) {
                return "redirect:/cart";
            }
            
            model.addAttribute("cartItems", cartItems);
            BigDecimal total = cartItems.stream()
                .map(item -> item.getProduct().getPrice().multiply(BigDecimal.valueOf(item.getQuantity())))
                .reduce(BigDecimal.ZERO, BigDecimal::add);
            model.addAttribute("total", total);
        }
        
        return "store/checkout";
    }

    // Создание заказа
    @PostMapping("/order/create")
    public String createOrder(Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return "redirect:/login";
        }
        
        String username = authentication.getName();
        ModelUser user = userRepository.findByUsername(username);
        if (user == null) {
            return "redirect:/login";
        }
        
        List<CartItem> cartItems = cartItemRepository.findByUser(user);
        if (cartItems.isEmpty()) {
            return "redirect:/cart";
        }
        
        // Создаем заказ
        Order order = new Order();
        order.setUser(user);
        order.setCreatedAt(LocalDateTime.now());
        order.setStatus("PENDING");
        order.setOrderNumber("ORD-" + System.currentTimeMillis());
        
        BigDecimal total = BigDecimal.ZERO;
        for (CartItem cartItem : cartItems) {
            BigDecimal itemTotal = cartItem.getProduct().getPrice().multiply(BigDecimal.valueOf(cartItem.getQuantity()));
            total = total.add(itemTotal);
        }
        order.setTotalAmount(total);
        
        order = orderRepository.save(order);
        
        // Создаем элементы заказа
        for (CartItem cartItem : cartItems) {
            OrderItem orderItem = new OrderItem();
            orderItem.setOrder(order);
            orderItem.setProduct(cartItem.getProduct());
            orderItem.setProductName(cartItem.getProduct().getName());
            orderItem.setProductSku(cartItem.getProduct().getSku());
            orderItem.setQuantity(cartItem.getQuantity());
            orderItem.setUnitPrice(cartItem.getProduct().getPrice());
            orderItem.setTotalPrice(cartItem.getProduct().getPrice().multiply(BigDecimal.valueOf(cartItem.getQuantity())));
            orderItemRepository.save(orderItem);
        }
        
        // Очищаем корзину
        cartItemRepository.deleteAll(cartItems);
        
        return "redirect:/orders/" + order.getId();
    }

    // История заказов
    @GetMapping("/orders")
    public String orders(Authentication authentication, Model model) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return "redirect:/login";
        }
        
        String username = authentication.getName();
        ModelUser user = userRepository.findByUsername(username);
        if (user != null) {
            List<Order> orders = orderRepository.findByUserOrderByCreatedAtDesc(user);
            model.addAttribute("orders", orders);
        }
        
        return "store/orders";
    }

    // Детали заказа
    @GetMapping("/orders/{id}")
    public String orderDetails(@PathVariable Long id, Authentication authentication, Model model) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return "redirect:/login";
        }
        
        String username = authentication.getName();
        ModelUser user = userRepository.findByUsername(username);
        if (user == null) {
            return "redirect:/login";
        }
        
        Optional<Order> orderOpt = orderRepository.findById(id);
        if (!orderOpt.isPresent()) {
            return "redirect:/orders";
        }
        
        Order order = orderOpt.get();
        if (!order.getUser().getIdUser().equals(user.getIdUser())) {
            return "redirect:/orders";
        }
        
        model.addAttribute("order", order);
        return "store/order-details";
    }
}
