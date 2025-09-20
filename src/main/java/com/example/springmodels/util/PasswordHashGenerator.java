package com.example.springmodels.util;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class PasswordHashGenerator {
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder(8);
        
        String adminPassword = "Administraror228!";
        String moderatorPassword = "Moderator!";
        
        String adminHash = encoder.encode(adminPassword);
        String moderatorHash = encoder.encode(moderatorPassword);
        
        System.out.println("Admin password hash: " + adminHash);
        System.out.println("Moderator password hash: " + moderatorHash);
        
        // Проверка хешей
        System.out.println("Admin hash verification: " + encoder.matches(adminPassword, adminHash));
        System.out.println("Moderator hash verification: " + encoder.matches(moderatorPassword, moderatorHash));
    }
}
