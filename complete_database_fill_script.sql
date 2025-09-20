-- =====================================================
-- ПОЛНЫЙ СКРИПТ ЗАПОЛНЕНИЯ БАЗЫ ДАННЫХ
-- База данных: YP4SpringAuthorizathion
-- Проект: Spring Security с тремя ролями (USER, ADMIN, MODERATOR)
-- =====================================================

-- Подключение к базе данных
\c YP4SpringAuthorizathion;

-- Создание таблиц (если они не существуют)
-- Таблица пользователей
CREATE TABLE IF NOT EXISTS model_user (
    id_user BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    active BOOLEAN DEFAULT true
);

-- Таблица ролей пользователей
CREATE TABLE IF NOT EXISTS user_role (
    user_id BIGINT NOT NULL,
    roles VARCHAR(20) NOT NULL,
    PRIMARY KEY (user_id, roles),
    FOREIGN KEY (user_id) REFERENCES model_user(id_user) ON DELETE CASCADE
);

-- Создание индексов для оптимизации
CREATE INDEX IF NOT EXISTS idx_model_user_username ON model_user(username);
CREATE INDEX IF NOT EXISTS idx_model_user_active ON model_user(active);
CREATE INDEX IF NOT EXISTS idx_user_role_user_id ON user_role(user_id);
CREATE INDEX IF NOT EXISTS idx_user_role_roles ON user_role(roles);

-- Очистка существующих данных (опционально)
-- Раскомментируйте следующие строки, если хотите очистить существующие данные
-- DELETE FROM user_role;
-- DELETE FROM model_user;

-- =====================================================
-- ЗАПОЛНЕНИЕ ТЕСТОВЫМИ ДАННЫМИ
-- =====================================================

-- Вставка пользователей с BCrypt-закодированными паролями
-- Пароль для всех пользователей: "password123" (закодирован с BCrypt)

-- 1. Администратор
INSERT INTO model_user (username, password, active) 
VALUES ('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', true)
ON CONFLICT (username) DO UPDATE SET 
    password = EXCLUDED.password,
    active = EXCLUDED.active;

-- 2. Модератор
INSERT INTO model_user (username, password, active) 
VALUES ('moderator', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', true)
ON CONFLICT (username) DO UPDATE SET 
    password = EXCLUDED.password,
    active = EXCLUDED.active;

-- 3. Обычный пользователь
INSERT INTO model_user (username, password, active) 
VALUES ('user', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', true)
ON CONFLICT (username) DO UPDATE SET 
    password = EXCLUDED.password,
    active = EXCLUDED.active;

-- 4. Тестовый пользователь
INSERT INTO model_user (username, password, active) 
VALUES ('test', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', true)
ON CONFLICT (username) DO UPDATE SET 
    password = EXCLUDED.password,
    active = EXCLUDED.active;

-- 5. Дополнительный пользователь для демонстрации
INSERT INTO model_user (username, password, active) 
VALUES ('demo', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', true)
ON CONFLICT (username) DO UPDATE SET 
    password = EXCLUDED.password,
    active = EXCLUDED.active;

-- =====================================================
-- НАЗНАЧЕНИЕ РОЛЕЙ ПОЛЬЗОВАТЕЛЯМ
-- =====================================================

-- Получение ID пользователей
-- Администратор получает роль ADMIN
INSERT INTO user_role (user_id, roles) 
SELECT id_user, 'ADMIN' 
FROM model_user 
WHERE username = 'admin'
ON CONFLICT (user_id, roles) DO NOTHING;

-- Модератор получает роль MODERATOR
INSERT INTO user_role (user_id, roles) 
SELECT id_user, 'MODERATOR' 
FROM model_user 
WHERE username = 'moderator'
ON CONFLICT (user_id, roles) DO NOTHING;

-- Обычный пользователь получает роль USER
INSERT INTO user_role (user_id, roles) 
SELECT id_user, 'USER' 
FROM model_user 
WHERE username = 'user'
ON CONFLICT (user_id, roles) DO NOTHING;

-- Тестовый пользователь получает роль USER
INSERT INTO user_role (user_id, roles) 
SELECT id_user, 'USER' 
FROM model_user 
WHERE username = 'test'
ON CONFLICT (user_id, roles) DO NOTHING;

-- Демо пользователь получает роль USER
INSERT INTO user_role (user_id, roles) 
SELECT id_user, 'USER' 
FROM model_user 
WHERE username = 'demo'
ON CONFLICT (user_id, roles) DO NOTHING;

-- =====================================================
-- ПРОВЕРКА РЕЗУЛЬТАТОВ
-- =====================================================

-- Показать всех пользователей с их ролями
SELECT 
    u.id_user,
    u.username,
    u.active,
    STRING_AGG(ur.roles, ', ') as roles
FROM model_user u
LEFT JOIN user_role ur ON u.id_user = ur.user_id
GROUP BY u.id_user, u.username, u.active
ORDER BY u.id_user;

-- Показать статистику по ролям
SELECT 
    roles,
    COUNT(*) as user_count
FROM user_role
GROUP BY roles
ORDER BY roles;

-- Показать активных пользователей
SELECT 
    COUNT(*) as total_users,
    COUNT(CASE WHEN active = true THEN 1 END) as active_users
FROM model_user;

-- =====================================================
-- ИНФОРМАЦИЯ О СИСТЕМЕ
-- =====================================================

-- Информация о настройках сессии
SELECT 
    'Session Timeout: 15 minutes' as setting,
    'Auto-logout after 15 minutes of total session time' as description
UNION ALL
SELECT 
    'Password Validation: Enabled' as setting,
    'Min 8 chars, uppercase, lowercase, digit, special char' as description
UNION ALL
SELECT 
    'Roles: USER, ADMIN, MODERATOR' as setting,
    'Three distinct user roles with different access levels' as description;

-- =====================================================
-- КОМАНДЫ ДЛЯ ПРОВЕРКИ
-- =====================================================

-- Проверить подключение к базе данных
SELECT current_database(), current_user, version();

-- Проверить существование таблиц
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('model_user', 'user_role');

-- Проверить индексы
SELECT 
    indexname,
    tablename,
    indexdef
FROM pg_indexes 
WHERE tablename IN ('model_user', 'user_role')
ORDER BY tablename, indexname;

-- =====================================================
-- ЗАВЕРШЕНИЕ
-- =====================================================

-- Сообщение об успешном завершении
SELECT 
    'DATABASE FILLED SUCCESSFULLY!' as status,
    'All users and roles have been created' as message,
    'You can now run the Spring Boot application' as next_step;

-- Показать время выполнения
SELECT 
    'Script completed at: ' || NOW() as completion_time;

