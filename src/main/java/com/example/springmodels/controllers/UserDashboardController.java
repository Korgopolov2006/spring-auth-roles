package com.example.springmodels.controllers;

import com.example.springmodels.models.ModelUser;
import com.example.springmodels.repos.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/user")
@PreAuthorize("hasAuthority('USER')")
public class UserDashboardController {

    @Autowired
    private UserRepository userRepository;

    @GetMapping("/dashboard")
    public String userDashboard(Authentication authentication, Model model) {
        // Перенаправляем пользователей в каталог магазина
        return "redirect:/catalog";
    }

    @GetMapping("/profile")
    public String userProfile(Authentication authentication, Model model) {
        String username = authentication.getName();
        ModelUser user = userRepository.findByUsername(username);
        if (user == null) {
            throw new IllegalArgumentException("User not found");
        }
        
        model.addAttribute("user", user);
        return "user/profile";
    }

    @GetMapping("/settings")
    public String userSettings(Authentication authentication, Model model) {
        String username = authentication.getName();
        ModelUser user = userRepository.findByUsername(username);
        if (user == null) {
            throw new IllegalArgumentException("User not found");
        }
        
        model.addAttribute("user", user);
        return "user/settings";
    }
}
