-- =====================================================
-- ПОЛНЫЙ СКРИПТ ДЛЯ СОЗДАНИЯ БАЗЫ ДАННЫХ SPRING SECURITY
-- =====================================================
-- Выполните этот скрипт от имени суперпользователя PostgreSQL
-- Команда для запуска: psql -U postgres -f full_database_setup.sql

-- Создание базы данных
DROP DATABASE IF EXISTS spring_security_db;
CREATE DATABASE spring_security_db;

-- Создание пользователя (если не существует)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'postgres') THEN
        CREATE USER postgres WITH PASSWORD 'postgres';
    ELSE
        -- Обновляем пароль для существующего пользователя
        ALTER USER postgres PASSWORD 'postgres';
    END IF;
END
$$;

-- Предоставление прав пользователю
GRANT ALL PRIVILEGES ON DATABASE spring_security_db TO postgres;

-- Подключение к созданной базе данных
\c spring_security_db;

-- Предоставление прав на схему public
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO postgres;

-- Установка прав по умолчанию для будущих таблиц
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;

-- =====================================================
-- СОЗДАНИЕ ТАБЛИЦ
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
-- ЗАПОЛНЕНИЕ ТЕСТОВЫМИ ДАННЫМИ
-- =====================================================

-- Очистка существующих данных (если есть)
DELETE FROM user_role;
DELETE FROM model_user;

-- Сброс последовательности для id_user
ALTER SEQUENCE model_user_id_user_seq RESTART WITH 1;

-- Вставка тестовых пользователей
-- Пароли зашифрованы с помощью BCrypt с силой 8
-- Пароль "admin" -> $2a$08$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi
-- Пароль "user" -> $2a$08$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi
-- Пароль "test" -> $2a$08$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi
-- Пароль "manager" -> $2a$08$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi

INSERT INTO model_user (username, password, active) VALUES 
('admin', '$2a$08$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', true),
('user', '$2a$08$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', true),
('test', '$2a$08$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', true),
('manager', '$2a$08$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', true);

-- Вставка ролей для пользователей
INSERT INTO user_role (user_id, roles) VALUES 
(1, 'ADMIN'),    -- admin имеет роль ADMIN
(1, 'USER'),     -- admin также имеет роль USER
(2, 'USER'),     -- user имеет роль USER
(3, 'USER'),     -- test имеет роль USER
(4, 'USER');     -- manager имеет роль USER

-- =====================================================
-- ПРОВЕРКА СОЗДАННЫХ ДАННЫХ
-- =====================================================

-- Показываем структуру таблиц
\d model_user
\d user_role

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
    'ТЕСТОВЫЕ ПОЛЬЗОВАТЕЛИ:' as info
UNION ALL
SELECT 'Username: admin, Password: admin, Roles: ADMIN, USER'
UNION ALL
SELECT 'Username: user, Password: user, Roles: USER'
UNION ALL
SELECT 'Username: test, Password: test, Roles: USER'
UNION ALL
SELECT 'Username: manager, Password: manager, Roles: USER';

-- =====================================================
-- ЗАВЕРШЕНИЕ СКРИПТА
-- =====================================================

SELECT 'База данных spring_security_db успешно создана и заполнена тестовыми данными!' as status;
SELECT 'Теперь вы можете запустить Spring Boot приложение.' as next_step;
