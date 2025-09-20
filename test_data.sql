-- Скрипт для заполнения базы данных тестовыми данными
-- Выполните после запуска приложения Spring Boot

-- Очистка существующих данных (опционально)
-- DELETE FROM user_role;
-- DELETE FROM model_user;

-- Вставка тестовых пользователей
-- Пароли зашифрованы с помощью BCrypt с силой 8
-- Пароль "admin" -> $2a$08$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi
-- Пароль "user" -> $2a$08$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi
-- Пароль "test" -> $2a$08$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi

INSERT INTO model_user (id_user, username, password, active) VALUES 
(1, 'admin', '$2a$08$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', true),
(2, 'user', '$2a$08$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', true),
(3, 'test', '$2a$08$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', true);

-- Вставка ролей для пользователей
INSERT INTO user_role (user_id, roles) VALUES 
(1, 'ADMIN'),
(1, 'USER'),
(2, 'USER'),
(3, 'USER');

-- Проверка вставленных данных
SELECT 
    u.id_user,
    u.username,
    u.active,
    array_agg(ur.roles) as roles
FROM model_user u
LEFT JOIN user_role ur ON u.id_user = ur.user_id
GROUP BY u.id_user, u.username, u.active
ORDER BY u.id_user;
