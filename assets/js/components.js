// Reusable Components
const Components = {
    // Flip Card Handlers
    setupFlipCards() {
        const flipCards = document.querySelectorAll('.flip-card');
        flipCards.forEach(card => {
            card.addEventListener('click', function() {
                this.classList.toggle('flipped');
            });
        });
    },

    // Sticky Net Worth Card Handler
    setupStickyNetWorth() {
        const netWorthCard = document.getElementById('netWorthCard');
        const netWorthWrapper = document.querySelector('.net-worth-wrapper');
        if (!netWorthCard || !netWorthWrapper) return;

        const threshold = netWorthWrapper.offsetTop + netWorthWrapper.offsetHeight - 100;

        function handleScroll() {
            const scrollY = window.scrollY || window.pageYOffset;
            
            if (scrollY > threshold) {
                if (!netWorthCard.classList.contains('sticky')) {
                    netWorthCard.classList.add('sticky');
                    document.body.classList.add('has-sticky');
                }
            } else {
                if (netWorthCard.classList.contains('sticky')) {
                    netWorthCard.classList.remove('sticky');
                    document.body.classList.remove('has-sticky');
                }
            }
        }

        // Throttle scroll events for better performance
        let ticking = false;
        window.addEventListener('scroll', () => {
            if (!ticking) {
                window.requestAnimationFrame(() => {
                    handleScroll();
                    ticking = false;
                });
                ticking = true;
            }
        });

        // Initial check
        handleScroll();
    }
};

