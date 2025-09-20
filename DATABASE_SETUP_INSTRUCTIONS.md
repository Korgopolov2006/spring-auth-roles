# Инструкции по настройке базы данных для TechStore

## 🚀 Быстрый старт

### 1. Подготовка базы данных
```bash
# Подключитесь к PostgreSQL
psql -U postgres

# Создайте базу данных (если не существует)
CREATE DATABASE YP4SpringAuthorizathion;

# Выйдите из psql
\q
```

### 2. Выполнение скрипта
```bash
# Выполните полный скрипт создания и заполнения базы данных
psql -U postgres -d YP4SpringAuthorizathion -f electronics_store_database.sql
```

### 3. Проверка результата
```bash
# Подключитесь к базе данных
psql -U postgres -d YP4SpringAuthorizathion

# Проверьте созданные таблицы
\dt

# Проверьте количество записей
SELECT 'Пользователи' as table_name, COUNT(*) as count FROM model_user
UNION ALL
SELECT 'Товары', COUNT(*) FROM products
UNION ALL
SELECT 'Категории', COUNT(*) FROM categories;

# Выйдите из psql
\q
```

## 📊 Что создается в базе данных

### Таблицы:
- ✅ **model_user** - пользователи системы
- ✅ **user_role** - роли пользователей  
- ✅ **categories** - категории товаров
- ✅ **manufacturers** - производители
- ✅ **products** - товары
- ✅ **product_images** - изображения товаров
- ✅ **product_specifications** - характеристики товаров
- ✅ **product_reviews** - отзывы о товарах
- ✅ **cart_items** - корзина покупок
- ✅ **orders** - заказы
- ✅ **order_items** - элементы заказов
- ✅ **coupons** - промокоды
- ✅ **user_activity_log** - журнал активности
- ✅ **system_settings** - настройки системы

### Тестовые данные:
- 👤 **4 пользователя** (admin, moderator, user, test)
- 🏷️ **13 категорий** товаров
- 🏭 **8 производителей** (Apple, Samsung, Xiaomi, ASUS, Sony, Microsoft, Huawei, OnePlus)
- 📱 **20+ товаров** (смартфоны, ноутбуки, планшеты, наушники, игровые устройства)
- 🖼️ **10 изображений** товаров
- ⭐ **5 отзывов** о товарах
- 🎫 **4 промокода** для скидок
- ⚙️ **6 настроек** системы

## 🔑 Тестовые пользователи

| Пользователь | Пароль | Роль | Доступ |
|-------------|--------|------|--------|
| **admin** | password123 | ADMIN | Полный доступ |
| **moderator** | password123 | MODERATOR | Управление товарами |
| **user** | password123 | USER | Покупки |
| **test** | password123 | USER | Покупки |

## 🛒 Тестовые товары

### Смартфоны:
- iPhone 15 Pro (99,999 ₽)
- Samsung Galaxy S24 Ultra (89,999 ₽)
- Xiaomi 14 Pro (59,999 ₽)
- iPhone 14 (69,999 ₽)
- Samsung Galaxy A54 (29,999 ₽)

### Ноутбуки:
- MacBook Pro 16" M3 (199,999 ₽)
- ASUS ROG Strix G16 (129,999 ₽)
- MacBook Air 13" M2 (99,999 ₽)
- ASUS VivoBook S15 (49,999 ₽)

### Планшеты:
- iPad Pro 12.9" M2 (89,999 ₽)
- Samsung Galaxy Tab S9 (59,999 ₽)
- iPad Air 5 (49,999 ₽)

### Наушники:
- AirPods Pro 2 (19,999 ₽)
- Sony WH-1000XM5 (24,999 ₽)
- Samsung Galaxy Buds2 Pro (14,999 ₽)

### Игровые устройства:
- PlayStation 5 (49,999 ₽)
- Xbox Series X (45,999 ₽)
- Nintendo Switch OLED (29,999 ₽)

## 🎫 Промокоды

| Код | Скидка | Мин. сумма | Лимит использований |
|-----|--------|------------|-------------------|
| **WELCOME10** | 10% | 5,000 ₽ | 100 |
| **NEWUSER20** | 20% | 10,000 ₽ | 50 |
| **SUMMER15** | 15% | 15,000 ₽ | 200 |
| **TECH5** | 5% | 3,000 ₽ | 500 |

## ⚠️ Важные замечания

1. **Пароли закодированы** с помощью BCrypt
2. **Все товары активны** и доступны для покупки
3. **Изображения** используют заглушки (placeholder.jpg)
4. **Цены** указаны в рублях
5. **Складские остатки** настроены для тестирования

## 🔧 Настройка приложения

После выполнения скрипта убедитесь, что в `application.yml` правильно настроено подключение:

```yaml
spring:
    datasource:
        url: jdbc:postgresql://localhost:5432/YP4SpringAuthorizathion
        username: postgres
        password: 1  # Измените на ваш пароль
```

## 🚀 Запуск приложения

```bash
# Компиляция
.\mvnw.cmd compile

# Запуск
.\mvnw.cmd spring-boot:run
```

## 🌐 Доступ к приложению

- **Главная страница**: http://localhost:8080
- **Каталог товаров**: http://localhost:8080/catalog
- **Корзина**: http://localhost:8080/cart
- **Вход в систему**: http://localhost:8080/login
- **Регистрация**: http://localhost:8080/registration

## 📞 Поддержка

Если возникли проблемы:
1. Проверьте, что PostgreSQL запущен
2. Убедитесь, что база данных создана
3. Проверьте права доступа пользователя postgres
4. Посмотрите логи приложения

---

**Готово!** Ваш магазин электроники TechStore готов к работе! 🛒✨

