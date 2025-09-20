package com.example.springmodels.repos;

import com.example.springmodels.models.ModelUser;
import com.example.springmodels.models.Order;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {
    
    // Найти заказы пользователя, отсортированные по дате
    List<Order> findByUserOrderByCreatedAtDesc(ModelUser user);
    
    // Найти заказы по статусу
    List<Order> findByStatus(String status);
    
    // Найти заказы пользователя по статусу
    List<Order> findByUserAndStatus(ModelUser user, String status);
    
    // Найти заказы за период
    List<Order> findByCreatedAtBetween(LocalDateTime startDate, LocalDateTime endDate);
    
    // Найти заказы пользователя за период
    List<Order> findByUserAndCreatedAtBetween(ModelUser user, LocalDateTime startDate, LocalDateTime endDate);
    
    // Подсчет заказов пользователя
    Long countByUser(ModelUser user);
    
    // Подсчет заказов по статусу
    Long countByStatus(String status);
    
    // Найти заказы с общей суммой больше указанной
    @Query("SELECT o FROM Order o WHERE o.totalAmount > :minAmount")
    List<Order> findOrdersWithMinAmount(@Param("minAmount") Double minAmount);
    
    // Статистика заказов пользователя
    @Query("SELECT COUNT(o), SUM(o.totalAmount) FROM Order o WHERE o.user = :user")
    Object[] getOrderStatistics(@Param("user") ModelUser user);
}
