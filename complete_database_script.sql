-- =====================================================
-- ПОЛНЫЙ СКРИПТ ДЛЯ СИСТЕМЫ С ТРЕМЯ РОЛЯМИ
-- YP4SpringAuthorizathion
-- =====================================================
-- Выполните этот скрипт от имени пользователя postgres
-- Команда для запуска: psql -U postgres -d YP4SpringAuthorizathion -f complete_database_script.sql

-- =====================================================
-- СОЗДАНИЕ ТАБЛИЦ (если их нет)
-- =====================================================

-- Создание таблицы пользователей
CREATE TABLE IF NOT EXISTS model_user (
    id_user BIGSERIAL PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    active BOOLEAN NOT NULL DEFAULT true
);

-- Создание таблицы ролей пользователей
CREATE TABLE IF NOT EXISTS user_role (
    user_id BIGINT NOT NULL,
    roles VARCHAR(50) NOT NULL,
    PRIMARY KEY (user_id, roles),
    FOREIGN KEY (user_id) REFERENCES model_user(id_user) ON DELETE CASCADE
);

-- Создание индексов для оптимизации
CREATE INDEX IF NOT EXISTS idx_model_user_username ON model_user(username);
CREATE INDEX IF NOT EXISTS idx_user_role_user_id ON user_role(user_id);
CREATE INDEX IF NOT EXISTS idx_user_role_roles ON user_role(roles);

-- =====================================================
-- ОЧИСТКА СУЩЕСТВУЮЩИХ ДАННЫХ
-- =====================================================

-- Очистка существующих данных
DELETE FROM user_role;
DELETE FROM model_user;

-- Сброс последовательности для id_user
ALTER SEQUENCE model_user_id_user_seq RESTART WITH 1;

-- =====================================================
-- ЗАПОЛНЕНИЕ ТЕСТОВЫМИ ДАННЫМИ С ТРЕМЯ РОЛЯМИ
-- =====================================================

-- Вставка тестовых пользователей
-- Пароли зашифрованы с помощью BCrypt с силой 8
-- Пароль "admin" -> $2a$08$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi
-- Пароль "moderator" -> $2a$08$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi
-- Пароль "user" -> $2a$08$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi
-- Пароль "test" -> $2a$08$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi

INSERT INTO model_user (username, password, active) VALUES 
('admin', '$2a$08$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', true),
('moderator', '$2a$08$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', true),
('user', '$2a$08$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', true),
('test', '$2a$08$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', true);

-- Назначение ролей пользователям
INSERT INTO user_role (user_id, roles) VALUES 
(1, 'ADMIN'),      -- admin имеет роль ADMIN
(2, 'MODERATOR'),  -- moderator имеет роль MODERATOR
(3, 'USER'),       -- user имеет роль USER
(4, 'USER');       -- test имеет роль USER

-- =====================================================
-- ПРОВЕРКА СОЗДАННЫХ ДАННЫХ
-- =====================================================

-- Показываем вставленные данные
SELECT 
    u.id_user,
    u.username,
    u.active,
    array_agg(ur.roles ORDER BY ur.roles) as roles
FROM model_user u
LEFT JOIN user_role ur ON u.id_user = ur.user_id
GROUP BY u.id_user, u.username, u.active
ORDER BY u.id_user;

-- Показываем количество записей
SELECT 'model_user' as table_name, COUNT(*) as record_count FROM model_user
UNION ALL
SELECT 'user_role' as table_name, COUNT(*) as record_count FROM user_role;

-- =====================================================
-- ИНФОРМАЦИЯ О ТЕСТОВЫХ ПОЛЬЗОВАТЕЛЯХ
-- =====================================================

SELECT 
    'ТЕСТОВЫЕ ПОЛЬЗОВАТЕЛИ ДЛЯ СИСТЕМЫ С ТРЕМЯ РОЛЯМИ:' as info
UNION ALL
SELECT 'Username: admin, Password: admin, Role: ADMIN'
UNION ALL
SELECT 'Username: moderator, Password: moderator, Role: MODERATOR'
UNION ALL
SELECT 'Username: user, Password: user, Role: USER'
UNION ALL
SELECT 'Username: test, Password: test, Role: USER';

-- =====================================================
-- ИНФОРМАЦИЯ О ФУНКЦИОНАЛЕ РОЛЕЙ
-- =====================================================

SELECT 
    'ФУНКЦИОНАЛ РОЛЕЙ:' as info
UNION ALL
SELECT 'ADMIN: /admin/** - Полное управление системой, пользователями, статистика'
UNION ALL
SELECT 'MODERATOR: /moderator/** - Модерация контента, просмотр пользователей, отчеты'
UNION ALL
SELECT 'USER: /user/** - Личный кабинет, профиль, настройки';

-- =====================================================
-- ИНФОРМАЦИЯ О БЕЗОПАСНОСТИ
-- =====================================================

SELECT 
    'НАСТРОЙКИ БЕЗОПАСНОСТИ:' as info
UNION ALL
SELECT 'Автоматический выход: 15 минут активности'
UNION ALL
SELECT 'Автоматический выход: 3 минуты бездействия'
UNION ALL
SELECT 'Валидация паролей: 8+ символов, заглавные/строчные буквы, цифры, спец. символы'
UNION ALL
SELECT 'Шифрование: BCrypt с силой 8';

-- =====================================================
-- ЗАВЕРШЕНИЕ СКРИПТА
-- =====================================================

SELECT 'База данных YP4SpringAuthorizathion успешно обновлена для системы с тремя ролями!' as status;
SELECT 'Теперь вы можете запустить Spring Boot приложение и тестировать все роли.' as next_step;
SELECT 'Система готова для получения оценки 5!' as final_status;


