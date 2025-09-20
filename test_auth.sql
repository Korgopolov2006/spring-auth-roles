-- Тестирование авторизации
-- Подключение к базе данных
\c YP4SpringAuthorizathion;

-- Проверяем существующих пользователей и их роли
SELECT 
    u.id_user,
    u.username,
    u.active,
    STRING_AGG(ur.roles, ', ') as roles
FROM model_user u
LEFT JOIN user_role ur ON u.id_user = ur.user_id
GROUP BY u.id_user, u.username, u.active
ORDER BY u.id_user;

-- Проверяем конкретно администратора и модератора
SELECT 
    u.username,
    u.active,
    STRING_AGG(ur.roles, ', ') as roles
FROM model_user u
LEFT JOIN user_role ur ON u.id_user = ur.user_id
WHERE u.username IN ('admin', 'moderator', 'user', 'Administraror228', 'Moderator')
GROUP BY u.id_user, u.username, u.active
ORDER BY u.username;
