# ИНСТРУКЦИЯ ПО ЗАПОЛНЕНИЮ СУЩЕСТВУЮЩЕЙ БАЗЫ ДАННЫХ

## Ваша база данных: YP4SpringAuthorizathion

### Способ 1: Через PowerShell (рекомендуется)

1. Откройте PowerShell от имени администратора
2. Перейдите в папку проекта:
   ```powershell
   cd "C:\Users\1\Downloads\SpringSecRoles (2)\SpringSecRoles"
   ```

3. Запустите скрипт заполнения:
   ```powershell
   psql -U postgres -d YP4SpringAuthorizathion -f fill_existing_database.sql
   ```

4. Введите пароль для пользователя postgres (123456789)

### Способ 2: Через командную строку

1. Откройте командную строку от имени администратора
2. Перейдите в папку проекта:
   ```cmd
   cd "C:\Users\1\Downloads\SpringSecRoles (2)\SpringSecRoles"
   ```

3. Запустите скрипт:
   ```cmd
   psql -U postgres -d YP4SpringAuthorizathion -f fill_existing_database.sql
   ```

### Способ 3: Через pgAdmin

1. Откройте pgAdmin
2. Подключитесь к серверу PostgreSQL
3. Найдите базу данных YP4SpringAuthorizathion
4. Щелкните правой кнопкой мыши на ней
5. Выберите "Query Tool"
6. Откройте файл fill_existing_database.sql
7. Нажмите F5 или кнопку "Execute"

## Что делает скрипт:

✅ Подключается к существующей базе данных YP4SpringAuthorizathion
✅ Создает таблицы model_user и user_role (если их нет)
✅ Создает необходимые индексы
✅ Заполняет тестовыми данными (только если таблицы пустые)
✅ Показывает результат выполнения

## Тестовые пользователи:

| Username | Password | Roles |
|----------|----------|-------|
| admin    | admin    | ADMIN, USER |
| user     | user     | USER |
| test     | test     | USER |
| manager  | manager  | USER |

## После выполнения скрипта:

1. Запустите Spring Boot приложение
2. Откройте браузер: http://localhost:8080
3. Попробуйте войти с любым из тестовых пользователей

## Если возникли проблемы:

1. Проверьте подключение к базе данных:
   ```powershell
   psql -U postgres -d YP4SpringAuthorizathion -c "\dt"
   ```

2. Если таблицы уже существуют, скрипт не будет их пересоздавать
3. Если данные уже есть, скрипт покажет количество существующих записей
