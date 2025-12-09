// Asset Management and Rendering Module
const Assets = {
    renderBankSavingsDetails(data) {
        const container = document.getElementById('bankSavingsDetails');
        if (!data || data.details.length === 0) {
            container.innerHTML = '<p class="text-sm text-muted-foreground">No bank accounts connected.</p>';
            return;
        }

        let html = '<div class="space-y-3">';
        data.details.forEach(account => {
            html += `
                <div class="flex items-center justify-between p-3 bg-muted rounded-md">
                    <div class="flex-1">
                        <p class="font-medium text-sm">${account.bank}</p>
                        <p class="text-xs text-muted-foreground">${account.accountNumber} • ${account.type}</p>
                    </div>
                    <div class="text-right">
                        <p class="font-semibold">${Utils.formatCurrency(account.balance)}</p>
                    </div>
                </div>
            `;
        });
        html += '</div>';
        container.innerHTML = html;
    },

    renderLoansDetails(data) {
        const container = document.getElementById('loansDetails');
        if (!data || data.details.length === 0) {
            container.innerHTML = '<p class="text-sm text-muted-foreground">No active loans.</p>';
            return;
        }

        let html = '<div class="space-y-4">';
        data.details.forEach(loan => {
            const progressPercent = loan.originalAmount ? ((loan.paidAmount / loan.originalAmount) * 100).toFixed(1) : 0;
            const purposeIcon = loan.purpose === 'House Purchase' ? '🏠' : loan.purpose === 'Car' ? '🚗' : '💼';
            
            html += `
                <div class="p-4 bg-muted rounded-lg border hover:shadow-md transition-shadow">
                    <div class="flex items-start justify-between mb-3">
                        <div class="flex-1">
                            <div class="flex items-center gap-2 mb-1">
                                <span class="text-lg">${purposeIcon}</span>
                                <p class="font-semibold text-base">${loan.loanType}</p>
                            </div>
                            <p class="text-xs text-muted-foreground mb-2">${loan.lender}</p>
                            <div class="inline-flex items-center px-2 py-1 bg-primary/10 text-primary rounded-md text-xs font-medium">
                                ${loan.purpose}
                            </div>
                        </div>
                        <div class="text-right">
                            <p class="font-bold text-lg text-destructive">${Utils.formatCurrency(loan.outstanding)}</p>
                            <p class="text-xs text-muted-foreground">Outstanding</p>
                        </div>
                    </div>
                    
                    <div class="space-y-2 mb-3">
                        <div class="flex items-center justify-between text-xs">
                            <span class="text-muted-foreground">Original Amount</span>
                            <span class="font-medium">${Utils.formatCurrency(loan.originalAmount || 0)}</span>
                        </div>
                        <div class="flex items-center justify-between text-xs">
                            <span class="text-muted-foreground">Amount Paid</span>
                            <span class="font-medium text-green-600">${Utils.formatCurrency(loan.paidAmount || 0)}</span>
                        </div>
                        <div class="w-full bg-secondary rounded-full h-2">
                            <div class="bg-green-600 h-2 rounded-full" style="width: ${progressPercent}%"></div>
                        </div>
                        <p class="text-xs text-muted-foreground text-center">${progressPercent}% paid</p>
                    </div>
                    
                    <div class="grid grid-cols-3 gap-3 pt-3 border-t">
                        <div>
                            <p class="text-xs text-muted-foreground mb-1">EMI</p>
                            <p class="font-semibold text-sm">${Utils.formatCurrency(loan.emi)}</p>
                        </div>
                        <div>
                            <p class="text-xs text-muted-foreground mb-1">Remaining</p>
                            <p class="font-semibold text-sm">${loan.remainingMonths || 0} months</p>
                        </div>
                        <div>
                            <p class="text-xs text-muted-foreground mb-1">Total Tenure</p>
                            <p class="font-semibold text-sm">${loan.tenure || 0} months</p>
                        </div>
                    </div>
                </div>
            `;
        });
        html += '</div>';
        container.innerHTML = html;
    },

    renderAssetsDetails(data) {
        const container = document.getElementById('assetsDetails');
        if (!data || data.details.length === 0) {
            container.innerHTML = '<p class="text-sm text-muted-foreground">No assets recorded.</p>';
            return;
        }

        let html = '<div class="space-y-3">';
        data.details.forEach(asset => {
            html += `
                <div class="flex items-center justify-between p-3 bg-muted rounded-md">
                    <div class="flex-1">
                        <p class="font-medium text-sm">${asset.name}</p>
                        ${asset.location ? `<p class="text-xs text-muted-foreground">${asset.location} • ${asset.type}</p>` : `<p class="text-xs text-muted-foreground">${asset.type}</p>`}
                    </div>
                    <div class="text-right">
                        <p class="font-semibold">${Utils.formatCurrency(asset.value)}</p>
                    </div>
                </div>
            `;
        });
        html += '</div>';
        container.innerHTML = html;
    },

    renderMutualFundsDetails(data) {
        const container = document.getElementById('mutualFundsDetails');
        if (!data || data.details.length === 0) {
            container.innerHTML = '<p class="text-sm text-muted-foreground">No mutual fund investments.</p>';
            return;
        }

        let html = '<div class="space-y-3">';
        data.details.forEach(fund => {
            const isPositive = fund.returns.startsWith('+');
            html += `
                <div class="flex items-center justify-between p-3 bg-muted rounded-md">
                    <div class="flex-1">
                        <p class="font-medium text-sm">${fund.name}</p>
                        <p class="text-xs text-muted-foreground">${fund.type}</p>
                    </div>
                    <div class="text-right">
                        <p class="font-semibold">${Utils.formatCurrency(fund.amount)}</p>
                        <p class="text-xs ${isPositive ? 'text-green-600' : 'text-red-600'}">${fund.returns}</p>
                    </div>
                </div>
            `;
        });
        html += '</div>';
        container.innerHTML = html;
    },

    renderStocksDetails(data) {
        const container = document.getElementById('stocksDetails');
        if (!data || data.details.length === 0) {
            container.innerHTML = '<p class="text-sm text-muted-foreground">No stock holdings.</p>';
            return;
        }

        let html = '<div class="space-y-3">';
        data.details.forEach(stock => {
            const isPositive = stock.returns.startsWith('+');
            html += `
                <div class="flex items-center justify-between p-3 bg-muted rounded-md">
                    <div class="flex-1">
                        <p class="font-medium text-sm">${stock.symbol}</p>
                        <p class="text-xs text-muted-foreground">${stock.name} • Qty: ${stock.quantity}</p>
                    </div>
                    <div class="text-right">
                        <p class="font-semibold">${Utils.formatCurrency(stock.value)}</p>
                        <p class="text-xs ${isPositive ? 'text-green-600' : 'text-red-600'}">${stock.returns}</p>
                    </div>
                </div>
            `;
        });
        html += '</div>';
        container.innerHTML = html;
    },

    renderDigitalGoldDetails(data) {
        const container = document.getElementById('digitalGoldDetails');
        if (!data || data.details.length === 0) {
            container.innerHTML = '<p class="text-sm text-muted-foreground">No digital gold holdings.</p>';
            return;
        }

        let html = '<div class="space-y-3">';
        data.details.forEach(gold => {
            html += `
                <div class="flex items-center justify-between p-3 bg-muted rounded-md">
                    <div class="flex-1">
                        <p class="font-medium text-sm">${gold.platform}</p>
                        <p class="text-xs text-muted-foreground">${gold.units} grams • ₹${gold.currentPrice}/gram</p>
                    </div>
                    <div class="text-right">
                        <p class="font-semibold">${Utils.formatCurrency(gold.value)}</p>
                    </div>
                </div>
            `;
        });
        html += '</div>';
        container.innerHTML = html;
    },

    populateFlipCardDetails(data) {
        // Bank Savings
        if (data.bankSavings && data.bankSavings.details) {
            const container = document.getElementById('bankSavingsFlipDetails');
            const accounts = data.bankSavings.details;
            const totalAccounts = accounts.length;
            
            container.innerHTML = `
                <div class="flex items-center justify-center h-full">
                    <div class="text-center">
                        <p class="text-3xl font-bold mb-1">${totalAccounts}</p>
                        <p class="text-xs text-muted-foreground">Bank Accounts</p>
                    </div>
                </div>
            `;
        }

        // Loans
        if (data.loans && data.loans.details) {
            const container = document.getElementById('loansFlipDetails');
            const loans = data.loans.details;
            const totalLoans = loans.length;
            
            container.innerHTML = `
                <div class="flex items-center justify-center h-full">
                    <div class="text-center">
                        <p class="text-3xl font-bold mb-1">${totalLoans}</p>
                        <p class="text-xs text-muted-foreground">Active Loans</p>
                    </div>
                </div>
            `;
        }

        // Assets
        if (data.assets && data.assets.details) {
            const container = document.getElementById('assetsFlipDetails');
            const assets = data.assets.details;
            const totalAssets = assets.length;
            
            container.innerHTML = `
                <div class="flex items-center justify-center h-full">
                    <div class="text-center">
                        <p class="text-3xl font-bold mb-1">${totalAssets}</p>
                        <p class="text-xs text-muted-foreground">Properties & Assets</p>
                    </div>
                </div>
            `;
        }

        // Mutual Funds
        if (data.mutualFunds && data.mutualFunds.details) {
            const container = document.getElementById('mutualFundsFlipDetails');
            const funds = data.mutualFunds.details;
            const totalFunds = funds.length;
            
            container.innerHTML = `
                <div class="flex items-center justify-center h-full">
                    <div class="text-center">
                        <p class="text-3xl font-bold mb-1">${totalFunds}</p>
                        <p class="text-xs text-muted-foreground">Mutual Fund Schemes</p>
                    </div>
                </div>
            `;
        }

        // Stocks
        if (data.stocks && data.stocks.details) {
            const container = document.getElementById('stocksFlipDetails');
            const stocks = data.stocks.details;
            const totalHoldings = stocks.length;
            
            container.innerHTML = `
                <div class="flex items-center justify-center h-full">
                    <div class="text-center">
                        <p class="text-3xl font-bold mb-1">${totalHoldings}</p>
                        <p class="text-xs text-muted-foreground">Stock Holdings</p>
                    </div>
                </div>
            `;
        }

        // Digital Gold
        if (data.digitalGold && data.digitalGold.details) {
            const container = document.getElementById('digitalGoldFlipDetails');
            const totalGrams = data.digitalGold.details.reduce((sum, g) => sum + g.units, 0);
            
            container.innerHTML = `
                <div class="flex items-center justify-center h-full">
                    <div class="text-center">
                        <p class="text-3xl font-bold mb-1">${totalGrams.toFixed(2)}</p>
                        <p class="text-xs text-muted-foreground">Grams of Gold</p>
                    </div>
                </div>
            `;
        }
    },

    updateAssetData(data) {
        console.log('Updating asset data:', data);
        
        if (!data) {
            console.error('No data provided to updateAssetData');
            return;
        }
        
        let totalAssets = 0;
        let totalLiabilities = 0;
        
        // Update overview cards
        if (data.bankSavings) {
            const totalEl = document.getElementById('bankSavingsTotal');
            const countEl = document.getElementById('bankAccountsCount');
            if (totalEl) totalEl.textContent = Utils.formatCurrency(data.bankSavings.total);
            if (countEl) countEl.textContent = data.bankSavings.accounts || 0;
            this.renderBankSavingsDetails(data.bankSavings);
            totalAssets += data.bankSavings.total || 0;
        }
        
        if (data.loans) {
            const totalEl = document.getElementById('loansTotal');
            const countEl = document.getElementById('loansCount');
            if (totalEl) totalEl.textContent = Utils.formatCurrency(data.loans.total);
            if (countEl) countEl.textContent = data.loans.count || 0;
            this.renderLoansDetails(data.loans);
            totalLiabilities += data.loans.total || 0;
        }
        
        if (data.assets) {
            const totalEl = document.getElementById('assetsTotal');
            const countEl = document.getElementById('assetsCount');
            if (totalEl) totalEl.textContent = Utils.formatCurrency(data.assets.total);
            if (countEl) countEl.textContent = data.assets.count || 0;
            this.renderAssetsDetails(data.assets);
            totalAssets += data.assets.total || 0;
        }
        
        if (data.mutualFunds) {
            const totalEl = document.getElementById('mutualFundsTotal');
            const countEl = document.getElementById('mutualFundsCount');
            if (totalEl) totalEl.textContent = Utils.formatCurrency(data.mutualFunds.total);
            if (countEl) countEl.textContent = data.mutualFunds.count || 0;
            this.renderMutualFundsDetails(data.mutualFunds);
            totalAssets += data.mutualFunds.total || 0;
        }
        
        if (data.stocks) {
            const totalEl = document.getElementById('stocksTotal');
            const countEl = document.getElementById('stocksCount');
            if (totalEl) totalEl.textContent = Utils.formatCurrency(data.stocks.total);
            if (countEl) countEl.textContent = data.stocks.count || 0;
            this.renderStocksDetails(data.stocks);
            totalAssets += data.stocks.total || 0;
        }
        
        if (data.digitalGold) {
            const totalEl = document.getElementById('digitalGoldTotal');
            const countEl = document.getElementById('digitalGoldCount');
            if (totalEl) totalEl.textContent = Utils.formatCurrency(data.digitalGold.total);
            if (countEl) countEl.textContent = data.digitalGold.count || 0;
            this.renderDigitalGoldDetails(data.digitalGold);
            totalAssets += data.digitalGold.total || 0;
        }
        
        // Update Net Worth Summary
        const netWorth = totalAssets - totalLiabilities;
        console.log('Calculated totals:', { netWorth, totalAssets, totalLiabilities });
        
        const netWorthEl = document.getElementById('netWorth');
        const totalAssetsEl = document.getElementById('totalAssets');
        const totalLiabilitiesEl = document.getElementById('totalLiabilities');
        
        if (netWorthEl) {
            netWorthEl.textContent = Utils.formatCurrency(netWorth);
        } else {
            console.error('netWorth element not found!');
        }
        
        if (totalAssetsEl) {
            totalAssetsEl.textContent = Utils.formatCurrency(totalAssets);
        } else {
            console.error('totalAssets element not found!');
        }
        
        if (totalLiabilitiesEl) {
            totalLiabilitiesEl.textContent = Utils.formatCurrency(totalLiabilities);
        } else {
            console.error('totalLiabilities element not found!');
        }

        // Populate flip card details
        this.populateFlipCardDetails(data);

        // Render pie chart
        Charts.renderPieChart(data);
    }
};

