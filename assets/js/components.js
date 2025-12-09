// Reusable UI Components
const Components = {
    // Flip Card Handler
    setupFlipCards() {
        // Use event delegation for more reliable click handling
        if (this._flipCardHandler) {
            document.removeEventListener('click', this._flipCardHandler);
        }
        
        this._flipCardHandler = (e) => {
            const flipCard = e.target.closest('.flip-card');
            if (!flipCard) return;
            
            // Don't flip if clicking on a button or interactive element
            if (e.target.closest('button') || e.target.closest('a')) {
                return;
            }
            
            flipCard.classList.toggle('flipped');
        };
        
        document.addEventListener('click', this._flipCardHandler);
    },

    // Sticky Net Worth Card Handler
    setupStickyNetWorth() {
        console.log('=== SETTING UP STICKY NET WORTH ===');
        const netWorthCard = document.getElementById('netWorthCard');
        const netWorthWrapper = document.querySelector('.net-worth-wrapper');
        
        if (!netWorthCard) {
            console.error('netWorthCard element not found!');
            return;
        }
        if (!netWorthWrapper) {
            console.error('netWorthWrapper element not found!');
            return;
        }

        console.log('Elements found, setting up scroll handler');

        function checkAndToggle() {
            const wrapperRect = netWorthWrapper.getBoundingClientRect();
            
            // Stick when the wrapper's top reaches or goes above the viewport top
            if (wrapperRect.top <= 0) {
                if (!netWorthCard.classList.contains('sticky')) {
                    netWorthCard.classList.add('sticky');
                    document.body.classList.add('has-sticky');
                    console.log('STICKY ADDED - wrapperRect.top:', wrapperRect.top);
                }
            } else {
                if (netWorthCard.classList.contains('sticky')) {
                    netWorthCard.classList.remove('sticky');
                    document.body.classList.remove('has-sticky');
                    console.log('STICKY REMOVED - wrapperRect.top:', wrapperRect.top);
                }
            }
        }

        // Throttle scroll events
        let ticking = false;
        function onScroll() {
            if (!ticking) {
                window.requestAnimationFrame(() => {
                    checkAndToggle();
                    ticking = false;
                });
                ticking = true;
            }
        }

        // Attach scroll listener
        window.addEventListener('scroll', onScroll, { passive: true });
        console.log('Scroll listener attached');
        
        // Recalculate on resize
        window.addEventListener('resize', checkAndToggle);
        
        // Initial check
        setTimeout(() => {
            checkAndToggle();
        }, 200);
        
        // Also check after a longer delay
        setTimeout(() => {
            checkAndToggle();
        }, 1000);
    },

    // Collapsible Cards Handler
    setupCollapsibleCards() {
        console.log('Setting up collapsible cards...');
        const headers = document.querySelectorAll('.collapsible-header');
        
        if (headers.length === 0) {
            console.log('No collapsible headers found');
            return;
        }

        console.log(`Found ${headers.length} collapsible headers`);

        // Initialize all as collapsed, expand first one
        headers.forEach((header, index) => {
            const targetId = header.getAttribute('data-target');
            const content = document.getElementById(targetId);
            
            if (!content) {
                console.error(`Content element not found for target: ${targetId}`);
                return;
            }

            // Set max-height based on scrollHeight for smooth transition
            const setMaxHeight = () => {
                if (content.classList.contains('expanded')) {
                    content.style.maxHeight = content.scrollHeight + 'px';
                } else {
                    content.style.maxHeight = '0px';
                }
            };

            // Initialize: first one expanded, others collapsed
            if (index === 0) {
                content.classList.add('expanded');
                const chevron = header.querySelector('.collapsible-chevron');
                if (chevron) {
                    chevron.style.transform = 'rotate(180deg)';
                }
            } else {
                content.classList.remove('expanded');
            }
            
            setMaxHeight();

            // Click handler
            header.addEventListener('click', () => {
                const isExpanded = content.classList.contains('expanded');
                const chevron = header.querySelector('.collapsible-chevron');
                
                // Close all other cards
                headers.forEach((otherHeader, otherIndex) => {
                    if (otherIndex !== index) {
                        const otherTargetId = otherHeader.getAttribute('data-target');
                        const otherContent = document.getElementById(otherTargetId);
                        const otherChevron = otherHeader.querySelector('.collapsible-chevron');
                        
                        if (otherContent) {
                            otherContent.classList.remove('expanded');
                            otherContent.style.maxHeight = '0px';
                        }
                        if (otherChevron) {
                            otherChevron.style.transform = 'rotate(0deg)';
                        }
                    }
                });

                // Toggle current card
                if (isExpanded) {
                    content.classList.remove('expanded');
                    content.style.maxHeight = '0px';
                    if (chevron) {
                        chevron.style.transform = 'rotate(0deg)';
                    }
                } else {
                    content.classList.add('expanded');
                    content.style.maxHeight = content.scrollHeight + 'px';
                    if (chevron) {
                        chevron.style.transform = 'rotate(180deg)';
                    }
                }
            });
        });

        // Update max-height on window resize
        window.addEventListener('resize', () => {
            headers.forEach((header) => {
                const targetId = header.getAttribute('data-target');
                const content = document.getElementById(targetId);
                if (content && content.classList.contains('expanded')) {
                    content.style.maxHeight = content.scrollHeight + 'px';
                }
            });
        });
    }
};
