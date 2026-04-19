/**
 * Real-Time Reviews & Ratings Logic (Firebase Realtime Database)
 * Features: Real-time sync, Star filtering, and Email uniqueness check.
 */

import firebaseConfig from './firebase-config.js';
import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.12.0/firebase-app.js';
import { 
    getDatabase, 
    ref, 
    push, 
    set, 
    onValue,
    get,
    query,
    orderByChild,
    equalTo
} from 'https://www.gstatic.com/firebasejs/10.12.0/firebase-database.js';

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const db = getDatabase(app);
const reviewsRef = ref(db, 'reviews');

document.addEventListener('DOMContentLoaded', () => {
    // Check for placeholders
    if (firebaseConfig.apiKey.includes("PASTE_YOUR")) {
        console.warn("Firebase is not connected: Please update assets/js/firebase-config.js with your real credentials.");
        const loader = document.getElementById('reviews-loader');
        if (loader) {
            loader.innerHTML = `
                <div class="alert alert-warning">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i>
                    <strong>Firebase Not Connected</strong><br>
                    Please paste your keys into <code>assets/js/firebase-config.js</code> to enable real-time reviews.
                </div>
            `;
            loader.classList.remove('d-none');
        }
        return;
    }
    const reviewForm = document.getElementById('review-form');
    const reviewsContainer = document.getElementById('reviews-container');
    const totalReviewsEl = document.getElementById('total-reviews');
    const avgRatingEl = document.getElementById('avg-rating');
    const reviewsLoader = document.getElementById('reviews-loader');
    const filterPills = document.querySelectorAll('.filter-pill');

    let currentFilter = 'all';
    let allReviews = [];

    // Listen for Filter Changes
    filterPills.forEach(pill => {
        pill.addEventListener('click', () => {
            filterPills.forEach(p => p.classList.remove('active'));
            pill.classList.add('active');
            currentFilter = pill.getAttribute('data-filter');
            applyFilter();
        });
    });

    // Start listening for reviews globally
    console.log("Attempting to connect to Realtime Database...");
    if (reviewsLoader) reviewsLoader.classList.remove('d-none');
    
    // Safety timeout for slow connections
    const connectionTimeout = setTimeout(() => {
        if (reviewsLoader && !reviewsLoader.classList.contains('d-none')) {
            console.warn("Connection timeout: Check if your databaseURL is correct and the database is created.");
            reviewsLoader.innerHTML += '<p class="text-warning mt-2 small">Still waiting for response... check your Firebase config.</p>';
        }
    }, 5000);

    onValue(reviewsRef, (snapshot) => {
        console.log("Connection successful! Data received.");
        clearTimeout(connectionTimeout);
        if (reviewsLoader) reviewsLoader.classList.add('d-none');
        
        const data = snapshot.val();
        allReviews = [];
        
        if (data) {
            // Convert Firebase object to array and reverse for newest first
            const entries = Object.keys(data).map(key => ({
                id: key,
                ...data[key]
            }));
            allReviews = entries.sort((a, b) => b.timestamp - a.timestamp);
        }

        applyFilter();
        updateGlobalStats();
    });

    // Handle Form Submission
    if (reviewForm) {
        const emailInput = document.getElementById('review-email');
        const emailError = document.getElementById('email-error');

        // Reset error state on input
        emailInput.addEventListener('input', () => {
            emailInput.classList.remove('is-invalid');
            if (emailError) emailError.classList.add('d-none');
        });

        reviewForm.addEventListener('submit', async (e) => {
            e.preventDefault();

            const ratingInput = reviewForm.querySelector('input[name="rating"]:checked');
            const nameInput = document.getElementById('review-name');
            const roleInput = document.getElementById('review-role');
            const textInput = document.getElementById('review-text');

            if (!ratingInput) {
                alert('Please select a star rating!');
                return;
            }

            const submitBtn = reviewForm.querySelector('button[type="submit"]');
            const originalHTML = submitBtn.innerHTML;
            submitBtn.disabled = true;
            submitBtn.innerHTML = 'Checking...';

            try {
                // Check if email already exists
                const emailQuery = query(reviewsRef, orderByChild('email'), equalTo(emailInput.value.toLowerCase()));
                const emailSnapshot = await get(emailQuery);

                if (emailSnapshot.exists()) {
                    emailInput.classList.add('is-invalid');
                    if (emailError) emailError.classList.remove('d-none');
                    submitBtn.innerHTML = originalHTML;
                    submitBtn.disabled = false;
                    return;
                }

                submitBtn.innerHTML = 'Publishing...';
                
                const newReviewRef = push(reviewsRef);
                await set(newReviewRef, {
                    name: nameInput.value,
                    email: emailInput.value.toLowerCase(), // Store normalized email for matching
                    role: roleInput.value || "Client",
                    rating: parseInt(ratingInput.value),
                    text: textInput.value,
                    timestamp: Date.now()
                });

                reviewForm.reset();
                submitBtn.innerHTML = 'Posted! <i class="bi bi-check-circle-fill ms-2"></i>';
                submitBtn.style.backgroundColor = '#10b981';
                
                setTimeout(() => {
                    submitBtn.innerHTML = originalHTML;
                    submitBtn.style.backgroundColor = '';
                    submitBtn.disabled = false;
                }, 3000);

            } catch (error) {
                console.error("Error saving review: ", error);
                submitBtn.innerHTML = 'Error! Try Again';
                submitBtn.disabled = false;
            }
        });
    }

    function applyFilter() {
        if (!reviewsContainer) return;

        let filteredData = allReviews;
        if (currentFilter !== 'all') {
            filteredData = allReviews.filter(r => r.rating === parseInt(currentFilter));
        }

        renderReviews(filteredData);
    }

    function renderReviews(data) {
        if (data.length === 0) {
            reviewsContainer.innerHTML = '<div class="col-12 text-center py-5 opacity-50">No reviews found yet.</div>';
            return;
        }

        reviewsContainer.innerHTML = '';
        data.forEach(review => {
            const card = document.createElement('div');
            card.className = 'col-12 reveal active'; 
            
            let stars = '';
            for (let i = 1; i <= 5; i++) {
                stars += `<i class="bi bi-star${i <= review.rating ? '-fill' : ''}"></i> `;
            }

            const dateStr = new Date(review.timestamp).toLocaleDateString();

            card.innerHTML = `
                <div class="testimonial-card-premium">
                    <div class="review-stars-display">${stars}</div>
                    <p class="mb-4 opacity-90">"${review.text}"</p>
                    <div class="d-flex align-items-center gap-3">
                        <div class="testimonial-avatar d-flex align-items-center justify-content-center text-white bg-primary" 
                             style="width: 40px; height: 40px; border-radius: 50%; font-weight: bold; font-size: 14px;">
                            ${getInitials(review.name)}
                        </div>
                        <div>
                            <h5 class="mb-0" style="font-size: 16px;">${review.name}</h5>
                            <small class="opacity-50">${review.role} • ${dateStr}</small>
                        </div>
                    </div>
                </div>
            `;
            reviewsContainer.appendChild(card);
        });
    }

    function updateGlobalStats() {
        if (totalReviewsEl) totalReviewsEl.innerText = allReviews.length;
        if (avgRatingEl && allReviews.length > 0) {
            const total = allReviews.reduce((sum, r) => sum + r.rating, 0);
            avgRatingEl.innerText = (total / allReviews.length).toFixed(1);
        }
    }

    function getInitials(name) {
        return name.split(' ').map(n => n[0]).join('').toUpperCase().substring(0, 2);
    }
});
