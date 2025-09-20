-- =====================================================
-- СОЗДАНИЕ ПОЛЬЗОВАТЕЛЕЙ АДМИНИСТРАТОРА И МОДЕРАТОРА
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

-- Удаление существующих пользователей (если есть)
DELETE FROM user_role WHERE user_id IN (
    SELECT id_user FROM model_user WHERE username IN ('Administraror228', 'Moderator')
);
DELETE FROM model_user WHERE username IN ('Administraror228', 'Moderator');

-- Добавление администратора
-- Пароль: "Administraror228!" (закодирован с BCrypt)
INSERT INTO model_user (username, password, active) VALUES 
('Administraror228', '$2b$08$Tp17.Lwf21SHlifc7qm8z.VI4M3Kenp12biu/hKwnq9XGqrX0OjvO', true);

-- Добавление модератора
-- Пароль: "Moderator!" (закодирован с BCrypt)
INSERT INTO model_user (username, password, active) VALUES 
('Moderator', '$2b$08$yRnLjyStitYf5AJlPJsOHeJ1X/M4Xbkn.WaJpmhSN8ALA/sHXXN8a', true);

-- Назначение роли ADMIN для администратора
INSERT INTO user_role (user_id, roles) 
SELECT id_user, 'ADMIN' FROM model_user WHERE username = 'Administraror228';

-- Назначение роли MODERATOR для модератора
INSERT INTO user_role (user_id, roles) 
SELECT id_user, 'MODERATOR' FROM model_user WHERE username = 'Moderator';

-- Проверка результата
SELECT 
    u.username,
    u.active,
    STRING_AGG(ur.roles, ', ') as roles
FROM model_user u
LEFT JOIN user_role ur ON u.id_user = ur.user_id
WHERE u.username IN ('Administraror228', 'Moderator')
GROUP BY u.id_user, u.username, u.active;

SELECT 'Пользователи созданы успешно!' as status;
SELECT 'Администратор: Administraror228 / Administraror228!' as admin_credentials;
SELECT 'Модератор: Moderator / Moderator!' as moderator_credentials;
