package com.example.springmodels.repos;

import com.example.springmodels.models.Order;
import com.example.springmodels.models.OrderItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface OrderItemRepository extends JpaRepository<OrderItem, Long> {
    
    // Найти элементы заказа по заказу
    List<OrderItem> findByOrder(Order order);
    
    // Найти элементы заказа по ID заказа
    List<OrderItem> findByOrderId(Long orderId);
    
    // Подсчет элементов заказа
    Long countByOrder(Order order);
}

