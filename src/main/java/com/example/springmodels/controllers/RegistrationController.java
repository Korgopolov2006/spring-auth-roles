package com.example.springmodels.controllers;

import com.example.springmodels.models.ModelUser;
import com.example.springmodels.models.RoleEnum;
import com.example.springmodels.repos.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;

import java.util.Collections;


@Controller
public class RegistrationController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @GetMapping("/registration")
    public String regView() {
        return "regis";
    }

    @PostMapping("/registration")
    public String reg(ModelUser user, Model model) {
        // Проверка существования пользователя
        if (userRepository.existsByUsername(user.getUsername())) {
            model.addAttribute("message", "Пользователь с таким логином уже существует");
            return "regis";
        }
        
        // Валидация пароля
        String password = user.getPassword();
        if (password == null || password.length() < 8) {
            model.addAttribute("message", "Пароль должен содержать минимум 8 символов");
            return "regis";
        }
        
        if (!password.matches(".*[A-Z].*")) {
            model.addAttribute("message", "Пароль должен содержать минимум одну заглавную букву");
            return "regis";
        }
        
        if (!password.matches(".*[a-z].*")) {
            model.addAttribute("message", "Пароль должен содержать минимум одну строчную букву");
            return "regis";
        }
        
        if (!password.matches(".*[0-9].*")) {
            model.addAttribute("message", "Пароль должен содержать минимум одну цифру");
            return "regis";
        }
        
        if (!password.matches(".*[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>\\/?].*")) {
            model.addAttribute("message", "Пароль должен содержать минимум один специальный символ");
            return "regis";
        }
        
        // Валидация имени пользователя
        if (user.getUsername() == null || user.getUsername().length() < 3) {
            model.addAttribute("message", "Имя пользователя должно содержать минимум 3 символа");
            return "regis";
        }
        
        if (!user.getUsername().matches("^[a-zA-Z0-9_]+$")) {
            model.addAttribute("message", "Имя пользователя может содержать только буквы, цифры и символ подчеркивания");
            return "regis";
        }
        
        // Создание пользователя
        user.setActive(true);
        user.setRoles(Collections.singleton(RoleEnum.USER));
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        userRepository.save(user);
        
        model.addAttribute("successMessage", "Регистрация успешно завершена! Теперь вы можете войти в систему.");
        return "redirect:/login";
    }
}
