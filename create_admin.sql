-- =====================================================
-- СОЗДАНИЕ АДМИНИСТРАТОРА
-- =====================================================

-- Подключение к базе данных
\c YP4SpringAuthorizathion;

-- Создание таблиц (если не существуют)
CREATE TABLE IF NOT EXISTS model_user (
    id_user BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    active BOOLEAN DEFAULT true
);

CREATE TABLE IF NOT EXISTS user_role (
    user_id BIGINT NOT NULL,
    roles VARCHAR(20) NOT NULL,
    PRIMARY KEY (user_id, roles),
    FOREIGN KEY (user_id) REFERENCES model_user(id_user) ON DELETE CASCADE
);

-- Удаление существующего администратора (если есть)
DELETE FROM user_role WHERE user_id IN (SELECT id_user FROM model_user WHERE username = 'admin');
DELETE FROM model_user WHERE username = 'admin';

-- Добавление администратора
-- Пароль: "admin" (закодирован с BCrypt)
INSERT INTO model_user (username, password, active) VALUES 
('admin', '$2a$08$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', true);

-- Назначение роли ADMIN
INSERT INTO user_role (user_id, roles) 
SELECT id_user, 'ADMIN' FROM model_user WHERE username = 'admin';

-- Проверка результата
SELECT 
    u.username,
    u.active,
    STRING_AGG(ur.roles, ', ') as roles
FROM model_user u
LEFT JOIN user_role ur ON u.id_user = ur.user_id
WHERE u.username = 'admin'
GROUP BY u.id_user, u.username, u.active;

SELECT 'Admin user created successfully!' as status;
SELECT 'Username: admin, Password: admin' as credentials;
