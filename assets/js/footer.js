/**
 * Footer Component Loader for HEXJIN Tech
 * (HTML-in-JS version to avoid CORS issues)
 */

document.addEventListener('DOMContentLoaded', () => {
    console.log("Footer script running...");
    const footerPlaceholder = document.getElementById('footer-placeholder');
    if (!footerPlaceholder) {
        console.warn("Footer placeholder NOT found!");
        return;
    }

    // The footer HTML content
    const footerHTML = `
<footer class="footer-section pt-5 pb-4">
    <div class="container footer-container">
        <div class="row g-4 mb-5">
            <div class="col-lg-4 col-md-6 reveal">
                <a href="index.html" class="footer-logo mb-3 d-inline-block">
                    HEXJIN<span>TECH</span>
                </a>
                <p class="footer-bio pe-lg-5">Crafting high-performance digital experiences. From initial concept to
                    seamless deployment, we build the future of your business with modern tech and premium design.
                </p>
                <div class="footer-social-links d-flex gap-3 mt-4">
                    <a href="#" class="footer-social-link"><i class="bi bi-linkedin"></i></a>
                    <a href="#" class="footer-social-link"><i class="bi bi-twitter-x"></i></a>
                    <a href="#" class="footer-social-link"><i class="bi bi-github"></i></a>
                    <a href="#" class="footer-social-link"><i class="bi bi-instagram"></i></a>
                </div>
            </div>

            <div class="col-lg-2 col-md-6 reveal">
                <h4 class="footer-col-title">Navigation</h4>
                <ul class="list-unstyled footer-links">
                    <li><a href="about/">About Us</a></li>
                    <li><a href="portfolio/">Portfolio</a></li>
                    <li><a href="index.html#services">Services</a></li>
                    <li><a href="contact/">Contact Us</a></li>
                    <li><a href="index.html#faq">FAQ</a></li>
                </ul>
            </div>

            <div class="col-lg-3 col-md-6 reveal">
                <h4 class="footer-col-title">Our Services</h4>
                <ul class="list-unstyled footer-links">
                    <li><a href="index.html#services">Website Development</a></li>
                    <li><a href="index.html#services">SaaS & Web Apps</a></li>
                    <li><a href="index.html#services">UI/UX Design</a></li>
                    <li><a href="index.html#services">API Integration</a></li>
                    <li><a href="index.html#services">Technical Support</a></li>
                </ul>
            </div>

            <div class="col-lg-3 col-md-6 reveal">
                <h4 class="footer-col-title">Stay Updated</h4>
                <p class="footer-bio mb-4">Subscribe to our newsletter for the latest tech insights.</p>
                <div class="footer-newsletter-mini d-flex gap-2">
                    <input type="email" class="form-control newsletter-input" placeholder="Email" style="height: 45px; border-radius: 8px;">
                    <button class="btn-hire m-0 border-0" style="padding: 0 15px; height: 45px; border-radius: 8px;"><i class="bi bi-send"></i></button>
                </div>
                <div class="footer-contact-info mt-4">
                    <p class="mb-2 small"><a href="mailto:hexjintech@gmail.com"
                            class="text-decoration-none color-inherit"><i
                                class="bi bi-envelope me-2 footer-icon"></i> hexjintech@gmail.com</a></p>
                </div>
            </div>
        </div>

        <div class="footer-bottom border-top pt-4 text-center">
            <div class="row">
                <div class="col-md-6 text-md-start mb-2 mb-md-0">
                    <p class="footer-copyright mb-0">&copy; 2026 HEXJIN Tech. All rights reserved.</p>
                </div>
                <div class="col-md-6 text-md-end">
                    <p class="footer-copyright mb-0">Innovation Accelerated. Built in India.</p>
                </div>
            </div>
        </div>
    </div>
</footer>`;

    // Inject the HTML instantly
    footerPlaceholder.innerHTML = footerHTML;
    console.log("Footer HTML injected.");

    // Determine path depth specifically to adjust links
    const currentPath = window.location.pathname;
    const isSubPage = currentPath.includes('/about/') || 
                      currentPath.includes('/portfolio/') || 
                      currentPath.includes('/contact/');

    if (isSubPage) {
        const links = footerPlaceholder.querySelectorAll('a');
        links.forEach(link => {
            const href = link.getAttribute('href');
            if (href && !href.startsWith('http') && !href.startsWith('mailto:') && !href.startsWith('tel:')) {
                // Adjust relative paths to go up one level
                if (href === 'about/' || href === 'portfolio/' || href === 'contact/') {
                    link.setAttribute('href', '../' + href);
                } else if (href.includes('index.html')) {
                    link.setAttribute('href', '../' + href);
                }
            }
        });
    }

    // Re-trigger reveal animations for the footer elements
    if (window.revealObserver) {
        console.log("Triggering footer animations.");
        const revealElements = footerPlaceholder.querySelectorAll('.reveal');
        revealElements.forEach(el => window.revealObserver.observe(el));
    } else {
        console.warn("Reveal observer not found, footer might stay invisible.");
    }
});
