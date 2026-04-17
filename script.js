document.addEventListener('DOMContentLoaded', () => {
    // Navbar Scroll Effect
    const navbar = document.getElementById('navbar');
    window.addEventListener('scroll', () => {
        if (window.scrollY > 50) {
            navbar.classList.add('scrolled');
        } else {
            navbar.classList.remove('scrolled');
        }
    });

    // Theme Toggle
    const themeToggle = document.getElementById('theme-toggle');
    const sunIcon = document.getElementById('sun-icon');
    const moonIcon = document.getElementById('moon-icon');
    const body = document.body;

    // Check for saved theme
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
        
        if (theme === 'dark') {
            sunIcon.style.display = 'block';
            moonIcon.style.display = 'none';
        } else {
            sunIcon.style.display = 'none';
            moonIcon.style.display = 'block';
        }
    }

    // Stats Counter Animation
    const statCards = document.querySelectorAll('.stat-card');
    
    const startCount = (el) => {
        const numEl = el.querySelector('.stat-number');
        if (!numEl) return;
        const target = parseInt(numEl.getAttribute('data-target'));
        let count = 0;
        const duration = 2000;
        const startTime = performance.now();

        const updateCount = (timestamp) => {
            const elapsed = timestamp - startTime;
            const progress = Math.min(elapsed / duration, 1);
            
            count = Math.floor(progress * target);
            numEl.innerText = count + (target === 24 ? "/7" : "+");

            if (progress < 1) {
                requestAnimationFrame(updateCount);
            } else {
                numEl.innerText = target + (target === 24 ? "/7" : "+");
            }
        };
        requestAnimationFrame(updateCount);
    };

    const statsObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                startCount(entry.target);
                statsObserver.unobserve(entry.target);
            }
        });
    }, { threshold: 0.1 });

    statCards.forEach(card => statsObserver.observe(card));

    // Reveal on Scroll Animation
    const revealElements = document.querySelectorAll('.reveal');
    const revealObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('active');
            }
        });
    }, {
        threshold: 0.1
    });

    revealElements.forEach(el => revealObserver.observe(el));

    // Active Link Highlighting
    const sections = document.querySelectorAll('section');
    const navLinks = document.querySelectorAll('.navbar-link');

    window.addEventListener('scroll', () => {
        let current = '';
        sections.forEach(section => {
            const sectionTop = section.offsetTop;
            const sectionHeight = section.clientHeight;
            if (window.pageYOffset >= (sectionTop - 200)) {
                current = section.getAttribute('id');
            }
        });

        navLinks.forEach(link => {
            link.classList.remove('active');
            if (link.getAttribute('href').includes(current)) {
                link.classList.add('active');
            }
        });
    });

    // Contact Form Handling (Formspree Integration)
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
                    headers: {
                        'Accept': 'application/json'
                    }
                });

                if (response.ok) {
                    btn.innerHTML = 'Message Sent! <i class="bi bi-check2"></i>';
                    btn.style.backgroundColor = '#10b981'; // Success Green
                    contactForm.reset();
                    
                    setTimeout(() => {
                        btn.innerHTML = originalText;
                        btn.style.backgroundColor = '';
                        btn.disabled = false;
                    }, 5000);
                } else {
                    const data = await response.json();
                    throw new Error(data.error || 'Submission failed');
                }
            } catch (error) {
                btn.innerHTML = 'Error Sending <i class="bi bi-exclamation-triangle"></i>';
                btn.style.backgroundColor = '#ef4444'; // Error Red
                
                setTimeout(() => {
                    btn.innerHTML = originalText;
                    btn.style.backgroundColor = '';
                    btn.disabled = false;
                }, 5000);
            }
        });
    }

    // Project Slider Logic
    const sliderContainers = document.querySelectorAll('.portfolio-slider-container');
    sliderContainers.forEach(container => {
        const images = container.querySelectorAll('.slider-img');
        const dots = container.querySelectorAll('.slider-dot');
        let currentIndex = 0;

        if (images.length > 1) {
            setInterval(() => {
                // Remove active from current
                images[currentIndex].classList.remove('active');
                dots[currentIndex].classList.remove('active');

                // Update index
                currentIndex = (currentIndex + 1) % images.length;

                // Add active to new
                images[currentIndex].classList.add('active');
                dots[currentIndex].classList.add('active');
            }, 3000); // Change image every 3 seconds
        }
    });

    // Mobile Menu Toggle
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
});
