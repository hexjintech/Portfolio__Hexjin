/**
 * Footer Component Loader for HEXJIN Tech
 */

document.addEventListener('DOMContentLoaded', () => {
    const footerPlaceholder = document.getElementById('footer-placeholder');
    if (!footerPlaceholder) return;

    // Determine path depth to reach assets folder
    // This is a simple way to handle relative paths in a multi-level structure
    const currentPath = window.location.pathname;
    const isSubPage = currentPath.includes('/about/') || 
                      currentPath.includes('/portfolio/') || 
                      currentPath.includes('/contact/');
    
    const basePath = isSubPage ? '../' : '';
    const footerUrl = `${basePath}assets/footer.html`;

    fetch(footerUrl)
        .then(response => {
            if (!response.ok) throw new Error('Failed to load footer');
            return response.text();
        })
        .then(html => {
            // Inject the HTML
            footerPlaceholder.innerHTML = html;
            
            // Adjust paths inside the footer if we are in a sub-page
            if (isSubPage) {
                const links = footerPlaceholder.querySelectorAll('a');
                links.forEach(link => {
                    const href = link.getAttribute('href');
                    // Only prefix local relative links, not external ones
                    if (href && !href.startsWith('http') && !href.startsWith('mailto:') && !href.startsWith('tel:')) {
                        // Special case: if it already points to the current directory link, don't double up
                        // But for simplicity, we'll just check if it's a root-relative-like link
                        if (href.startsWith('index.html')) {
                             link.setAttribute('href', '../' + href);
                        } else if (href === 'about/' || href === 'portfolio/' || href === 'contact/') {
                             link.setAttribute('href', '../' + href);
                        }
                    }
                });
            }

            // Re-trigger reveal animations for the footer
            if (typeof initRevealAnimations === 'function') {
                initRevealAnimations();
            } else if (window.revealObserver) {
                const revealElements = footerPlaceholder.querySelectorAll('.reveal');
                revealElements.forEach(el => window.revealObserver.observe(el));
            }
        })
        .catch(err => console.error('Error loading footer:', err));
});
