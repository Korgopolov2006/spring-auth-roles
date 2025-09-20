package com.example.springmodels.repos;

import com.example.springmodels.models.ProductReview;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProductReviewRepository extends JpaRepository<ProductReview, Long> {
    
    // Найти отзывы по товару
    List<ProductReview> findByProductId(Long productId);
    
    // Найти отзывы пользователя
    List<ProductReview> findByUser_IdUser(Long userId);
    
    // Найти одобренные отзывы
    List<ProductReview> findByIsApprovedTrue();
    
    // Найти неодобренные отзывы
    List<ProductReview> findByIsApprovedFalse();
    
    // Найти отзывы по рейтингу
    List<ProductReview> findByRating(Integer rating);
    
    // Подсчет отзывов по товару
    Long countByProductId(Long productId);
    
    // Средний рейтинг товара
    @Query("SELECT AVG(r.rating) FROM ProductReview r WHERE r.product.id = :productId AND r.isApproved = true")
    Double getAverageRatingByProductId(Long productId);
}
