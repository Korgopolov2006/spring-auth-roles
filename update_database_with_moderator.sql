-- Обновление базы данных для добавления роли MODERATOR
-- Запустите этот скрипт в вашей базе данных YP4SpringAuthorizathion

-- Очистка существующих данных
DELETE FROM user_role;
DELETE FROM model_user;

-- Сброс последовательности для id_user
ALTER SEQUENCE model_user_id_user_seq RESTART WITH 1;

-- Вставка тестовых пользователей с тремя ролями
-- Пароли зашифрованы с помощью BCrypt с силой 8
-- Пароль "admin" -> $2a$08$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi
-- Пароль "moderator" -> $2a$08$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi
-- Пароль "user" -> $2a$08$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi

-- Создание пользователей
INSERT INTO model_user (username, password, active) VALUES 
('admin', '$2a$08$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', true),
('moderator', '$2a$08$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', true),
('user', '$2a$08$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', true);

-- Назначение ролей пользователям
INSERT INTO user_role (user_id, roles) VALUES 
(1, 'ADMIN'),      -- admin имеет роль ADMIN
(2, 'MODERATOR'),  -- moderator имеет роль MODERATOR
(3, 'USER');       -- user имеет роль USER

-- Проверка данных
SELECT 
    u.id_user,
    u.username,
    u.active,
    STRING_AGG(ur.roles, ', ') as roles
FROM model_user u
LEFT JOIN user_role ur ON u.id_user = ur.user_id
GROUP BY u.id_user, u.username, u.active
ORDER BY u.id_user;

-- Сообщение об успешном выполнении
SELECT 'База данных успешно обновлена! Добавлена роль MODERATOR и созданы тестовые пользователи.' as status;


