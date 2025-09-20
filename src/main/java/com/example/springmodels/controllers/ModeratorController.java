package com.example.springmodels.controllers;

import com.example.springmodels.models.ModelUser;
import com.example.springmodels.repos.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/moderator")
@PreAuthorize("hasAnyAuthority('MODERATOR')")
public class ModeratorController {

    @Autowired
    private UserRepository userRepository;

    @GetMapping("/dashboard")
    public String moderatorDashboard(Model model) {
        model.addAttribute("userCount", userRepository.count());
        
        // Подсчет активных пользователей без stream API
        long activeUsers = 0;
        for (ModelUser user : userRepository.findAll()) {
            if (user.isActive()) {
                activeUsers++;
            }
        }
        model.addAttribute("activeUsers", activeUsers);
        
        return "moderator/dashboard";
    }

    @GetMapping("/users")
    public String viewUsers(Model model) {
        model.addAttribute("users", userRepository.findAll());
        return "moderator/users";
    }

    @PostMapping("/users/{id}/toggle")
    public String toggleUserStatus(@PathVariable Long id) {
        ModelUser user = userRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Invalid user ID: " + id));
        user.setActive(!user.isActive());
        userRepository.save(user);
        return "redirect:/moderator/users";
    }

    @GetMapping("/reports")
    public String reports(Model model) {
        model.addAttribute("reportData", "Статистика модерации");
        return "moderator/reports";
    }
}
