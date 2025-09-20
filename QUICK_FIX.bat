@echo off
echo ========================================
echo    БЫСТРОЕ ИСПРАВЛЕНИЕ ПРОЕКТА
echo ========================================
echo.

echo [1/3] Исправляем базу данных...
psql -U postgres -d YP4SpringAuthorizathion -f fix_database_issues.sql
if %errorlevel% neq 0 (
    echo ОШИБКА: Не удалось исправить базу данных
    echo Попробуйте выполнить команды вручную:
    echo psql -U postgres -d YP4SpringAuthorizathion -f fix_database_issues.sql
    pause
    exit /b 1
)

echo [2/3] База данных исправлена успешно!
echo.

echo [3/3] Запускаем приложение...
.\mvnw.cmd spring-boot:run

echo.
echo ========================================
echo    ИСПРАВЛЕНИЕ ЗАВЕРШЕНО!
echo ========================================
echo.
echo Админ-панель доступна по адресу:
echo http://localhost:8080/login
echo.
echo Логин: admin
echo Пароль: admin
echo.
pause

