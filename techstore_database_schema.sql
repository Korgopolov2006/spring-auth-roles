-- =====================================================
-- СХЕМА БАЗЫ ДАННЫХ ДЛЯ МАГАЗИНА ЭЛЕКТРОНИКИ "TECHSTORE"
-- =====================================================
-- Система с тремя ролями: ADMIN, MODERATOR, USER
-- Минимум 10 таблиц для полноценного магазина

-- =====================================================
-- 1. ПОЛЬЗОВАТЕЛИ И РОЛИ (уже есть)
-- =====================================================

-- Таблица пользователей (уже существует)
-- model_user (id_user, username, password, active)

-- Таблица ролей (уже существует)  
-- user_role (user_id, roles)

-- =====================================================
-- 2. КАТЕГОРИИ ТОВАРОВ
-- =====================================================

CREATE TABLE IF NOT EXISTS categories (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    parent_id BIGINT REFERENCES categories(id),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 3. ПРОИЗВОДИТЕЛИ
-- =====================================================

CREATE TABLE IF NOT EXISTS manufacturers (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    country VARCHAR(50),
    website VARCHAR(255),
    description TEXT,
    logo_url VARCHAR(255),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 4. ТОВАРЫ
-- =====================================================

CREATE TABLE IF NOT EXISTS products (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    old_price DECIMAL(10,2),
    sku VARCHAR(100) UNIQUE,
    category_id BIGINT REFERENCES categories(id),
    manufacturer_id BIGINT REFERENCES manufacturers(id),
    stock_quantity INTEGER DEFAULT 0,
    min_stock_level INTEGER DEFAULT 5,
    weight DECIMAL(8,2),
    dimensions VARCHAR(50),
    warranty_months INTEGER,
    is_active BOOLEAN DEFAULT true,
    is_featured BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 5. ИЗОБРАЖЕНИЯ ТОВАРОВ
-- =====================================================

CREATE TABLE IF NOT EXISTS product_images (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT REFERENCES products(id) ON DELETE CASCADE,
    image_url VARCHAR(255) NOT NULL,
    alt_text VARCHAR(255),
    is_primary BOOLEAN DEFAULT false,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 6. ХАРАКТЕРИСТИКИ ТОВАРОВ
-- =====================================================

CREATE TABLE IF NOT EXISTS product_specifications (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT REFERENCES products(id) ON DELETE CASCADE,
    spec_name VARCHAR(100) NOT NULL,
    spec_value VARCHAR(255) NOT NULL,
    spec_unit VARCHAR(20),
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 7. ОТЗЫВЫ И РЕЙТИНГИ
-- =====================================================

CREATE TABLE IF NOT EXISTS product_reviews (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT REFERENCES products(id) ON DELETE CASCADE,
    user_id BIGINT REFERENCES model_user(id_user) ON DELETE CASCADE,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    title VARCHAR(255),
    comment TEXT,
    is_verified_purchase BOOLEAN DEFAULT false,
    is_approved BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 8. КОРЗИНА ПОКУПОК
-- =====================================================

CREATE TABLE IF NOT EXISTS cart_items (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES model_user(id_user) ON DELETE CASCADE,
    product_id BIGINT REFERENCES products(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL DEFAULT 1,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, product_id)
);

-- =====================================================
-- 9. ЗАКАЗЫ
-- =====================================================

CREATE TABLE IF NOT EXISTS orders (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES model_user(id_user),
    order_number VARCHAR(50) UNIQUE NOT NULL,
    status VARCHAR(20) DEFAULT 'PENDING',
    total_amount DECIMAL(10,2) NOT NULL,
    shipping_cost DECIMAL(10,2) DEFAULT 0,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    payment_method VARCHAR(50),
    payment_status VARCHAR(20) DEFAULT 'PENDING',
    shipping_address TEXT,
    billing_address TEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 10. ЭЛЕМЕНТЫ ЗАКАЗА
-- =====================================================

CREATE TABLE IF NOT EXISTS order_items (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT REFERENCES orders(id) ON DELETE CASCADE,
    product_id BIGINT REFERENCES products(id),
    product_name VARCHAR(255) NOT NULL,
    product_sku VARCHAR(100),
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 11. КУПОНЫ И СКИДКИ
-- =====================================================

CREATE TABLE IF NOT EXISTS coupons (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    discount_type VARCHAR(20) NOT NULL, -- PERCENTAGE, FIXED_AMOUNT
    discount_value DECIMAL(10,2) NOT NULL,
    min_order_amount DECIMAL(10,2) DEFAULT 0,
    max_discount_amount DECIMAL(10,2),
    usage_limit INTEGER,
    used_count INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    valid_from TIMESTAMP,
    valid_until TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 12. ИСТОРИЯ ДЕЙСТВИЙ ПОЛЬЗОВАТЕЛЕЙ
-- =====================================================

CREATE TABLE IF NOT EXISTS user_activity_log (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES model_user(id_user),
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50),
    entity_id BIGINT,
    details JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 13. НАСТРОЙКИ СИСТЕМЫ
-- =====================================================

CREATE TABLE IF NOT EXISTS system_settings (
    id BIGSERIAL PRIMARY KEY,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT,
    setting_type VARCHAR(20) DEFAULT 'STRING',
    description TEXT,
    is_public BOOLEAN DEFAULT false,
    updated_by BIGINT REFERENCES model_user(id_user),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- ИНДЕКСЫ ДЛЯ ОПТИМИЗАЦИИ
-- =====================================================

-- Индексы для товаров
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_manufacturer ON products(manufacturer_id);
CREATE INDEX IF NOT EXISTS idx_products_price ON products(price);
CREATE INDEX IF NOT EXISTS idx_products_active ON products(is_active);
CREATE INDEX IF NOT EXISTS idx_products_featured ON products(is_featured);

-- Индексы для отзывов
CREATE INDEX IF NOT EXISTS idx_reviews_product ON product_reviews(product_id);
CREATE INDEX IF NOT EXISTS idx_reviews_user ON product_reviews(user_id);
CREATE INDEX IF NOT EXISTS idx_reviews_approved ON product_reviews(is_approved);

-- Индексы для заказов
CREATE INDEX IF NOT EXISTS idx_orders_user ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_created ON orders(created_at);

-- Индексы для корзины
CREATE INDEX IF NOT EXISTS idx_cart_user ON cart_items(user_id);

-- Индексы для активности
CREATE INDEX IF NOT EXISTS idx_activity_user ON user_activity_log(user_id);
CREATE INDEX IF NOT EXISTS idx_activity_created ON user_activity_log(created_at);

-- =====================================================
-- ЗАПОЛНЕНИЕ ТЕСТОВЫМИ ДАННЫМИ
-- =====================================================

-- Очистка существующих данных
DELETE FROM user_role;
DELETE FROM model_user;

-- Сброс последовательности
ALTER SEQUENCE model_user_id_user_seq RESTART WITH 1;

-- Создание пользователей с ролями
INSERT INTO model_user (username, password, active) VALUES 
('admin', '$2a$08$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', true),
('moderator', '$2a$08$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', true),
('user', '$2a$08$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDi', true);

INSERT INTO user_role (user_id, roles) VALUES 
(1, 'ADMIN'),
(2, 'MODERATOR'),
(3, 'USER');

-- Категории товаров
INSERT INTO categories (name, description) VALUES 
('Смартфоны', 'Мобильные телефоны и аксессуары'),
('Ноутбуки', 'Портативные компьютеры'),
('Планшеты', 'Планшетные компьютеры'),
('Наушники', 'Аудио аксессуары'),
('Игровые консоли', 'Игровые приставки и аксессуары'),
('Компьютеры', 'Настольные компьютеры и комплектующие'),
('Телевизоры', 'Телевизоры и мониторы'),
('Фототехника', 'Камеры и фотооборудование');

-- Производители
INSERT INTO manufacturers (name, country, website) VALUES 
('Apple', 'USA', 'https://apple.com'),
('Samsung', 'South Korea', 'https://samsung.com'),
('Sony', 'Japan', 'https://sony.com'),
('Microsoft', 'USA', 'https://microsoft.com'),
('ASUS', 'Taiwan', 'https://asus.com'),
('HP', 'USA', 'https://hp.com'),
('Dell', 'USA', 'https://dell.com'),
('Canon', 'Japan', 'https://canon.com'),
('Nikon', 'Japan', 'https://nikon.com'),
('LG', 'South Korea', 'https://lg.com');

-- Товары
INSERT INTO products (name, description, price, old_price, sku, category_id, manufacturer_id, stock_quantity, warranty_months, is_featured) VALUES 
('iPhone 15 Pro', 'Новейший смартфон Apple с титановым корпусом', 99999.00, 109999.00, 'IPH15PRO-256', 1, 1, 50, 12, true),
('Samsung Galaxy S24 Ultra', 'Флагманский Android смартфон', 89999.00, 94999.00, 'SGS24U-512', 1, 2, 30, 12, true),
('MacBook Pro 16"', 'Профессиональный ноутбук Apple', 199999.00, 219999.00, 'MBP16-M3', 2, 1, 20, 12, true),
('iPad Pro 12.9"', 'Планшет для профессионалов', 89999.00, 94999.00, 'IPADPRO-129', 3, 1, 25, 12, false),
('AirPods Pro 2', 'Беспроводные наушники с шумоподавлением', 19999.00, 21999.00, 'APP2-WHITE', 4, 1, 100, 12, true),
('PlayStation 5', 'Игровая консоль нового поколения', 49999.00, 54999.00, 'PS5-STD', 5, 3, 15, 12, true),
('Xbox Series X', 'Мощная игровая консоль Microsoft', 44999.00, 49999.00, 'XSX-1TB', 5, 4, 12, 12, false),
('ASUS ROG Strix', 'Игровой ноутбук высокого класса', 149999.00, 159999.00, 'ROG-STRIX-17', 2, 5, 8, 12, false),
('Sony WH-1000XM5', 'Премиальные наушники с шумоподавлением', 24999.00, 27999.00, 'WH1000XM5-BLK', 4, 3, 40, 12, true),
('Canon EOS R5', 'Профессиональная зеркальная камера', 299999.00, 319999.00, 'EOS-R5-BODY', 8, 8, 5, 12, true);

-- Изображения товаров
INSERT INTO product_images (product_id, image_url, alt_text, is_primary) VALUES 
(1, '/images/iphone15pro-1.jpg', 'iPhone 15 Pro - вид спереди', true),
(1, '/images/iphone15pro-2.jpg', 'iPhone 15 Pro - вид сзади', false),
(2, '/images/sgs24ultra-1.jpg', 'Samsung Galaxy S24 Ultra', true),
(3, '/images/macbookpro-1.jpg', 'MacBook Pro 16 дюймов', true),
(4, '/images/ipadpro-1.jpg', 'iPad Pro 12.9 дюймов', true),
(5, '/images/airpodspro-1.jpg', 'AirPods Pro 2', true),
(6, '/images/ps5-1.jpg', 'PlayStation 5', true),
(7, '/images/xbox-1.jpg', 'Xbox Series X', true),
(8, '/images/asusrog-1.jpg', 'ASUS ROG Strix', true),
(9, '/images/sonywh-1.jpg', 'Sony WH-1000XM5', true),
(10, '/images/canoneos-1.jpg', 'Canon EOS R5', true);

-- Характеристики товаров
INSERT INTO product_specifications (product_id, spec_name, spec_value, spec_unit) VALUES 
(1, 'Экран', '6.1', 'дюймов'),
(1, 'Процессор', 'A17 Pro', ''),
(1, 'Память', '256', 'ГБ'),
(1, 'Камера', '48 МП', ''),
(1, 'Батарея', '3274', 'мАч'),
(2, 'Экран', '6.8', 'дюймов'),
(2, 'Процессор', 'Snapdragon 8 Gen 3', ''),
(2, 'Память', '512', 'ГБ'),
(2, 'Камера', '200 МП', ''),
(3, 'Экран', '16.2', 'дюймов'),
(3, 'Процессор', 'M3 Pro', ''),
(3, 'Память', '512', 'ГБ'),
(3, 'Графика', 'M3 Pro GPU', '');

-- Отзывы
INSERT INTO product_reviews (product_id, user_id, rating, title, comment, is_verified_purchase, is_approved) VALUES 
(1, 3, 5, 'Отличный телефон!', 'Очень доволен покупкой. Камера просто потрясающая!', true, true),
(1, 3, 4, 'Хорошо, но дорого', 'Качество на высоте, но цена кусается', true, true),
(2, 3, 5, 'Лучший Android', 'Samsung снова превзошел ожидания', true, true),
(3, 3, 5, 'Мощная машина', 'Идеально для работы и творчества', true, true);

-- Купоны
INSERT INTO coupons (code, name, discount_type, discount_value, min_order_amount, usage_limit, valid_until) VALUES 
('WELCOME10', 'Скидка 10% для новых клиентов', 'PERCENTAGE', 10.00, 5000.00, 100, CURRENT_TIMESTAMP + INTERVAL '30 days'),
('SAVE5000', 'Скидка 5000 рублей', 'FIXED_AMOUNT', 5000.00, 20000.00, 50, CURRENT_TIMESTAMP + INTERVAL '15 days'),
('TECH20', 'Скидка 20% на электронику', 'PERCENTAGE', 20.00, 10000.00, 200, CURRENT_TIMESTAMP + INTERVAL '60 days');

-- Настройки системы
INSERT INTO system_settings (setting_key, setting_value, setting_type, description, is_public) VALUES 
('store_name', 'TechStore', 'STRING', 'Название магазина', true),
('store_email', 'info@techstore.ru', 'STRING', 'Email магазина', true),
('store_phone', '+7 (800) 123-45-67', 'STRING', 'Телефон магазина', true),
('free_shipping_threshold', '5000', 'NUMBER', 'Порог бесплатной доставки', true),
('max_cart_items', '50', 'NUMBER', 'Максимум товаров в корзине', false),
('review_approval_required', 'true', 'BOOLEAN', 'Требуется одобрение отзывов', false);

-- =====================================================
-- ПРОВЕРКА ДАННЫХ
-- =====================================================

SELECT 'СТАТИСТИКА МАГАЗИНА:' as info
UNION ALL
SELECT 'Категорий: ' || COUNT(*) FROM categories
UNION ALL
SELECT 'Производителей: ' || COUNT(*) FROM manufacturers
UNION ALL
SELECT 'Товаров: ' || COUNT(*) FROM products
UNION ALL
SELECT 'Пользователей: ' || COUNT(*) FROM model_user
UNION ALL
SELECT 'Купонов: ' || COUNT(*) FROM coupons;

-- Показываем товары с категориями и производителями
SELECT 
    p.name as product_name,
    c.name as category,
    m.name as manufacturer,
    p.price,
    p.stock_quantity
FROM products p
JOIN categories c ON p.category_id = c.id
JOIN manufacturers m ON p.manufacturer_id = m.id
ORDER BY p.is_featured DESC, p.created_at DESC;

SELECT 'База данных магазина TechStore успешно создана!' as status;


