/**
 * Global App Logic for HEXJIN TECH (MPA Version)
 */

document.addEventListener('DOMContentLoaded', () => {
    initPageScripts();
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
        // Hero Title Animation
        const heroTitle = document.querySelector('.hero-title');
        if (heroTitle && !heroTitle.classList.contains('title-animate')) {
            const text = heroTitle.innerText.trim();
            if (text) {
                heroTitle.innerHTML = text.split(' ').map(word => 
                    `<span class="word">${word.split('').map(char => `<span class="char">${char}</span>`).join('')}</span>`
                ).join(' ');
                
                // Use a slightly larger delay to ensure DOM is ready before animating
                setTimeout(() => {
                    heroTitle.classList.add('title-animate');
                }, 300);
            }
        }

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

        // Enhanced Reveal animations with Staggering
        const revealElements = document.querySelectorAll('.reveal');
        const staggerContainers = document.querySelectorAll('.stagger-reveal');

        // Apply staggering to containers
        staggerContainers.forEach(container => {
            const children = container.querySelectorAll('.reveal');
            children.forEach((child, index) => {
                child.style.transitionDelay = `${index * 0.15}s`;
            });
        });

        window.revealObserver = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('active');
                    // We don't unobserve to allow reveal on re-scroll if desired, 
                    // but usually once is enough.
                    // window.revealObserver.unobserve(entry.target);
                }
            });
        }, { 
            threshold: 0.15,
            rootMargin: '0px 0px -50px 0px' 
        });
        
        revealElements.forEach(el => window.revealObserver.observe(el));

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

        // Initialize Cursor
        initCustomCursor();
    }

    function initCustomCursor() {
        const follower = document.querySelector('.cursor-follower');
        const outline = document.querySelector('.cursor-outline');
        
        if (!follower || !outline) return;

        // Only show on desktop
        if (window.innerWidth < 1024) return;

        follower.style.display = 'block';
        outline.style.display = 'block';

        let mouseX = 0, mouseY = 0;
        let followerX = 0, followerY = 0;
        let outlineX = 0, outlineY = 0;

        window.addEventListener('mousemove', (e) => {
            mouseX = e.clientX;
            mouseY = e.clientY;
        });

        const animate = () => {
            // Smoothly move follower
            followerX += (mouseX - followerX) * 0.2;
            followerY += (mouseY - followerY) * 0.2;
            follower.style.transform = `translate3d(${followerX - 10}px, ${followerY - 10}px, 0)`;

            // Smoothly move outline
            outlineX += (mouseX - outlineX) * 0.1;
            outlineY += (mouseY - outlineY) * 0.1;
            outline.style.transform = `translate3d(${outlineX - 20}px, ${outlineY - 20}px, 0)`;

            requestAnimationFrame(animate);
        };
        animate();

        // Hover effect on interactive elements
        const hoverables = document.querySelectorAll('a, button, .services-card, .portfolio-card, .stat-card, input, textarea');
        hoverables.forEach(el => {
            el.addEventListener('mouseenter', () => {
                outline.style.width = '60px';
                outline.style.height = '60px';
                outline.style.transform = `translate3d(${outlineX - 30}px, ${outlineY - 30}px, 0)`;
                outline.style.backgroundColor = 'rgba(59, 130, 246, 0.1)';
                follower.style.transform = `translate3d(${followerX - 10}px, ${followerY - 10}px, 0) scale(0.5)`;
            });
            el.addEventListener('mouseleave', () => {
                outline.style.width = '40px';
                outline.style.height = '40px';
                outline.style.backgroundColor = 'transparent';
                follower.style.transform = `translate3d(${followerX - 10}px, ${followerY - 10}px, 0) scale(1)`;
            });
        });
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
