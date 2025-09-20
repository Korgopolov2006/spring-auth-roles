// =====================================================
// STORE JAVASCRIPT - TECHSTORE ELECTRONICS SHOP
// =====================================================

document.addEventListener('DOMContentLoaded', function() {
    // Инициализация
    initializeStore();
    
    // Обработчики событий
    setupEventListeners();
    
    // Обновление корзины
    updateCartCount();
});

// =====================================================
// ИНИЦИАЛИЗАЦИЯ
// =====================================================

function initializeStore() {
    // Анимация появления элементов
    animateOnScroll();
    
    // Инициализация счетчика корзины
    loadCartCount();
}

// =====================================================
// ОБРАБОТЧИКИ СОБЫТИЙ
// =====================================================

function setupEventListeners() {
    // Добавление в корзину
    document.addEventListener('click', function(e) {
        if (e.target.closest('.add-to-cart')) {
            e.preventDefault();
            const button = e.target.closest('.add-to-cart');
            const productId = button.dataset.productId;
            addToCart(productId);
        }
    });
    
    // Выпадающее меню пользователя
    document.addEventListener('click', function(e) {
        const dropdown = e.target.closest('.user-dropdown');
        const allDropdowns = document.querySelectorAll('.user-dropdown');
        
        // Закрываем все выпадающие меню
        allDropdowns.forEach(dd => {
            if (dd !== dropdown) {
                dd.classList.remove('active');
            }
        });
        
        // Переключаем текущее меню
        if (dropdown) {
            dropdown.classList.toggle('active');
        }
    });
    
    // Закрытие выпадающего меню при клике вне его
    document.addEventListener('click', function(e) {
        if (!e.target.closest('.user-dropdown')) {
            document.querySelectorAll('.user-dropdown').forEach(dropdown => {
                dropdown.classList.remove('active');
            });
        }
    });
    
    // Обновление количества в корзине
    document.addEventListener('change', function(e) {
        if (e.target.classList.contains('cart-quantity')) {
            const cartItemId = e.target.dataset.cartItemId;
            const quantity = parseInt(e.target.value);
            updateCartItem(cartItemId, quantity);
        }
    });
    
    // Удаление из корзины
    document.addEventListener('click', function(e) {
        if (e.target.closest('.remove-from-cart')) {
            e.preventDefault();
            const button = e.target.closest('.remove-from-cart');
            const cartItemId = button.dataset.cartItemId;
            removeFromCart(cartItemId);
        }
    });
    
    // Поиск товаров
    const searchInput = document.getElementById('search-input');
    if (searchInput) {
        searchInput.addEventListener('input', debounce(handleSearch, 300));
    }
    
    // Фильтры
    const filterForm = document.getElementById('filter-form');
    if (filterForm) {
        filterForm.addEventListener('change', handleFilterChange);
    }
}

// =====================================================
// КОРЗИНА
// =====================================================

function addToCart(productId, quantity = 1) {
    const button = document.querySelector(`[data-product-id="${productId}"]`);
    if (!button) return;
    
    // Показываем загрузку
    const originalText = button.innerHTML;
    button.innerHTML = '<i class="fas fa-spinner fa-spin"></i>';
    button.disabled = true;
    
    fetch('/cart/add', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: `productId=${productId}&quantity=${quantity}`
    })
    .then(response => response.text())
    .then(data => {
        if (data === 'success') {
            showNotification('Товар добавлен в корзину!', 'success');
            updateCartCount();
        } else {
            showNotification('Ошибка при добавлении товара', 'error');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showNotification('Ошибка при добавлении товара', 'error');
    })
    .finally(() => {
        // Восстанавливаем кнопку
        button.innerHTML = originalText;
        button.disabled = false;
    });
}

function updateCartItem(cartItemId, quantity) {
    fetch('/cart/update', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: `cartItemId=${cartItemId}&quantity=${quantity}`
    })
    .then(response => response.text())
    .then(data => {
        if (data === 'success') {
            updateCartCount();
            updateCartTotal();
        } else {
            showNotification('Ошибка при обновлении корзины', 'error');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showNotification('Ошибка при обновлении корзины', 'error');
    });
}

function removeFromCart(cartItemId) {
    if (!confirm('Удалить товар из корзины?')) return;
    
    fetch('/cart/remove', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: `cartItemId=${cartItemId}`
    })
    .then(response => response.text())
    .then(data => {
        if (data === 'success') {
            showNotification('Товар удален из корзины', 'success');
            updateCartCount();
            // Удаляем элемент из DOM
            const cartItem = document.querySelector(`[data-cart-item-id="${cartItemId}"]`);
            if (cartItem) {
                cartItem.remove();
                updateCartTotal();
            }
        } else {
            showNotification('Ошибка при удалении товара', 'error');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showNotification('Ошибка при удалении товара', 'error');
    });
}

function updateCartCount() {
    fetch('/cart/count')
    .then(response => response.text())
    .then(count => {
        const cartCount = document.querySelector('.cart-count');
        if (cartCount) {
            cartCount.textContent = count;
        }
    })
    .catch(error => {
        console.error('Error updating cart count:', error);
    });
}

function loadCartCount() {
    updateCartCount();
}

function updateCartTotal() {
    const cartItems = document.querySelectorAll('.cart-item');
    let total = 0;
    
    cartItems.forEach(item => {
        const price = parseFloat(item.dataset.price);
        const quantity = parseInt(item.querySelector('.cart-quantity').value);
        total += price * quantity;
    });
    
    const totalElement = document.querySelector('.cart-total');
    if (totalElement) {
        totalElement.textContent = formatPrice(total);
    }
}

// =====================================================
// ПОИСК И ФИЛЬТРЫ
// =====================================================

function handleSearch(e) {
    const query = e.target.value;
    if (query.length < 2) return;
    
    // Перенаправляем на страницу каталога с поисковым запросом
    window.location.href = `/catalog?search=${encodeURIComponent(query)}`;
}

function handleFilterChange(e) {
    const form = e.target.closest('form');
    const formData = new FormData(form);
    const params = new URLSearchParams();
    
    for (let [key, value] of formData.entries()) {
        if (value) {
            params.append(key, value);
        }
    }
    
    window.location.href = `/catalog?${params.toString()}`;
}

// =====================================================
// АНИМАЦИИ
// =====================================================

function animateOnScroll() {
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('animate-in');
            }
        });
    }, {
        threshold: 0.1
    });
    
    document.querySelectorAll('.product-card, .category-card, .feature-item').forEach(el => {
        observer.observe(el);
    });
}

// =====================================================
// УТИЛИТЫ
// =====================================================

function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

function formatPrice(price) {
    return new Intl.NumberFormat('ru-RU', {
        style: 'currency',
        currency: 'RUB',
        minimumFractionDigits: 0
    }).format(price);
}

function showNotification(message, type = 'info') {
    // Создаем уведомление
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.innerHTML = `
        <div class="notification-content">
            <i class="fas fa-${getNotificationIcon(type)}"></i>
            <span>${message}</span>
        </div>
    `;
    
    // Добавляем стили
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: ${getNotificationColor(type)};
        color: white;
        padding: 1rem 1.5rem;
        border-radius: 8px;
        box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);
        z-index: 1000;
        transform: translateX(100%);
        transition: transform 0.3s ease;
    `;
    
    document.body.appendChild(notification);
    
    // Анимация появления
    setTimeout(() => {
        notification.style.transform = 'translateX(0)';
    }, 100);
    
    // Удаляем через 3 секунды
    setTimeout(() => {
        notification.style.transform = 'translateX(100%)';
        setTimeout(() => {
            if (notification.parentNode) {
                notification.parentNode.removeChild(notification);
            }
        }, 300);
    }, 3000);
}

function getNotificationIcon(type) {
    const icons = {
        success: 'check-circle',
        error: 'exclamation-circle',
        warning: 'exclamation-triangle',
        info: 'info-circle'
    };
    return icons[type] || 'info-circle';
}

function getNotificationColor(type) {
    const colors = {
        success: '#10b981',
        error: '#ef4444',
        warning: '#f59e0b',
        info: '#3b82f6'
    };
    return colors[type] || '#3b82f6';
}

// =====================================================
// ДОПОЛНИТЕЛЬНЫЕ ФУНКЦИИ
// =====================================================

// Плавная прокрутка к якорям
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        }
    });
});

// Обработка форм
document.querySelectorAll('form').forEach(form => {
    form.addEventListener('submit', function(e) {
        const submitButton = form.querySelector('button[type="submit"]');
        if (submitButton) {
            submitButton.disabled = true;
            submitButton.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Загрузка...';
        }
    });
});

// Инициализация tooltips
document.querySelectorAll('[data-tooltip]').forEach(element => {
    element.addEventListener('mouseenter', function() {
        const tooltip = document.createElement('div');
        tooltip.className = 'tooltip';
        tooltip.textContent = this.dataset.tooltip;
        tooltip.style.cssText = `
            position: absolute;
            background: #1e293b;
            color: white;
            padding: 0.5rem 0.75rem;
            border-radius: 4px;
            font-size: 0.875rem;
            z-index: 1000;
            pointer-events: none;
        `;
        document.body.appendChild(tooltip);
        
        const rect = this.getBoundingClientRect();
        tooltip.style.left = rect.left + 'px';
        tooltip.style.top = (rect.top - tooltip.offsetHeight - 5) + 'px';
        
        this._tooltip = tooltip;
    });
    
    element.addEventListener('mouseleave', function() {
        if (this._tooltip) {
            this._tooltip.remove();
            this._tooltip = null;
        }
    });
});

