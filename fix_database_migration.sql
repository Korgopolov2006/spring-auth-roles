-- Скрипт для исправления миграции базы данных
-- Выполните этот скрипт перед запуском приложения

-- 1. Исправляем таблицу coupons
-- Добавляем новые поля с значениями по умолчанию
ALTER TABLE coupons ADD COLUMN IF NOT EXISTS discount_type VARCHAR(20) DEFAULT 'PERCENTAGE';
ALTER TABLE coupons ADD COLUMN IF NOT EXISTS discount_value NUMERIC(10, 2) DEFAULT 0.00;
ALTER TABLE coupons ADD COLUMN IF NOT EXISTS name VARCHAR(100) DEFAULT 'Промокод';

-- Обновляем существующие записи
UPDATE coupons SET 
    discount_type = 'PERCENTAGE',
    discount_value = COALESCE(discount_percentage, 0.00),
    name = COALESCE(code, 'Промокод')
WHERE discount_type IS NULL OR discount_value IS NULL OR name IS NULL;

-- Делаем поля NOT NULL после обновления
ALTER TABLE coupons ALTER COLUMN discount_type SET NOT NULL;
ALTER TABLE coupons ALTER COLUMN discount_value SET NOT NULL;
ALTER TABLE coupons ALTER COLUMN name SET NOT NULL;

-- 2. Исправляем таблицу product_specifications
-- Добавляем новые поля с значениями по умолчанию
ALTER TABLE product_specifications ADD COLUMN IF NOT EXISTS spec_name VARCHAR(100) DEFAULT 'Характеристика';
ALTER TABLE product_specifications ADD COLUMN IF NOT EXISTS spec_value VARCHAR(255) DEFAULT 'Значение';

-- Обновляем существующие записи
UPDATE product_specifications SET 
    spec_name = COALESCE(name, 'Характеристика'),
    spec_value = COALESCE(value, 'Значение')
WHERE spec_name IS NULL OR spec_value IS NULL;

-- Делаем поля NOT NULL после обновления
ALTER TABLE product_specifications ALTER COLUMN spec_name SET NOT NULL;
ALTER TABLE product_specifications ALTER COLUMN spec_value SET NOT NULL;

-- 3. Добавляем недостающие поля в другие таблицы если нужно
-- Добавляем поля в таблицу orders если их нет
ALTER TABLE orders ADD COLUMN IF NOT EXISTS order_number VARCHAR(50);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS shipping_cost NUMERIC(10, 2) DEFAULT 0.00;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS tax_amount NUMERIC(10, 2) DEFAULT 0.00;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS discount_amount NUMERIC(10, 2) DEFAULT 0.00;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_method VARCHAR(50);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_status VARCHAR(50) DEFAULT 'PENDING';
ALTER TABLE orders ADD COLUMN IF NOT EXISTS shipping_address TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS billing_address TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS notes TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Добавляем поля в таблицу order_items если их нет
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS product_name VARCHAR(255);
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS product_sku VARCHAR(100);
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS unit_price NUMERIC(10, 2);
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS total_price NUMERIC(10, 2);
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Добавляем поля в таблицу product_reviews если их нет
ALTER TABLE product_reviews ADD COLUMN IF NOT EXISTS is_approved BOOLEAN DEFAULT FALSE;
ALTER TABLE product_reviews ADD COLUMN IF NOT EXISTS review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Добавляем поля в таблицу cart_items если их нет
ALTER TABLE cart_items ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- 4. Обновляем существующие записи orders
UPDATE orders SET 
    order_number = 'ORD-' || LPAD(id::text, 10, '0'),
    payment_status = 'PENDING',
    created_at = COALESCE(order_date, CURRENT_TIMESTAMP),
    updated_at = CURRENT_TIMESTAMP
WHERE order_number IS NULL OR payment_status IS NULL;

-- 5. Обновляем существующие записи order_items
UPDATE order_items SET 
    product_name = 'Товар',
    product_sku = 'SKU-' || LPAD(id::text, 6, '0'),
    unit_price = COALESCE(price_at_order, 0.00),
    total_price = COALESCE(price_at_order, 0.00) * quantity,
    created_at = CURRENT_TIMESTAMP
WHERE product_name IS NULL OR unit_price IS NULL;

-- 6. Обновляем существующие записи product_reviews
UPDATE product_reviews SET 
    is_approved = FALSE,
    review_date = CURRENT_TIMESTAMP
WHERE is_approved IS NULL OR review_date IS NULL;

-- 7. Обновляем существующие записи cart_items
UPDATE cart_items SET 
    created_at = CURRENT_TIMESTAMP
WHERE created_at IS NULL;

-- 8. Создаем индексы для производительности
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_manufacturer ON products(manufacturer_id);
CREATE INDEX IF NOT EXISTS idx_products_active ON products(is_active);
CREATE INDEX IF NOT EXISTS idx_orders_user ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_cart_items_user ON cart_items(user_id);
CREATE INDEX IF NOT EXISTS idx_product_reviews_product ON product_reviews(product_id);
CREATE INDEX IF NOT EXISTS idx_product_reviews_approved ON product_reviews(is_approved);

-- 9. Обновляем статистику таблиц
ANALYZE;

COMMIT;

