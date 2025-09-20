# Создание пользователей для SpringSecRoles

## Созданные пользователи

### Администратор
- **Логин:** `Administraror228`
- **Пароль:** `Administraror228!`
- **Роль:** `ADMIN`
- **Доступ:** Полный доступ ко всем функциям системы

### Модератор
- **Логин:** `Moderator`
- **Пароль:** `Moderator!`
- **Роль:** `MODERATOR`
- **Доступ:** Управление товарами и контентом

## Способы создания пользователей

### 1. Через SQL скрипты

#### Полный скрипт (создает таблицы если нужно):
```bash
psql -U postgres -d YP4SpringAuthorizathion -f create_custom_users.sql
```

#### Быстрый скрипт (только добавляет пользователей):
```bash
psql -U postgres -d YP4SpringAuthorizathion -f quick_add_users.sql
```

### 2. Через Spring Boot приложение

Пользователи будут автоматически созданы при запуске приложения благодаря `UserCreator` компоненту.

### 3. Ручное выполнение SQL

```sql
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
```

## Проверка создания пользователей

```sql
SELECT 
    u.username,
    u.active,
    STRING_AGG(ur.roles, ', ') as roles
FROM model_user u
LEFT JOIN user_role ur ON u.id_user = ur.user_id
WHERE u.username IN ('Administraror228', 'Moderator')
GROUP BY u.id_user, u.username, u.active;
```

## Безопасность

- Пароли закодированы с помощью BCrypt с 8 раундами
- Хеши генерируются с уникальной солью для каждого пользователя
- Пароли не хранятся в открытом виде в базе данных

## Доступ к приложению

После создания пользователей вы можете войти в систему:
1. Перейдите на страницу входа: `http://localhost:8080/login`
2. Введите логин и пароль одного из созданных пользователей
3. После успешного входа вы будете перенаправлены на соответствующую панель управления
