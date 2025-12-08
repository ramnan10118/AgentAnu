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
            const savingsAccounts = accounts.filter(a => a.type === 'Savings').length;
            const currentAccounts = accounts.filter(a => a.type === 'Current').length;
            const largestAccount = accounts.reduce((max, acc) => acc.balance > max.balance ? acc : max, accounts[0]);
            const avgBalance = Math.round(data.bankSavings.total / totalAccounts);
            
            container.innerHTML = `
                <div class="space-y-3">
                    <div class="grid grid-cols-2 gap-3">
                        <div class="p-2 bg-muted rounded text-center">
                            <p class="text-xs text-muted-foreground mb-1">Total Accounts</p>
                            <p class="text-lg font-bold">${totalAccounts}</p>
                        </div>
                        <div class="p-2 bg-muted rounded text-center">
                            <p class="text-xs text-muted-foreground mb-1">Avg Balance</p>
                            <p class="text-sm font-semibold">${Utils.formatCurrency(avgBalance)}</p>
                        </div>
                    </div>
                    <div class="p-2 bg-muted rounded">
                        <p class="text-xs text-muted-foreground mb-1">Account Types</p>
                        <p class="text-sm font-medium">${savingsAccounts} Savings • ${currentAccounts} Current</p>
                    </div>
                    <div class="p-2 bg-muted rounded">
                        <p class="text-xs text-muted-foreground mb-1">Largest Account</p>
                        <p class="text-sm font-semibold">${largestAccount.bank}</p>
                        <p class="text-xs text-muted-foreground">${Utils.formatCurrency(largestAccount.balance)}</p>
                    </div>
                </div>
            `;
        }

        // Loans
        if (data.loans && data.loans.details) {
            const container = document.getElementById('loansFlipDetails');
            const loans = data.loans.details;
            const totalLoans = loans.length;
            const totalEMI = loans.reduce((sum, loan) => sum + loan.emi, 0);
            const avgRemainingMonths = Math.round(loans.reduce((sum, loan) => sum + loan.remainingMonths, 0) / totalLoans);
            const homeLoans = loans.filter(l => l.purpose === 'House Purchase').length;
            const personalLoans = loans.filter(l => l.purpose === 'Personal').length;
            
            container.innerHTML = `
                <div class="space-y-3">
                    <div class="grid grid-cols-2 gap-3">
                        <div class="p-2 bg-muted rounded text-center">
                            <p class="text-xs text-muted-foreground mb-1">Total Loans</p>
                            <p class="text-lg font-bold">${totalLoans}</p>
                        </div>
                        <div class="p-2 bg-muted rounded text-center">
                            <p class="text-xs text-muted-foreground mb-1">Total EMI</p>
                            <p class="text-sm font-semibold">${Utils.formatCurrency(totalEMI)}</p>
                        </div>
                    </div>
                    <div class="p-2 bg-muted rounded">
                        <p class="text-xs text-muted-foreground mb-1">Loan Types</p>
                        <p class="text-sm font-medium">${homeLoans} Home • ${personalLoans} Personal</p>
                    </div>
                    <div class="p-2 bg-muted rounded">
                        <p class="text-xs text-muted-foreground mb-1">Avg Remaining</p>
                        <p class="text-sm font-semibold">${avgRemainingMonths} months</p>
                    </div>
                </div>
            `;
        }

        // Assets
        if (data.assets && data.assets.details) {
            const container = document.getElementById('assetsFlipDetails');
            const assets = data.assets.details;
            const propertyAssets = assets.filter(a => a.type === 'Property' || a.type === 'Land');
            const vehicleAssets = assets.filter(a => a.type === 'Vehicle');
            const largestAsset = assets.reduce((max, asset) => asset.value > max.value ? asset : max, assets[0]);
            
            container.innerHTML = `
                <div class="space-y-3">
                    <div class="grid grid-cols-2 gap-3">
                        <div class="p-2 bg-muted rounded text-center">
                            <p class="text-xs text-muted-foreground mb-1">Total Assets</p>
                            <p class="text-lg font-bold">${assets.length}</p>
                        </div>
                        <div class="p-2 bg-muted rounded text-center">
                            <p class="text-xs text-muted-foreground mb-1">Properties</p>
                            <p class="text-sm font-semibold">${propertyAssets.length}</p>
                        </div>
                    </div>
                    <div class="p-2 bg-muted rounded">
                        <p class="text-xs text-muted-foreground mb-1">Asset Breakdown</p>
                        <p class="text-sm font-medium">${propertyAssets.length} Property • ${vehicleAssets.length} Vehicle</p>
                    </div>
                    <div class="p-2 bg-muted rounded">
                        <p class="text-xs text-muted-foreground mb-1">Largest Asset</p>
                        <p class="text-sm font-semibold">${largestAsset.name}</p>
                        <p class="text-xs text-muted-foreground">${Utils.formatCurrency(largestAsset.value)}</p>
                    </div>
                </div>
            `;
        }

        // Mutual Funds
        if (data.mutualFunds && data.mutualFunds.details) {
            const container = document.getElementById('mutualFundsFlipDetails');
            const funds = data.mutualFunds.details;
            const totalFunds = funds.length;
            const equityFunds = funds.filter(f => f.type === 'Equity').length;
            const avgReturns = funds.reduce((sum, fund) => {
                const ret = parseFloat(fund.returns.replace('+', '').replace('%', ''));
                return sum + ret;
            }, 0) / totalFunds;
            const topPerformer = funds.reduce((max, fund) => {
                const ret = parseFloat(fund.returns.replace('+', '').replace('%', ''));
                const maxRet = parseFloat(max.returns.replace('+', '').replace('%', ''));
                return ret > maxRet ? fund : max;
            }, funds[0]);
            
            container.innerHTML = `
                <div class="space-y-3">
                    <div class="grid grid-cols-2 gap-3">
                        <div class="p-2 bg-muted rounded text-center">
                            <p class="text-xs text-muted-foreground mb-1">Total Funds</p>
                            <p class="text-lg font-bold">${totalFunds}</p>
                        </div>
                        <div class="p-2 bg-muted rounded text-center">
                            <p class="text-xs text-muted-foreground mb-1">Avg Returns</p>
                            <p class="text-sm font-semibold text-green-600">+${avgReturns.toFixed(1)}%</p>
                        </div>
                    </div>
                    <div class="p-2 bg-muted rounded">
                        <p class="text-xs text-muted-foreground mb-1">Fund Types</p>
                        <p class="text-sm font-medium">${equityFunds} Equity • ${totalFunds - equityFunds} Others</p>
                    </div>
                    <div class="p-2 bg-muted rounded">
                        <p class="text-xs text-muted-foreground mb-1">Top Performer</p>
                        <p class="text-sm font-semibold">${topPerformer.name}</p>
                        <p class="text-xs text-green-600">${topPerformer.returns}</p>
                    </div>
                </div>
            `;
        }

        // Stocks
        if (data.stocks && data.stocks.details) {
            const container = document.getElementById('stocksFlipDetails');
            const stocks = data.stocks.details;
            const totalHoldings = stocks.length;
            const totalQuantity = stocks.reduce((sum, stock) => sum + stock.quantity, 0);
            const avgReturns = stocks.reduce((sum, stock) => {
                const ret = parseFloat(stock.returns.replace('+', '').replace('%', ''));
                return sum + ret;
            }, 0) / totalHoldings;
            const topPerformer = stocks.reduce((max, stock) => {
                const ret = parseFloat(stock.returns.replace('+', '').replace('%', ''));
                const maxRet = parseFloat(max.returns.replace('+', '').replace('%', ''));
                return ret > maxRet ? stock : max;
            }, stocks[0]);
            
            container.innerHTML = `
                <div class="space-y-3">
                    <div class="grid grid-cols-2 gap-3">
                        <div class="p-2 bg-muted rounded text-center">
                            <p class="text-xs text-muted-foreground mb-1">Total Holdings</p>
                            <p class="text-lg font-bold">${totalHoldings}</p>
                        </div>
                        <div class="p-2 bg-muted rounded text-center">
                            <p class="text-xs text-muted-foreground mb-1">Avg Returns</p>
                            <p class="text-sm font-semibold text-green-600">+${avgReturns.toFixed(1)}%</p>
                        </div>
                    </div>
                    <div class="p-2 bg-muted rounded">
                        <p class="text-xs text-muted-foreground mb-1">Total Shares</p>
                        <p class="text-sm font-medium">${totalQuantity.toLocaleString()} shares</p>
                    </div>
                    <div class="p-2 bg-muted rounded">
                        <p class="text-xs text-muted-foreground mb-1">Top Performer</p>
                        <p class="text-sm font-semibold">${topPerformer.symbol}</p>
                        <p class="text-xs text-green-600">${topPerformer.returns}</p>
                    </div>
                </div>
            `;
        }

        // Digital Gold
        if (data.digitalGold && data.digitalGold.details) {
            const container = document.getElementById('digitalGoldFlipDetails');
            const gold = data.digitalGold.details[0];
            const totalGrams = data.digitalGold.details.reduce((sum, g) => sum + g.units, 0);
            
            container.innerHTML = `
                <div class="space-y-3">
                    <div class="p-2 bg-muted rounded text-center">
                        <p class="text-xs text-muted-foreground mb-1">Total Gold</p>
                        <p class="text-lg font-bold">${totalGrams.toFixed(2)}g</p>
                    </div>
                    <div class="p-2 bg-muted rounded">
                        <p class="text-xs text-muted-foreground mb-1">Platform</p>
                        <p class="text-sm font-semibold">${gold.platform}</p>
                    </div>
                    <div class="p-2 bg-muted rounded">
                        <p class="text-xs text-muted-foreground mb-1">Current Price</p>
                        <p class="text-sm font-medium">₹${gold.currentPrice}/gram</p>
                    </div>
                </div>
            `;
        }
    },

    updateAssetData(data) {
        let totalAssets = 0;
        let totalLiabilities = 0;
        
        // Update overview cards
        if (data.bankSavings) {
            document.getElementById('bankSavingsTotal').textContent = Utils.formatCurrency(data.bankSavings.total);
            document.getElementById('bankAccountsCount').textContent = data.bankSavings.accounts || 0;
            this.renderBankSavingsDetails(data.bankSavings);
            totalAssets += data.bankSavings.total;
        }
        
        if (data.loans) {
            document.getElementById('loansTotal').textContent = Utils.formatCurrency(data.loans.total);
            document.getElementById('loansCount').textContent = data.loans.count || 0;
            this.renderLoansDetails(data.loans);
            totalLiabilities += data.loans.total;
        }
        
        if (data.assets) {
            document.getElementById('assetsTotal').textContent = Utils.formatCurrency(data.assets.total);
            document.getElementById('assetsCount').textContent = data.assets.count || 0;
            this.renderAssetsDetails(data.assets);
            totalAssets += data.assets.total;
        }
        
        if (data.mutualFunds) {
            document.getElementById('mutualFundsTotal').textContent = Utils.formatCurrency(data.mutualFunds.total);
            document.getElementById('mutualFundsCount').textContent = data.mutualFunds.count || 0;
            this.renderMutualFundsDetails(data.mutualFunds);
            totalAssets += data.mutualFunds.total;
        }
        
        if (data.stocks) {
            document.getElementById('stocksTotal').textContent = Utils.formatCurrency(data.stocks.total);
            document.getElementById('stocksCount').textContent = data.stocks.count || 0;
            this.renderStocksDetails(data.stocks);
            totalAssets += data.stocks.total;
        }
        
        if (data.digitalGold) {
            document.getElementById('digitalGoldTotal').textContent = Utils.formatCurrency(data.digitalGold.total);
            document.getElementById('digitalGoldCount').textContent = data.digitalGold.count || 0;
            this.renderDigitalGoldDetails(data.digitalGold);
            totalAssets += data.digitalGold.total;
        }
        
        // Update Net Worth Summary
        const netWorth = totalAssets - totalLiabilities;
        document.getElementById('netWorth').textContent = Utils.formatCurrency(netWorth);
        document.getElementById('totalAssets').textContent = Utils.formatCurrency(totalAssets);
        document.getElementById('totalLiabilities').textContent = Utils.formatCurrency(totalLiabilities);

        // Populate flip card details
        this.populateFlipCardDetails(data);

        // Render pie chart
        Charts.renderPieChart(data);
    }
};

