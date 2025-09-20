-- Быстрое исправление критических проблем базы данных
-- Выполните этот скрипт для исправления ошибок миграции

-- 1. Исправляем таблицу coupons
ALTER TABLE coupons ADD COLUMN IF NOT EXISTS discount_type VARCHAR(20);
ALTER TABLE coupons ADD COLUMN IF NOT EXISTS discount_value NUMERIC(10, 2);
ALTER TABLE coupons ADD COLUMN IF NOT EXISTS name VARCHAR(100);

-- Заполняем значениями по умолчанию
UPDATE coupons SET 
    discount_type = 'PERCENTAGE',
    discount_value = COALESCE(discount_percentage, 10.00),
    name = COALESCE(code, 'Промокод')
WHERE discount_type IS NULL;

-- Делаем поля NOT NULL
ALTER TABLE coupons ALTER COLUMN discount_type SET NOT NULL;
ALTER TABLE coupons ALTER COLUMN discount_value SET NOT NULL;
ALTER TABLE coupons ALTER COLUMN name SET NOT NULL;

-- 2. Исправляем таблицу product_specifications
ALTER TABLE product_specifications ADD COLUMN IF NOT EXISTS spec_name VARCHAR(100);
ALTER TABLE product_specifications ADD COLUMN IF NOT EXISTS spec_value VARCHAR(255);

-- Заполняем значениями по умолчанию
UPDATE product_specifications SET 
    spec_name = COALESCE(name, 'Характеристика'),
    spec_value = COALESCE(value, 'Значение')
WHERE spec_name IS NULL;

-- Делаем поля NOT NULL
ALTER TABLE product_specifications ALTER COLUMN spec_name SET NOT NULL;
ALTER TABLE product_specifications ALTER COLUMN spec_value SET NOT NULL;

-- 3. Добавляем недостающие поля в orders
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

-- 4. Добавляем недостающие поля в order_items
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS product_name VARCHAR(255);
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS product_sku VARCHAR(100);
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS unit_price NUMERIC(10, 2);
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS total_price NUMERIC(10, 2);
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- 5. Добавляем недостающие поля в product_reviews
ALTER TABLE product_reviews ADD COLUMN IF NOT EXISTS is_approved BOOLEAN DEFAULT FALSE;
ALTER TABLE product_reviews ADD COLUMN IF NOT EXISTS review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- 6. Добавляем недостающие поля в cart_items
ALTER TABLE cart_items ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- 7. Обновляем существующие записи
UPDATE orders SET 
    order_number = 'ORD-' || LPAD(id::text, 10, '0'),
    payment_status = 'PENDING',
    created_at = COALESCE(order_date, CURRENT_TIMESTAMP),
    updated_at = CURRENT_TIMESTAMP
WHERE order_number IS NULL;

UPDATE order_items SET 
    product_name = 'Товар',
    product_sku = 'SKU-' || LPAD(id::text, 6, '0'),
    unit_price = COALESCE(price_at_order, 0.00),
    total_price = COALESCE(price_at_order, 0.00) * quantity,
    created_at = CURRENT_TIMESTAMP
WHERE product_name IS NULL;

UPDATE product_reviews SET 
    is_approved = FALSE,
    review_date = CURRENT_TIMESTAMP
WHERE is_approved IS NULL;

UPDATE cart_items SET 
    created_at = CURRENT_TIMESTAMP
WHERE created_at IS NULL;

COMMIT;

