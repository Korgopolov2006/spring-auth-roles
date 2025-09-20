package com.example.springmodels.repos;

import com.example.springmodels.models.Manufacturer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ManufacturerRepository extends JpaRepository<Manufacturer, Long> {
    
    // Найти активных производителей
    List<Manufacturer> findByIsActiveTrue();
    
    // Найти производителей по стране
    List<Manufacturer> findByCountryAndIsActiveTrue(String country);
    
    // Найти производителей по названию
    List<Manufacturer> findByNameContainingIgnoreCaseAndIsActiveTrue(String name);
    
    // Найти производителей с товарами
    @Query("SELECT DISTINCT m FROM Manufacturer m JOIN m.products p WHERE m.isActive = true AND p.isActive = true")
    List<Manufacturer> findManufacturersWithProducts();
    
    // Подсчет товаров производителя
    @Query("SELECT COUNT(p) FROM Product p WHERE p.manufacturer.id = :manufacturerId AND p.isActive = true")
    Long countProductsByManufacturer(Long manufacturerId);
}

