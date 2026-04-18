/**
 * Global App Logic for HEXJIN TECH (MPA Version)
 */

document.addEventListener('DOMContentLoaded', () => {
    // 1. Initial Page Scan
    console.log("HEXJIN Tech App Initialized");
    initPageScripts();

    // 2. Navbar Scroll Effect
    const navbar = document.getElementById('navbar');
    if (navbar) {
        window.addEventListener('scroll', () => {
            if (window.scrollY > 50) {
                navbar.classList.add('scrolled');
            } else {
                navbar.classList.remove('scrolled');
            }
        });
    }

    // 3. Theme Toggle Logic
    const themeToggle = document.getElementById('theme-toggle');
    const sunIcon = document.getElementById('sun-icon');
    const moonIcon = document.getElementById('moon-icon');
    const body = document.body;

    const savedTheme = localStorage.getItem('theme') || 'dark';
    setTheme(savedTheme);

    if (themeToggle) {
        themeToggle.addEventListener('click', () => {
            const currentTheme = body.getAttribute('data-theme');
            const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
            setTheme(newTheme);
        });
    }

    function setTheme(theme) {
        body.setAttribute('data-theme', theme);
        localStorage.setItem('theme', theme);
        if (sunIcon && moonIcon) {
            if (theme === 'dark') {
                sunIcon.style.display = 'block';
                moonIcon.style.display = 'none';
            } else {
                sunIcon.style.display = 'none';
                moonIcon.style.display = 'block';
            }
        }
    }

    // 4. Mobile Menu Toggle
    const mobileMenuBtn = document.querySelector('.navbar-mobile-btn');
    const navLinksList = document.querySelector('.navbar-links');
    
    if (mobileMenuBtn && navLinksList) {
        mobileMenuBtn.addEventListener('click', () => {
            navLinksList.classList.toggle('mobile-active');
            const icon = mobileMenuBtn.querySelector('i');
            if (navLinksList.classList.contains('mobile-active')) {
                icon.className = 'bi bi-x-lg';
            } else {
                icon.className = 'bi bi-list';
            }
        });
    }

    // 5. Page Scripts Initialization
    function initPageScripts() {
        // Stats Counter
        const statCards = document.querySelectorAll('.stat-card');
        const statsObserver = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    startCount(entry.target);
                    statsObserver.unobserve(entry.target);
                }
            });
        }, { threshold: 0.1 });
        statCards.forEach(card => statsObserver.observe(card));

        // Reveal animations
        const revealElements = document.querySelectorAll('.reveal');
        const revealObserver = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('active');
                }
            });
        }, { threshold: 0.1 });
        revealElements.forEach(el => revealObserver.observe(el));

        // Portfolio Slider
        const sliderContainers = document.querySelectorAll('.portfolio-slider-container');
        sliderContainers.forEach(container => {
            const images = container.querySelectorAll('.slider-img');
            const dots = container.querySelectorAll('.slider-dot');
            let currentIndex = 0;
            if (images.length > 1) {
                setInterval(() => {
                    images[currentIndex].classList.remove('active');
                    if (dots[currentIndex]) dots[currentIndex].classList.remove('active');
                    currentIndex = (currentIndex + 1) % images.length;
                    images[currentIndex].classList.add('active');
                    if (dots[currentIndex]) dots[currentIndex].classList.add('active');
                }, 3000);
            }
        });

        // Contact Form
        initContactForm();
        
        // Portfolio Filters
        initPortfolioFilters();
    }

    function startCount(el) {
        const numEl = el.querySelector('.stat-number');
        if (!numEl) return;
        const targetAttr = numEl.getAttribute('data-target');
        if (!targetAttr) return;
        const target = parseInt(targetAttr);
        let count = 0;
        const duration = 2000;
        const startTime = performance.now();

        const updateCount = (timestamp) => {
            const elapsed = timestamp - startTime;
            const progress = Math.min(elapsed / duration, 1);
            count = Math.floor(progress * target);
            numEl.innerText = count + (target === 24 ? "/7" : "+");
            if (progress < 1) requestAnimationFrame(updateCount);
            else numEl.innerText = target + (target === 24 ? "/7" : "+");
        };
        requestAnimationFrame(updateCount);
    }

    function initContactForm() {
        const contactForm = document.querySelector('.contact-form');
        if (contactForm) {
            contactForm.addEventListener('submit', async (e) => {
                e.preventDefault();
                const btn = contactForm.querySelector('.btn-contact-submit');
                const originalText = btn.innerHTML;
                const formData = new FormData(contactForm);
                btn.innerHTML = 'Sending...';
                btn.disabled = true;
                try {
                    const response = await fetch(contactForm.action, {
                        method: contactForm.method,
                        body: formData,
                        headers: { 'Accept': 'application/json' }
                    });
                    if (response.ok) {
                        btn.innerHTML = 'Sent! <i class="bi bi-check2"></i>';
                        btn.style.backgroundColor = '#10b981';
                        contactForm.reset();
                        setTimeout(() => {
                            btn.innerHTML = originalText;
                            btn.style.backgroundColor = '';
                            btn.disabled = false;
                        }, 5000);
                    } else { throw new Error('Fail'); }
                } catch (error) {
                    btn.innerHTML = 'Error <i class="bi bi-exclamation-triangle"></i>';
                    btn.style.backgroundColor = '#ef4444';
                    setTimeout(() => {
                        btn.innerHTML = originalText;
                        btn.style.backgroundColor = '';
                        btn.disabled = false;
                    }, 5000);
                }
            });
        }
    }

    function initPortfolioFilters() {
        const filterBtns = document.querySelectorAll('[data-filter]');
        const items = document.querySelectorAll('.portfolio-item');
        
        filterBtns.forEach(btn => {
            btn.addEventListener('click', () => {
                const filter = btn.getAttribute('data-filter');
                filterBtns.forEach(b => b.classList.remove('active-filter'));
                btn.classList.add('active-filter');
                
                items.forEach(item => {
                    if (filter === 'all' || item.getAttribute('data-category') === filter) {
                        item.style.display = 'block';
                        setTimeout(() => item.style.opacity = '1', 10);
                    } else {
                        item.style.opacity = '0';
                        setTimeout(() => item.style.display = 'none', 300);
                    }
                });
            });
        });
    }
});
