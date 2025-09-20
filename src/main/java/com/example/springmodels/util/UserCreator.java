package com.example.springmodels.util;

import com.example.springmodels.models.ModelUser;
import com.example.springmodels.models.RoleEnum;
import com.example.springmodels.repos.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.Set;

@Component
public class UserCreator implements CommandLineRunner {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private BCryptPasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        // Создание администратора
        if (userRepository.findByUsername("Administraror228") == null) {
            ModelUser admin = new ModelUser();
            admin.setUsername("Administraror228");
            admin.setPassword(passwordEncoder.encode("Administraror228!"));
            admin.setActive(true);
            admin.setRoles(Set.of(RoleEnum.ADMIN));
            userRepository.save(admin);
            System.out.println("Администратор создан: Administraror228 / Administraror228!");
        }

        // Создание модератора
        if (userRepository.findByUsername("Moderator") == null) {
            ModelUser moderator = new ModelUser();
            moderator.setUsername("Moderator");
            moderator.setPassword(passwordEncoder.encode("Moderator!"));
            moderator.setActive(true);
            moderator.setRoles(Set.of(RoleEnum.MODERATOR));
            userRepository.save(moderator);
            System.out.println("Модератор создан: Moderator / Moderator!");
        }
    }
}
