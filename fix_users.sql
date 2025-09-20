-- Исправление пользователей для правильной авторизации
-- Подключение к базе данных
\c YP4SpringAuthorizathion;

-- Очистка существующих данных
DELETE FROM user_role;
DELETE FROM model_user;

-- Сброс последовательности
ALTER SEQUENCE model_user_id_user_seq RESTART WITH 1;

-- Добавление пользователей с правильными BCrypt хешами
INSERT INTO model_user (username, password, active) VALUES 
('admin', '$2a$08$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', true),
('moderator', '$2a$08$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', true),
('user', '$2a$08$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', true);

-- Назначение ролей
INSERT INTO user_role (user_id, roles) VALUES 
(1, 'ADMIN'),      -- admin имеет роль ADMIN
(2, 'MODERATOR'),  -- moderator имеет роль MODERATOR
(3, 'USER');       -- user имеет роль USER

-- Проверка результата
SELECT 
    u.username,
    u.active,
    STRING_AGG(ur.roles, ', ') as roles
FROM model_user u
LEFT JOIN user_role ur ON u.id_user = ur.user_id
GROUP BY u.id_user, u.username, u.active
ORDER BY u.id_user;

SELECT 'Пользователи исправлены! Теперь можно тестировать авторизацию.' as status;
SELECT 'admin / admin - Администратор' as admin_info;
SELECT 'moderator / moderator - Модератор' as moderator_info;
SELECT 'user / user - Пользователь' as user_info;
