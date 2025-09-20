package com.example.springmodels.repos;

import com.example.springmodels.models.Coupon;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface CouponRepository extends JpaRepository<Coupon, Long> {
    
    // Найти купон по коду
    Optional<Coupon> findByCode(String code);
    
    // Найти активные купоны
    List<Coupon> findByIsActiveTrue();
    
    // Найти неактивные купоны
    List<Coupon> findByIsActiveFalse();
    
    // Найти купоны по типу скидки
    List<Coupon> findByDiscountPercentageIsNotNull();
    
    // Найти купоны с истекающим сроком
    @Query("SELECT c FROM Coupon c WHERE c.expirationDate <= :date AND c.isActive = true")
    List<Coupon> findExpiringCoupons(LocalDateTime date);
    
    // Проверить валидность купона
    @Query("SELECT c FROM Coupon c WHERE c.code = :code AND c.isActive = true AND (c.expirationDate IS NULL OR c.expirationDate > :now)")
    Optional<Coupon> findValidCoupon(String code, LocalDateTime now);
}
