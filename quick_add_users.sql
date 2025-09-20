-- Быстрое добавление пользователей
-- Подключение к базе данных
\c YP4SpringAuthorizathion;

-- Удаление существующих пользователей
DELETE FROM user_role WHERE user_id IN (
    SELECT id_user FROM model_user WHERE username IN ('Administraror228', 'Moderator')
);
DELETE FROM model_user WHERE username IN ('Administraror228', 'Moderator');

-- Добавление администратора
INSERT INTO model_user (username, password, active) VALUES 
('Administraror228', '$2b$08$Tp17.Lwf21SHlifc7qm8z.VI4M3Kenp12biu/hKwnq9XGqrX0OjvO', true);

-- Добавление модератора
INSERT INTO model_user (username, password, active) VALUES 
('Moderator', '$2b$08$yRnLjyStitYf5AJlPJsOHeJ1X/M4Xbkn.WaJpmhSN8ALA/sHXXN8a', true);

-- Назначение ролей
INSERT INTO user_role (user_id, roles) 
SELECT id_user, 'ADMIN' FROM model_user WHERE username = 'Administraror228';

INSERT INTO user_role (user_id, roles) 
SELECT id_user, 'MODERATOR' FROM model_user WHERE username = 'Moderator';

-- Проверка
SELECT u.username, u.active, STRING_AGG(ur.roles, ', ') as roles
FROM model_user u
LEFT JOIN user_role ur ON u.id_user = ur.user_id
WHERE u.username IN ('Administraror228', 'Moderator')
GROUP BY u.id_user, u.username, u.active;
