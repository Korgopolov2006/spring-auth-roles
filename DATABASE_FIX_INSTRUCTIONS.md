# 🔧 Инструкции по исправлению базы данных

## ❌ **Проблемы, которые нужно исправить:**

### 1. **Ошибки миграции Hibernate**
Hibernate пытается добавить новые поля в существующие таблицы, но они уже содержат NULL значения.

### 2. **Ошибка в CategoryRepository**
В запросе `findCategoriesWithProducts()` используется несуществующее поле `products` в модели `Category`.

## ✅ **Решение:**

### **Шаг 1: Выполните скрипт исправления базы данных**

```bash
# Подключитесь к PostgreSQL
psql -U postgres -d YP4SpringAuthorizathion

# Выполните скрипт исправления
\i fix_database_migration.sql
```

### **Шаг 2: Альтернативное решение - пересоздание базы данных**

Если первый способ не сработает, выполните:

```bash
# 1. Удалите существующую базу данных
psql -U postgres -c "DROP DATABASE IF EXISTS YP4SpringAuthorizathion;"

# 2. Создайте новую базу данных
psql -U postgres -c "CREATE DATABASE YP4SpringAuthorizathion;"

# 3. Выполните основной скрипт создания
psql -U postgres -d YP4SpringAuthorizathion -f electronics_store_database.sql
```

### **Шаг 3: Проверьте исправления**

После выполнения скриптов:

1. **Запустите приложение:**
   ```bash
   .\mvnw.cmd spring-boot:run
   ```

2. **Проверьте доступ к админ-панели:**
   - URL: http://localhost:8080/login
   - Логин: `admin`
   - Пароль: `admin`

## 🔍 **Что исправляет скрипт:**

### **1. Таблица `coupons`:**
- Добавляет поля `discount_type`, `discount_value`, `name`
- Заполняет существующие записи значениями по умолчанию
- Делает поля NOT NULL после заполнения

### **2. Таблица `product_specifications`:**
- Добавляет поля `spec_name`, `spec_value`
- Заполняет существующие записи значениями по умолчанию
- Делает поля NOT NULL после заполнения

### **3. Другие таблицы:**
- Добавляет недостающие поля в `orders`, `order_items`, `product_reviews`, `cart_items`
- Обновляет существующие записи значениями по умолчанию
- Создает индексы для производительности

### **4. Исправление CategoryRepository:**
- Заменяет неправильный JOIN на EXISTS подзапрос
- Устраняет ошибку "could not resolve property: products"

## 🚨 **Если проблемы продолжаются:**

### **Вариант 1: Отключите автоматическую миграцию**
В `application.yml` измените:
```yaml
spring:
  jpa:
    hibernate:
      ddl-auto: validate  # вместо update
```

### **Вариант 2: Используйте create-drop для разработки**
```yaml
spring:
  jpa:
    hibernate:
      ddl-auto: create-drop  # пересоздает таблицы при каждом запуске
```

### **Вариант 3: Ручная миграция**
1. Сделайте бэкап данных
2. Удалите проблемные таблицы
3. Запустите приложение для создания новых таблиц
4. Восстановите данные

## 📋 **Проверочный список:**

- [ ] Выполнен скрипт `fix_database_migration.sql`
- [ ] Исправлен `CategoryRepository.java`
- [ ] Приложение запускается без ошибок
- [ ] Доступ к админ-панели работает
- [ ] Все CRUD операции функционируют

## 🆘 **Если ничего не помогает:**

1. **Полная переустановка:**
   ```bash
   # Удалите базу данных
   psql -U postgres -c "DROP DATABASE IF EXISTS YP4SpringAuthorizathion;"
   
   # Создайте новую
   psql -U postgres -c "CREATE DATABASE YP4SpringAuthorizathion;"
   
   # Выполните основной скрипт
   psql -U postgres -d YP4SpringAuthorizathion -f electronics_store_database.sql
   
   # Запустите приложение
   .\mvnw.cmd spring-boot:run
   ```

2. **Проверьте логи приложения** на наличие других ошибок

3. **Убедитесь, что PostgreSQL запущен** и доступен

---

**После исправления админ-панель должна работать полностью!** 🛡️✨

