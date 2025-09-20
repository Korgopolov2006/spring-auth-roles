# ИНСТРУКЦИЯ ПО ЗАПУСКУ СКРИПТА СОЗДАНИЯ БАЗЫ ДАННЫХ

## Способ 1: Через PowerShell (рекомендуется)

1. Откройте PowerShell от имени администратора
2. Перейдите в папку проекта:
   ```powershell
   cd "C:\Users\1\Downloads\SpringSecRoles (2)\SpringSecRoles"
   ```

3. Запустите скрипт:
   ```powershell
   psql -U postgres -f full_database_setup.sql
   ```

4. Если запрашивает пароль, введите пароль пользователя postgres (или оставьте пустым)

## Способ 2: Через командную строку

1. Откройте командную строку от имени администратора
2. Перейдите в папку проекта:
   ```cmd
   cd "C:\Users\1\Downloads\SpringSecRoles (2)\SpringSecRoles"
   ```

3. Запустите скрипт:
   ```cmd
   psql -U postgres -f full_database_setup.sql
   ```

## Способ 3: Через pgAdmin (графический интерфейс)

1. Откройте pgAdmin
2. Подключитесь к серверу PostgreSQL
3. Щелкните правой кнопкой мыши на базе данных postgres
4. Выберите "Query Tool"
5. Откройте файл full_database_setup.sql
6. Нажмите F5 или кнопку "Execute"

## Что делает скрипт:

✅ Создает базу данных spring_security_db
✅ Создает пользователя postgres с паролем postgres
✅ Создает таблицы model_user и user_role
✅ Создает необходимые индексы
✅ Заполняет тестовыми данными
✅ Показывает результат выполнения

## Тестовые пользователи после выполнения:

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

1. Убедитесь, что PostgreSQL запущен:
   ```powershell
   Get-Service -Name "*postgres*"
   ```

2. Если PostgreSQL не запущен:
   ```powershell
   Start-Service postgresql-x64-13
   ```

3. Проверьте подключение:
   ```powershell
   psql -U postgres -c "\l"
   ```
