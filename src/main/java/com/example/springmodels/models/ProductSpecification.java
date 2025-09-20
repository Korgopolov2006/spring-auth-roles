package com.example.springmodels.models;

import javax.persistence.*;

@Entity
@Table(name = "product_specifications")
public class ProductSpecification {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;
    
    @Column(name = "name", length = 100)
    private String name;
    
    @Column(name = "value", length = 255)
    private String value;
    
    // Конструкторы
    public ProductSpecification() {}
    
    public ProductSpecification(Product product, String name, String value) {
        this.product = product;
        this.name = name;
        this.value = value;
    }
    
    // Геттеры и сеттеры
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public Product getProduct() {
        return product;
    }
    
    public void setProduct(Product product) {
        this.product = product;
    }
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public String getValue() {
        return value;
    }
    
    public void setValue(String value) {
        this.value = value;
    }
}