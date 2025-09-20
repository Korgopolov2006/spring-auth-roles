-- Скрипт для проверки структуры базы данных
-- Выполните этот скрипт, чтобы увидеть, какие таблицы и поля уже существуют

-- Проверяем существующие таблицы
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Проверяем структуру таблицы coupons
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'coupons' 
ORDER BY ordinal_position;

-- Проверяем структуру таблицы product_specifications
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'product_specifications' 
ORDER BY ordinal_position;

-- Проверяем структуру таблицы orders
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'orders' 
ORDER BY ordinal_position;

