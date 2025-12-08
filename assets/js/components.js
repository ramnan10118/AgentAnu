// Reusable Components
const Components = {
    // Flip Card Handlers
    setupFlipCards() {
        const flipCards = document.querySelectorAll('.flip-card');
        console.log('Setting up flip cards, found:', flipCards.length);
        
        if (flipCards.length === 0) {
            console.warn('No flip cards found!');
            return;
        }
        
        // Use event delegation on document for reliability
        // Remove existing handler if it exists
        if (this._flipCardHandler) {
            document.removeEventListener('click', this._flipCardHandler);
        }
        
        // Create handler function
        this._flipCardHandler = (e) => {
            // Find the closest flip-card element
            const card = e.target.closest('.flip-card');
            if (card) {
                // Don't flip if clicking on interactive elements inside
                if (e.target.tagName === 'BUTTON' || e.target.closest('button')) {
                    return;
                }
                card.classList.toggle('flipped');
            }
        };
        
        // Add event listener to document
        document.addEventListener('click', this._flipCardHandler);
        console.log('Flip card event delegation set up');
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
    },

    // Collapsible Cards Handler
    setupCollapsibleCards() {
        console.log('Setting up collapsible cards...');
        
        // Use event delegation on document for maximum reliability
        // Remove any existing listener
        if (this._collapsibleHandler) {
            document.removeEventListener('click', this._collapsibleHandler);
        }
        
        // Create handler function
        this._collapsibleHandler = (e) => {
            const header = e.target.closest('.collapsible-header');
            if (!header) return;
            
            e.preventDefault();
            e.stopPropagation();
            
            const targetId = header.getAttribute('data-target');
            if (!targetId) {
                console.error('No data-target found on header');
                return;
            }
            
            console.log('Header clicked:', targetId);
            const content = document.getElementById(targetId);
            const chevron = header.querySelector('.collapsible-chevron');
            
            if (!content) {
                console.error('Content not found for:', targetId);
                return;
            }
            
            // Check if this card is currently open
            const isOpen = content.classList.contains('expanded');
            console.log('Is open:', isOpen);
            
            // Close all other cards (accordion behavior)
            document.querySelectorAll('.collapsible-content').forEach(item => {
                if (item.id !== targetId) {
                    item.classList.remove('expanded');
                    item.style.maxHeight = '0px';
                    const otherHeader = document.querySelector(`[data-target="${item.id}"]`);
                    if (otherHeader) {
                        const otherChevron = otherHeader.querySelector('.collapsible-chevron');
                        if (otherChevron) {
                            otherChevron.style.transform = 'rotate(0deg)';
                        }
                    }
                }
            });
            
            // Toggle current card
            if (isOpen) {
                content.classList.remove('expanded');
                content.style.maxHeight = '0px';
                if (chevron) {
                    chevron.style.transform = 'rotate(0deg)';
                }
                console.log('Collapsed:', targetId);
            } else {
                content.classList.add('expanded');
                // Set max-height to actual content height for smooth animation
                const scrollHeight = content.scrollHeight;
                content.style.maxHeight = scrollHeight + 'px';
                if (chevron) {
                    chevron.style.transform = 'rotate(180deg)';
                }
                console.log('Expanded:', targetId, 'Height:', scrollHeight);
            }
        };
        
        // Add event listener to document
        document.addEventListener('click', this._collapsibleHandler);
        
        // Initialize all cards as collapsed
        const allContents = document.querySelectorAll('.collapsible-content');
        console.log('Found contents:', allContents.length);
        
        allContents.forEach((content, index) => {
            content.classList.remove('expanded');
            content.style.maxHeight = '0px';
            const header = document.querySelector(`[data-target="${content.id}"]`);
            if (header) {
                const chevron = header.querySelector('.collapsible-chevron');
                if (chevron) {
                    chevron.style.transform = 'rotate(0deg)';
                }
            }
        });
        
        // Expand first card by default
        if (allContents.length > 0) {
            const firstContent = allContents[0];
            const firstHeader = document.querySelector(`[data-target="${firstContent.id}"]`);
            firstContent.classList.add('expanded');
            const scrollHeight = firstContent.scrollHeight;
            firstContent.style.maxHeight = scrollHeight + 'px';
            if (firstHeader) {
                const firstChevron = firstHeader.querySelector('.collapsible-chevron');
                if (firstChevron) {
                    firstChevron.style.transform = 'rotate(180deg)';
                }
            }
            console.log('First card expanded:', firstContent.id);
        }
        
        console.log('Collapsible cards setup complete');
    }
};

