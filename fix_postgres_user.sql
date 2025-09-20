-- Альтернативный скрипт для создания пользователя с правильным паролем
-- Если у вас уже есть PostgreSQL, но нужно изменить пароль пользователя postgres

-- Подключитесь к PostgreSQL как суперпользователь и выполните:

-- Изменение пароля для пользователя postgres
ALTER USER postgres PASSWORD 'postgres';

-- Или создание нового пользователя, если postgres не существует
-- CREATE USER postgres WITH PASSWORD 'postgres' SUPERUSER;

-- Создание базы данных
CREATE DATABASE spring_security_db OWNER postgres;

-- Предоставление всех прав
GRANT ALL PRIVILEGES ON DATABASE spring_security_db TO postgres;
