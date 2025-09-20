package com.example.springmodels.repos;

import com.example.springmodels.models.Product;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
    
    // Найти товары по категории
    Page<Product> findByCategoryIdAndIsActiveTrue(Long categoryId, Pageable pageable);
    
    // Найти товары по производителю
    Page<Product> findByManufacturerIdAndIsActiveTrue(Long manufacturerId, Pageable pageable);
    
    // Найти товары по названию (поиск)
    Page<Product> findByNameContainingIgnoreCaseAndIsActiveTrue(String name, Pageable pageable);
    
    // Найти активные товары
    Page<Product> findByIsActiveTrue(Pageable pageable);
    
    // Найти рекомендуемые товары
    List<Product> findByIsFeaturedTrueAndIsActiveTrue();
    
    // Найти товары по категории, исключая определенный товар
    List<Product> findByCategoryIdAndIsActiveTrueAndIdNot(Long categoryId, Long productId, Pageable pageable);
    
    // Найти товары по цене
    Page<Product> findByPriceBetweenAndIsActiveTrue(Double minPrice, Double maxPrice, Pageable pageable);
    
    // Найти товары на складе
    List<Product> findByStockQuantityGreaterThanAndIsActiveTrue(Integer minStock, Pageable pageable);
    
    // Найти товары с низким остатком
    @Query("SELECT p FROM Product p WHERE p.stockQuantity <= p.minStockLevel AND p.isActive = true")
    List<Product> findLowStockProducts();
    
    // Поиск товаров по нескольким критериям
    @Query("SELECT p FROM Product p WHERE " +
           "(:categoryId IS NULL OR p.category.id = :categoryId) AND " +
           "(:manufacturerId IS NULL OR p.manufacturer.id = :manufacturerId) AND " +
           "(:minPrice IS NULL OR p.price >= :minPrice) AND " +
           "(:maxPrice IS NULL OR p.price <= :maxPrice) AND " +
           "(:search IS NULL OR LOWER(p.name) LIKE LOWER(CONCAT('%', :search, '%'))) AND " +
           "p.isActive = true")
    Page<Product> findProductsWithFilters(
        @Param("categoryId") Long categoryId,
        @Param("manufacturerId") Long manufacturerId,
        @Param("minPrice") Double minPrice,
        @Param("maxPrice") Double maxPrice,
        @Param("search") String search,
        Pageable pageable
    );
}

