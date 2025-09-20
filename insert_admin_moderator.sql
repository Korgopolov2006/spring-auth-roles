-- =====================================================
-- ДОБАВЛЕНИЕ АДМИНИСТРАТОРА И МОДЕРАТОРА
-- =====================================================
-- Скрипт для добавления пользователей с ролями ADMIN и MODERATOR

-- Очистка существующих данных
DELETE FROM user_role;
DELETE FROM model_user;

-- Сброс последовательности
ALTER SEQUENCE model_user_id_user_seq RESTART WITH 1;

-- Добавление пользователей
INSERT INTO model_user (username, password, active) VALUES 
('admin', '$2a$08$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', true),
('moderator', '$2a$08$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', true),
('user', '$2a$08$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', true);

-- Назначение ролей
INSERT INTO user_role (user_id, roles) VALUES 
(1, 'ADMIN'),      -- admin имеет роль ADMIN
(2, 'MODERATOR'),  -- moderator имеет роль MODERATOR
(3, 'USER');       -- user имеет роль USER

-- Проверка добавленных пользователей
SELECT 
    u.id_user,
    u.username,
    u.active,
    array_agg(ur.roles ORDER BY ur.roles) as roles
FROM model_user u
LEFT JOIN user_role ur ON u.id_user = ur.user_id
GROUP BY u.id_user, u.username, u.active
ORDER BY u.id_user;

-- Информация о пользователях
SELECT 
    'ТЕСТОВЫЕ ПОЛЬЗОВАТЕЛИ:' as info
UNION ALL
SELECT 'Username: admin, Password: admin, Role: ADMIN'
UNION ALL
SELECT 'Username: moderator, Password: moderator, Role: MODERATOR'
UNION ALL
SELECT 'Username: user, Password: user, Role: USER';

SELECT 'Пользователи с ролями успешно добавлены!' as status;


