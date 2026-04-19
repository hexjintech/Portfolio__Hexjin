(() => {
    const initNavbar = () => {
        if (window.navbarInitialized) return;

        const placeholder = document.getElementById('navbar-placeholder');
        if (!placeholder) return;

        const path = window.location.pathname.replace(/\\/g, '/');
        const segments = path.split('/').filter(s => s.length > 0);
        const subfolders = ['about', 'serviceslinks', 'portfolio', 'contact', 'case-study-template'];
        const currentSubfolder = subfolders.find(s => {
            return segments.some(seg => seg.toLowerCase() === s.toLowerCase());
        });

        const isSubfolder = !!currentSubfolder;
        const isNested = path.toLowerCase().includes('/case-study-template/');
        const finalBase = isNested ? '../../' : (isSubfolder ? '../' : '');

        console.log('[Navbar] Initializing...', { path, currentSubfolder, finalBase });
        const getActive = (name) => {
            if (name === 'home') {
                return !isSubfolder ? 'active' : '';
            }
            return (currentSubfolder === name) ? 'active' : '';
        };

        const navbarHTML = `
        <!-- Navigation Backdrop -->
        <div class="nav-backdrop"></div>

        <nav id="navbar" class="fixed-top">
            <div class="container navbar-container">
                <div class="row align-items-center">
                    <div class="col-4">
                        <a href="${finalBase}index.html" class="navbar-logo">
                            <img src="${finalBase}assets/images/logo.jpeg" alt="logo">
                            HEXJIN<span>TECH</span>
                        </a>
                    </div>
                    <div class="col-8 d-flex justify-content-end align-items-center">
                        <div class="navbar-links mb-0 align-items-start align-items-lg-center">
                            <div class="drawer-header d-lg-none">
                                <a href="${finalBase}index.html" class="navbar-logo">
                                    HEXJIN<span>TECH</span>
                                </a>
                                <button class="drawer-close border-0 bg-transparent">
                                    <i class="bi bi-x-lg"></i>
                                </button>
                            </div>

                            <ul class="nav-list d-lg-flex mb-0 list-unstyled align-items-start align-items-lg-center">
                                <li><a href="${finalBase}index.html" class="navbar-link ${getActive('home')}">Home</a></li>
                                <li><a href="${finalBase}about/index.html" class="navbar-link ${getActive('about')}">About</a></li>
                                <li><a href="${finalBase}services/index.html" class="navbar-link ${getActive('services')}">Services</a></li>
                                <li><a href="${finalBase}portfolio/index.html" class="navbar-link ${getActive('portfolio')}">Portfolio</a></li>
                                <li><a href="${finalBase}index.html#faq" class="navbar-link">FAQ</a></li>
                                <li><a href="${finalBase}contact/index.html" class="navbar-link ${getActive('contact')}">Contact</a></li>
                            </ul>

                            <div class="drawer-footer d-lg-none">
                                <p class="small opacity-50 mb-3">Follow our journey</p>
                                <div class="d-flex gap-3 mb-4">
                                    <a href="#" class="social-icon"><i class="bi bi-github"></i></a>
                                    <a href="#" class="social-icon"><i class="bi bi-linkedin"></i></a>
                                    <a href="#" class="social-icon"><i class="bi bi-twitter-x"></i></a>
                                </div>
                                <a href="${finalBase}contact/index.html" class="btn-hero-primary w-100 justify-content-center">Start a Project</a>
                            </div>
                        </div>
                        <div class="navbar-actions ms-lg-4 d-flex align-items-center gap-3">
                            <button id="theme-nav-toggle" class="btn-theme-toggle border-0 bg-transparent"
                                aria-label="Toggle Theme">
                                <i class="bi bi-sun sun-icon"></i>
                                <i class="bi bi-moon moon-icon" style="display: none;"></i>
                            </button>
                            <a href="${finalBase}contact/index.html" class="btn-hire ms-3 d-none d-sm-inline-block">Hire Me</a>
                            <button class="navbar-mobile-btn d-lg-none" aria-label="Menu">
                                <div class="hamburger-inner">
                                    <span></span>
                                    <span></span>
                                    <span></span>
                                </div>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </nav>
        `;

        placeholder.innerHTML = navbarHTML;
        window.navbarInitialized = true;
        initNavbarLogic();
    };

    // Run on DOM load OR immediately if already loaded
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initNavbar);
    } else {
        initNavbar();
    }
})();

function initNavbarLogic() {
    const navbar = document.getElementById('navbar');
    const mobileMenuBtn = document.querySelector('.navbar-mobile-btn');
    const navLinksList = document.querySelector('.navbar-links');
    const navBackdrop = document.querySelector('.nav-backdrop');
    const drawerCloseBtn = document.querySelector('.drawer-close');


    if (navBackdrop) {
        navBackdrop.classList.remove('active');
        navBackdrop.style.display = ''; // Reset display 
    }

    if (navbar) {
        window.addEventListener('scroll', () => {
            if (window.scrollY > 50) navbar.classList.add('scrolled');
            else navbar.classList.remove('scrolled');
        }, { passive: true });
    }

    if (mobileMenuBtn && navLinksList) {
        const toggleMenu = (state) => {
            const isActive = state !== undefined ? state : !navLinksList.classList.contains('mobile-active');
            navLinksList.classList.toggle('mobile-active', isActive);
            mobileMenuBtn.classList.toggle('is-active', isActive);

            if (navBackdrop) {
                navBackdrop.classList.toggle('active', isActive);
            }
            document.body.style.overflow = isActive ? 'hidden' : '';
        };

        mobileMenuBtn.addEventListener('click', (e) => {
            e.preventDefault();
            toggleMenu();
        });

        if (drawerCloseBtn) drawerCloseBtn.addEventListener('click', () => toggleMenu(false));
        if (navBackdrop) navBackdrop.addEventListener('click', () => toggleMenu(false));

        const links = navLinksList.querySelectorAll('.navbar-link');
        links.forEach(link => {
            link.addEventListener('click', (e) => {
                const href = link.getAttribute('href') || '';
                // Only close menu automatically for hash links (internal page navigation)
                // Page-to-page navigation will happen naturally.
                if (href.startsWith('#') || href.includes('#')) {
                    toggleMenu(false);
                }
            });
        });

        // Close on Escape
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') toggleMenu(false);
        });
    }

    const themeNavToggle = document.getElementById('theme-nav-toggle');
    if (themeNavToggle) {
        themeNavToggle.addEventListener('click', () => {
            // Priority 1: Use original theme toggle if it exists
            const originalToggle = document.getElementById('theme-toggle');
            if (originalToggle) {
                originalToggle.click();
            } else if (window.setTheme) {
                // Priority 2: Use global setTheme if exposed
                const newTheme = document.body.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
                window.setTheme(newTheme);
            } else {
                // Priority 3: Direct fallback 
                const body = document.body;
                const newTheme = body.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
                body.setAttribute('data-theme', newTheme);
                localStorage.setItem('theme', newTheme);

                // Manually update icons if local
                const sunIcon = themeNavToggle.querySelector('.sun-icon');
                const moonIcon = themeNavToggle.querySelector('.moon-icon');
                if (sunIcon && moonIcon) {
                    sunIcon.style.display = newTheme === 'dark' ? 'block' : 'none';
                    moonIcon.style.display = newTheme === 'dark' ? 'none' : 'block';
                }
            }
        });
    }
}
