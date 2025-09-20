package com.example.springmodels.repos;

import com.example.springmodels.models.CartItem;
import com.example.springmodels.models.ModelUser;
import com.example.springmodels.models.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CartItemRepository extends JpaRepository<CartItem, Long> {
    
    // Найти товары в корзине пользователя
    List<CartItem> findByUser(ModelUser user);
    
    // Найти конкретный товар в корзине пользователя
    CartItem findByUserAndProduct(ModelUser user, Product product);
    
    // Подсчет товаров в корзине пользователя
    Long countByUser(ModelUser user);
    
    // Удалить все товары из корзины пользователя
    void deleteByUser(ModelUser user);
    
    // Найти товары в корзине по ID пользователя
    List<CartItem> findByUserIdUser(Long userId);
}

