-- =====================================================
-- СКРИПТ БАЗЫ ДАННЫХ ДЛЯ МАГАЗИНА ЭЛЕКТРОНИКИ TECHSTORE
-- База данных: YP4SpringAuthorizathion
-- =====================================================

-- Подключение к базе данных
\c YP4SpringAuthorizathion;

-- =====================================================
-- СОЗДАНИЕ ТАБЛИЦ
-- =====================================================

-- Таблица пользователей (уже существует)
CREATE TABLE IF NOT EXISTS model_user (
    id_user BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    active BOOLEAN DEFAULT true
);

-- Таблица ролей пользователей (уже существует)
CREATE TABLE IF NOT EXISTS user_role (
    user_id BIGINT NOT NULL,
    roles VARCHAR(20) NOT NULL,
    PRIMARY KEY (user_id, roles),
    FOREIGN KEY (user_id) REFERENCES model_user(id_user) ON DELETE CASCADE
);

-- Таблица категорий товаров
CREATE TABLE IF NOT EXISTS categories (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    parent_id BIGINT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE SET NULL
);

-- Таблица производителей
CREATE TABLE IF NOT EXISTS manufacturers (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    country VARCHAR(50),
    website VARCHAR(255),
    description TEXT,
    logo_url VARCHAR(255),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица товаров
CREATE TABLE IF NOT EXISTS products (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    old_price DECIMAL(10,2),
    sku VARCHAR(100) UNIQUE,
    category_id BIGINT,
    manufacturer_id BIGINT,
    stock_quantity INTEGER DEFAULT 0,
    min_stock_level INTEGER DEFAULT 5,
    weight DECIMAL(8,2),
    dimensions VARCHAR(50),
    warranty_months INTEGER,
    is_active BOOLEAN DEFAULT true,
    is_featured BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
    FOREIGN KEY (manufacturer_id) REFERENCES manufacturers(id) ON DELETE SET NULL
);

-- Таблица изображений товаров
CREATE TABLE IF NOT EXISTS product_images (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL,
    image_url VARCHAR(255) NOT NULL,
    is_primary BOOLEAN DEFAULT false,
    sort_order INTEGER DEFAULT 0,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Таблица характеристик товаров
CREATE TABLE IF NOT EXISTS product_specifications (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL,
    name VARCHAR(100) NOT NULL,
    value VARCHAR(255) NOT NULL,
    sort_order INTEGER DEFAULT 0,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Таблица отзывов о товарах
CREATE TABLE IF NOT EXISTS product_reviews (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_approved BOOLEAN DEFAULT false,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES model_user(id_user) ON DELETE CASCADE
);

-- Таблица корзины
CREATE TABLE IF NOT EXISTS cart_items (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES model_user(id_user) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    UNIQUE(user_id, product_id)
);

-- Таблица заказов
CREATE TABLE IF NOT EXISTS orders (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'PENDING',
    shipping_address TEXT,
    billing_address TEXT,
    notes TEXT,
    FOREIGN KEY (user_id) REFERENCES model_user(id_user) ON DELETE CASCADE
);

-- Таблица элементов заказа
CREATE TABLE IF NOT EXISTS order_items (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INTEGER NOT NULL,
    price_at_order DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Таблица купонов
CREATE TABLE IF NOT EXISTS coupons (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    discount_percentage DECIMAL(5,2),
    discount_amount DECIMAL(10,2),
    min_order_amount DECIMAL(10,2),
    max_discount_amount DECIMAL(10,2),
    usage_limit INTEGER,
    used_count INTEGER DEFAULT 0,
    expiration_date TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица активности пользователей
CREATE TABLE IF NOT EXISTS user_activity_log (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT,
    activity_type VARCHAR(50) NOT NULL,
    description TEXT,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES model_user(id_user) ON DELETE SET NULL
);

-- Таблица настроек системы
CREATE TABLE IF NOT EXISTS system_settings (
    id BIGSERIAL PRIMARY KEY,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT,
    description TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- СОЗДАНИЕ ИНДЕКСОВ
-- =====================================================

-- Индексы для таблицы пользователей
CREATE INDEX IF NOT EXISTS idx_model_user_username ON model_user(username);
CREATE INDEX IF NOT EXISTS idx_model_user_active ON model_user(active);

-- Индексы для таблицы ролей
CREATE INDEX IF NOT EXISTS idx_user_role_user_id ON user_role(user_id);
CREATE INDEX IF NOT EXISTS idx_user_role_roles ON user_role(roles);

-- Индексы для таблицы категорий
CREATE INDEX IF NOT EXISTS idx_categories_name ON categories(name);
CREATE INDEX IF NOT EXISTS idx_categories_parent_id ON categories(parent_id);
CREATE INDEX IF NOT EXISTS idx_categories_is_active ON categories(is_active);

-- Индексы для таблицы производителей
CREATE INDEX IF NOT EXISTS idx_manufacturers_name ON manufacturers(name);
CREATE INDEX IF NOT EXISTS idx_manufacturers_country ON manufacturers(country);
CREATE INDEX IF NOT EXISTS idx_manufacturers_is_active ON manufacturers(is_active);

-- Индексы для таблицы товаров
CREATE INDEX IF NOT EXISTS idx_products_name ON products(name);
CREATE INDEX IF NOT EXISTS idx_products_sku ON products(sku);
CREATE INDEX IF NOT EXISTS idx_products_category_id ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_manufacturer_id ON products(manufacturer_id);
CREATE INDEX IF NOT EXISTS idx_products_price ON products(price);
CREATE INDEX IF NOT EXISTS idx_products_is_active ON products(is_active);
CREATE INDEX IF NOT EXISTS idx_products_is_featured ON products(is_featured);
CREATE INDEX IF NOT EXISTS idx_products_stock_quantity ON products(stock_quantity);

-- Индексы для таблицы изображений товаров
CREATE INDEX IF NOT EXISTS idx_product_images_product_id ON product_images(product_id);
CREATE INDEX IF NOT EXISTS idx_product_images_is_primary ON product_images(is_primary);

-- Индексы для таблицы характеристик
CREATE INDEX IF NOT EXISTS idx_product_specifications_product_id ON product_specifications(product_id);

-- Индексы для таблицы отзывов
CREATE INDEX IF NOT EXISTS idx_product_reviews_product_id ON product_reviews(product_id);
CREATE INDEX IF NOT EXISTS idx_product_reviews_user_id ON product_reviews(user_id);
CREATE INDEX IF NOT EXISTS idx_product_reviews_rating ON product_reviews(rating);
CREATE INDEX IF NOT EXISTS idx_product_reviews_is_approved ON product_reviews(is_approved);

-- Индексы для таблицы корзины
CREATE INDEX IF NOT EXISTS idx_cart_items_user_id ON cart_items(user_id);
CREATE INDEX IF NOT EXISTS idx_cart_items_product_id ON cart_items(product_id);

-- Индексы для таблицы заказов
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_order_date ON orders(order_date);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);

-- Индексы для таблицы элементов заказа
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON order_items(product_id);

-- Индексы для таблицы купонов
CREATE INDEX IF NOT EXISTS idx_coupons_code ON coupons(code);
CREATE INDEX IF NOT EXISTS idx_coupons_is_active ON coupons(is_active);
CREATE INDEX IF NOT EXISTS idx_coupons_expiration_date ON coupons(expiration_date);

-- Индексы для таблицы активности
CREATE INDEX IF NOT EXISTS idx_user_activity_log_user_id ON user_activity_log(user_id);
CREATE INDEX IF NOT EXISTS idx_user_activity_log_activity_type ON user_activity_log(activity_type);
CREATE INDEX IF NOT EXISTS idx_user_activity_log_created_at ON user_activity_log(created_at);

-- =====================================================
-- ЗАПОЛНЕНИЕ ТЕСТОВЫМИ ДАННЫМИ
-- =====================================================

-- Очистка существующих данных
DELETE FROM user_role;
DELETE FROM model_user;

-- Вставка пользователей
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

-- Вставка категорий
INSERT INTO categories (name, description, parent_id) VALUES 
('Смартфоны', 'Мобильные телефоны и аксессуары', NULL),
('Ноутбуки', 'Портативные компьютеры', NULL),
('Планшеты', 'Планшетные компьютеры', NULL),
('Наушники', 'Аудио аксессуары', NULL),
('Игровые устройства', 'Игровые консоли и аксессуары', NULL),
('Аксессуары', 'Аксессуары для электроники', NULL);

-- Подкатегории
INSERT INTO categories (name, description, parent_id) VALUES 
('iPhone', 'Смартфоны Apple', 1),
('Samsung Galaxy', 'Смартфоны Samsung', 1),
('Xiaomi', 'Смартфоны Xiaomi', 1),
('Игровые ноутбуки', 'Ноутбуки для игр', 2),
('Офисные ноутбуки', 'Ноутбуки для работы', 2),
('iPad', 'Планшеты Apple', 3),
('Android планшеты', 'Планшеты на Android', 3);

-- Вставка производителей
INSERT INTO manufacturers (name, country, website, description) VALUES 
('Apple', 'США', 'https://apple.com', 'Американская корпорация, производитель электроники'),
('Samsung', 'Южная Корея', 'https://samsung.com', 'Южнокорейская корпорация, производитель электроники'),
('Xiaomi', 'Китай', 'https://mi.com', 'Китайская компания, производитель смартфонов и электроники'),
('ASUS', 'Тайвань', 'https://asus.com', 'Тайваньская компания, производитель компьютеров и электроники'),
('Sony', 'Япония', 'https://sony.com', 'Японская корпорация, производитель электроники'),
('Microsoft', 'США', 'https://microsoft.com', 'Американская корпорация, производитель ПО и электроники'),
('Huawei', 'Китай', 'https://huawei.com', 'Китайская компания, производитель телекоммуникационного оборудования'),
('OnePlus', 'Китай', 'https://oneplus.com', 'Китайская компания, производитель смартфонов');

-- Вставка товаров
INSERT INTO products (name, description, price, old_price, sku, category_id, manufacturer_id, stock_quantity, min_stock_level, weight, dimensions, warranty_months, is_active, is_featured) VALUES 
-- Смартфоны
('iPhone 15 Pro', 'Новейший флагманский смартфон Apple с титановым корпусом', 99999.00, 109999.00, 'IPH15PRO-256', 7, 1, 15, 5, 187.0, '146.6 x 70.6 x 8.25', 12, true, true),
('Samsung Galaxy S24 Ultra', 'Флагманский смартфон Samsung с S Pen', 89999.00, 94999.00, 'SGS24U-512', 8, 2, 12, 5, 232.0, '162.3 x 79.0 x 8.6', 12, true, true),
('Xiaomi 14 Pro', 'Премиальный смартфон Xiaomi с камерой Leica', 59999.00, 64999.00, 'XM14P-256', 9, 3, 20, 5, 210.0, '152.8 x 71.5 x 8.49', 12, true, true),
('iPhone 14', 'Популярный смартфон Apple предыдущего поколения', 69999.00, 74999.00, 'IPH14-128', 7, 1, 25, 5, 172.0, '146.7 x 71.5 x 7.80', 12, true, false),
('Samsung Galaxy A54', 'Средний класс смартфона Samsung', 29999.00, 32999.00, 'SGA54-128', 8, 2, 30, 5, 202.0, '158.2 x 76.7 x 8.2', 12, true, false),

-- Ноутбуки
('MacBook Pro 16" M3', 'Профессиональный ноутбук Apple с чипом M3', 199999.00, 219999.00, 'MBP16-M3-512', 10, 1, 8, 3, 2000.0, '355.7 x 248.1 x 16.8', 12, true, true),
('ASUS ROG Strix G16', 'Игровой ноутбук с RTX 4060', 129999.00, 139999.00, 'ASUS-ROG-G16-4060', 10, 4, 10, 3, 2500.0, '354 x 264 x 22.6', 12, true, true),
('MacBook Air 13" M2', 'Ультрабук Apple с чипом M2', 99999.00, 109999.00, 'MBA13-M2-256', 11, 1, 15, 5, 1240.0, '304.1 x 215.0 x 11.3', 12, true, false),
('ASUS VivoBook S15', 'Офисный ноутбук для работы', 49999.00, 54999.00, 'ASUS-VS15-512', 11, 4, 20, 5, 1500.0, '359.2 x 233.9 x 17.9', 12, true, false),

-- Планшеты
('iPad Pro 12.9" M2', 'Профессиональный планшет Apple', 89999.00, 94999.00, 'IPADPRO-12.9-M2', 12, 1, 12, 5, 682.0, '280.6 x 214.9 x 6.4', 12, true, true),
('Samsung Galaxy Tab S9', 'Android планшет премиум класса', 59999.00, 64999.00, 'SGTAB-S9-256', 13, 2, 15, 5, 498.0, '254.3 x 165.8 x 5.9', 12, true, false),
('iPad Air 5', 'Планшет Apple среднего класса', 49999.00, 54999.00, 'IPADAIR-5-64', 12, 1, 18, 5, 461.0, '247.6 x 178.5 x 6.1', 12, true, false),

-- Наушники
('AirPods Pro 2', 'Беспроводные наушники Apple с шумоподавлением', 19999.00, 21999.00, 'APP2-USB-C', 4, 1, 25, 5, 56.0, '45.2 x 60.9 x 21.7', 12, true, true),
('Sony WH-1000XM5', 'Беспроводные наушники Sony с шумоподавлением', 24999.00, 26999.00, 'SONY-WH1000XM5', 4, 5, 20, 5, 250.0, '200 x 170 x 80', 12, true, true),
('Samsung Galaxy Buds2 Pro', 'Беспроводные наушники Samsung', 14999.00, 16999.00, 'SGBUDS2-PRO', 4, 2, 30, 5, 45.0, '60.0 x 60.0 x 20.0', 12, true, false),

-- Игровые устройства
('PlayStation 5', 'Игровая консоль Sony', 49999.00, 54999.00, 'PS5-STD', 5, 5, 8, 3, 4200.0, '390 x 260 x 92', 12, true, true),
('Xbox Series X', 'Игровая консоль Microsoft', 45999.00, 49999.00, 'XBOX-SX-1TB', 5, 6, 10, 3, 4450.0, '301 x 151 x 151', 12, true, true),
('Nintendo Switch OLED', 'Портативная игровая консоль Nintendo', 29999.00, 32999.00, 'NSW-OLED-64', 5, 7, 15, 5, 420.0, '242 x 102 x 14', 12, true, false);

-- Вставка изображений товаров
INSERT INTO product_images (product_id, image_url, is_primary, sort_order) VALUES 
(1, '/images/iphone15pro-1.jpg', true, 1),
(1, '/images/iphone15pro-2.jpg', false, 2),
(2, '/images/sgs24ultra-1.jpg', true, 1),
(2, '/images/sgs24ultra-2.jpg', false, 2),
(3, '/images/xm14pro-1.jpg', true, 1),
(3, '/images/xm14pro-2.jpg', false, 2),
(6, '/images/mbp16m3-1.jpg', true, 1),
(6, '/images/mbp16m3-2.jpg', false, 2),
(7, '/images/asusrog-1.jpg', true, 1),
(7, '/images/asusrog-2.jpg', false, 2);

-- Вставка характеристик товаров
INSERT INTO product_specifications (product_id, name, value, sort_order) VALUES 
-- iPhone 15 Pro
(1, 'Экран', '6.1" Super Retina XDR', 1),
(1, 'Процессор', 'A17 Pro', 2),
(1, 'Память', '256 ГБ', 3),
(1, 'Камера', '48 МП основная + 12 МП ультраширокая', 4),
(1, 'Батарея', 'До 23 часов видео', 5),
(1, 'Материал', 'Титан', 6),

-- Samsung Galaxy S24 Ultra
(2, 'Экран', '6.8" Dynamic AMOLED 2X', 1),
(2, 'Процессор', 'Snapdragon 8 Gen 3', 2),
(2, 'Память', '512 ГБ', 3),
(2, 'Камера', '200 МП основная + 50 МП телефото', 4),
(2, 'Батарея', '5000 мАч', 5),
(2, 'S Pen', 'Включен', 6),

-- MacBook Pro 16" M3
(6, 'Экран', '16.2" Liquid Retina XDR', 1),
(6, 'Процессор', 'Apple M3', 2),
(6, 'Память', '512 ГБ SSD', 3),
(6, 'Оперативная память', '16 ГБ', 4),
(6, 'Графика', '10-ядерный GPU', 5),
(6, 'Порты', '3x Thunderbolt 4, HDMI, SDXC', 6);

-- Вставка отзывов
INSERT INTO product_reviews (product_id, user_id, rating, comment, is_approved) VALUES 
(1, 3, 5, 'Отличный телефон! Камера просто потрясающая.', true),
(1, 4, 4, 'Хороший телефон, но дорогой.', true),
(2, 3, 5, 'S Pen очень удобный для заметок.', true),
(6, 3, 5, 'Мощный ноутбук для работы и творчества.', true),
(6, 4, 4, 'Быстрый и тихий, но тяжелый.', true);

-- Вставка купонов
INSERT INTO coupons (code, discount_percentage, min_order_amount, usage_limit, expiration_date) VALUES 
('WELCOME10', 10.00, 5000.00, 100, '2024-12-31 23:59:59'),
('NEWUSER20', 20.00, 10000.00, 50, '2024-12-31 23:59:59'),
('SUMMER15', 15.00, 15000.00, 200, '2024-08-31 23:59:59'),
('TECH5', 5.00, 3000.00, 500, '2024-12-31 23:59:59');

-- Вставка настроек системы
INSERT INTO system_settings (setting_key, setting_value, description) VALUES 
('store_name', 'TechStore', 'Название магазина'),
('store_email', 'info@techstore.ru', 'Email магазина'),
('store_phone', '+7 (800) 555-35-35', 'Телефон магазина'),
('free_shipping_threshold', '5000.00', 'Минимальная сумма для бесплатной доставки'),
('max_cart_items', '50', 'Максимальное количество товаров в корзине'),
('session_timeout_minutes', '15', 'Таймаут сессии в минутах');

-- =====================================================
-- ПРОВЕРКА РЕЗУЛЬТАТОВ
-- =====================================================

-- Статистика по таблицам
SELECT 'Пользователи' as table_name, COUNT(*) as count FROM model_user
UNION ALL
SELECT 'Категории', COUNT(*) FROM categories
UNION ALL
SELECT 'Производители', COUNT(*) FROM manufacturers
UNION ALL
SELECT 'Товары', COUNT(*) FROM products
UNION ALL
SELECT 'Изображения', COUNT(*) FROM product_images
UNION ALL
SELECT 'Характеристики', COUNT(*) FROM product_specifications
UNION ALL
SELECT 'Отзывы', COUNT(*) FROM product_reviews
UNION ALL
SELECT 'Купоны', COUNT(*) FROM coupons;

-- Популярные товары
SELECT p.name, p.price, c.name as category, m.name as manufacturer, p.stock_quantity
FROM products p
JOIN categories c ON p.category_id = c.id
JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE p.is_featured = true
ORDER BY p.price DESC;

-- Статистика по категориям
SELECT c.name as category, COUNT(p.id) as product_count, AVG(p.price) as avg_price
FROM categories c
LEFT JOIN products p ON c.id = p.category_id AND p.is_active = true
GROUP BY c.id, c.name
ORDER BY product_count DESC;

-- =====================================================
-- ЗАВЕРШЕНИЕ
-- =====================================================

SELECT 
    'БАЗА ДАННЫХ МАГАЗИНА ЭЛЕКТРОНИКИ СОЗДАНА УСПЕШНО!' as status,
    'Все таблицы, индексы и тестовые данные добавлены' as message,
    'Можно запускать Spring Boot приложение' as next_step;

SELECT 
    'Скрипт завершен: ' || NOW() as completion_time;

