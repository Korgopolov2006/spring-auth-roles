package com.example.springmodels.controllers;

import com.example.springmodels.models.ModelUser;
import com.example.springmodels.models.RoleEnum;
import com.example.springmodels.models.Product;
import com.example.springmodels.repos.UserRepository;
import com.example.springmodels.repos.ProductRepository;
import com.example.springmodels.repos.OrderRepository;
import com.example.springmodels.repos.CategoryRepository;
import com.example.springmodels.repos.ManufacturerRepository;
import com.example.springmodels.repos.CartItemRepository;
import com.example.springmodels.repos.ProductReviewRepository;
import com.example.springmodels.repos.CouponRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/admin")
@PreAuthorize("hasAnyAuthority('ADMIN')")
public class UserController {

    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private ProductRepository productRepository;
    
    @Autowired
    private OrderRepository orderRepository;
    
    @Autowired
    private CategoryRepository categoryRepository;
    
    @Autowired
    private ManufacturerRepository manufacturerRepository;
    
    @Autowired
    private CartItemRepository cartItemRepository;
    
    
    @Autowired
    private ProductReviewRepository productReviewRepository;
    
    @Autowired
    private CouponRepository couponRepository;

    @GetMapping("/dashboard")
    public String adminDashboard(Model model) {
        model.addAttribute("userCount", userRepository.count());
        
        // Подсчет активных пользователей без stream API
        long activeUsers = 0;
        for (ModelUser user : userRepository.findAll()) {
            if (user.isActive()) {
                activeUsers++;
            }
        }
        model.addAttribute("activeUsers", activeUsers);
        
        // Статистика товаров
        long totalProducts = productRepository.count();
        long activeProducts = 0;
        for (Product product : productRepository.findAll()) {
            if (product.getIsActive()) {
                activeProducts++;
            }
        }
        model.addAttribute("totalProducts", totalProducts);
        model.addAttribute("activeProducts", activeProducts);
        
        // Статистика заказов
        long totalOrders = orderRepository.count();
        model.addAttribute("totalOrders", totalOrders);
        
        return "admin/dashboard";
    }

    @GetMapping("/users")
    public String userView(Model model) {
        model.addAttribute("user_list", userRepository.findAll());
        return "admin/users";
    }

    @GetMapping("/{id}")
    public String detailView(@PathVariable Long id, Model model) {
        ModelUser user = userRepository.findById(id).orElseThrow(() -> new IllegalArgumentException("Invalid user ID: " + id));
        model.addAttribute("user_object", user);
        return "info";
    }

    @GetMapping("/{id}/update")
    public String updView(@PathVariable Long id, Model model) {
        ModelUser user = userRepository.findById(id).orElseThrow(() -> new IllegalArgumentException("Invalid user ID: " + id));
        model.addAttribute("user_object", user);
        model.addAttribute("roles", RoleEnum.values());
        return "update";
    }

    @PostMapping("/{id}/update")
    public String updateUser(@PathVariable Long id,
                             @RequestParam String username,
                             @RequestParam(name = "roles[]", required = false) String[] roles) {
        ModelUser user = userRepository.findById(id).orElseThrow(() -> new IllegalArgumentException("Invalid user ID: " + id));
        user.setUsername(username);

        user.getRoles().clear();
        if (roles != null) {
            for (String role : roles) {
                user.getRoles().add(RoleEnum.valueOf(role));
            }
        }

        userRepository.save(user);
        return "redirect:/admin/" + id;
    }
    
    @GetMapping("/products")
    public String products(Model model) {
        model.addAttribute("products", productRepository.findAll());
        return "admin/products";
    }
    
    @GetMapping("/orders")
    public String orders(Model model) {
        model.addAttribute("orders", orderRepository.findAll());
        return "admin/orders";
    }
    
    @GetMapping("/categories")
    public String categories(Model model) {
        model.addAttribute("categories", categoryRepository.findAll());
        return "admin/categories";
    }
    
    @GetMapping("/manufacturers")
    public String manufacturers(Model model) {
        model.addAttribute("manufacturers", manufacturerRepository.findAll());
        return "admin/manufacturers";
    }
    
    @GetMapping("/cart-items")
    public String cartItems(Model model) {
        model.addAttribute("cartItems", cartItemRepository.findAll());
        return "admin/cart-items";
    }
    
    @GetMapping("/order-items")
    public String orderItems(Model model) {
        // TODO: Implement order items management
        return "admin/order-items";
    }
    
    @GetMapping("/reviews")
    public String reviews(Model model) {
        model.addAttribute("reviews", productReviewRepository.findAll());
        return "admin/reviews";
    }
    
    @GetMapping("/coupons")
    public String coupons(Model model) {
        model.addAttribute("coupons", couponRepository.findAll());
        return "admin/coupons";
    }
}
