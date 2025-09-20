package com.example.springmodels.repos;

import com.example.springmodels.models.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CategoryRepository extends JpaRepository<Category, Long> {
    
    // Найти активные категории
    List<Category> findByIsActiveTrue();
    
    // Найти категории по родительской категории
    List<Category> findByParentIdAndIsActiveTrue(Long parentId);
    
    // Найти корневые категории (без родителя)
    List<Category> findByParentIsNullAndIsActiveTrue();
    
    // Найти категории по названию
    List<Category> findByNameContainingIgnoreCaseAndIsActiveTrue(String name);
    
    // Найти категории с товарами
    @Query("SELECT DISTINCT c FROM Category c WHERE c.isActive = true AND EXISTS (SELECT 1 FROM Product p WHERE p.category = c AND p.isActive = true)")
    List<Category> findCategoriesWithProducts();
    
    // Подсчет товаров в категории
    @Query("SELECT COUNT(p) FROM Product p WHERE p.category.id = :categoryId AND p.isActive = true")
    Long countProductsInCategory(Long categoryId);
}
