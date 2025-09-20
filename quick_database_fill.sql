-- =====================================================
-- БЫСТРОЕ ЗАПОЛНЕНИЕ БАЗЫ ДАННЫХ
-- База данных: YP4SpringAuthorizathion
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

-- Очистка существующих данных
DELETE FROM user_role;
DELETE FROM model_user;

-- Вставка пользователей (пароль: "password123")
INSERT INTO model_user (username, password, active) VALUES 
('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', true),
('moderator', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', true),
('user', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', true),
('test', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', true);

-- Назначение ролей
INSERT INTO user_role (user_id, roles) 
SELECT id_user, 'ADMIN' FROM model_user WHERE username = 'admin';

INSERT INTO user_role (user_id, roles) 
SELECT id_user, 'MODERATOR' FROM model_user WHERE username = 'moderator';

INSERT INTO user_role (user_id, roles) 
SELECT id_user, 'USER' FROM model_user WHERE username = 'user';

INSERT INTO user_role (user_id, roles) 
SELECT id_user, 'USER' FROM model_user WHERE username = 'test';

-- Проверка результата
SELECT 
    u.username,
    u.active,
    STRING_AGG(ur.roles, ', ') as roles
FROM model_user u
LEFT JOIN user_role ur ON u.id_user = ur.user_id
GROUP BY u.id_user, u.username, u.active
ORDER BY u.id_user;

SELECT 'Database filled successfully!' as status;

