// Chart Management Module
const Charts = {
    assetPieChart: null,

    calculateAssetDistribution(data) {
        const distribution = {
            'Property/Real Estate': 0,
            'Cash/Savings': 0,
            'Stocks & Equity': 0,
            'Mutual Funds': 0,
            'Gold': 0,
            'Other Assets': 0
        };

        if (data.bankSavings) {
            distribution['Cash/Savings'] += data.bankSavings.total;
        }

        if (data.assets) {
            data.assets.details.forEach(asset => {
                if (asset.type === 'Property' || asset.type === 'Land') {
                    distribution['Property/Real Estate'] += asset.value;
                } else {
                    distribution['Other Assets'] += asset.value;
                }
            });
        }

        if (data.stocks) {
            distribution['Stocks & Equity'] += data.stocks.total;
        }

        if (data.mutualFunds) {
            distribution['Mutual Funds'] += data.mutualFunds.total;
        }

        if (data.digitalGold) {
            distribution['Gold'] += data.digitalGold.total;
        }

        return distribution;
    },

    renderPieChart(data) {
        const ctx = document.getElementById('assetPieChart');
        if (!ctx) return;

        const distribution = this.calculateAssetDistribution(data);
        const labels = Object.keys(distribution).filter(key => distribution[key] > 0);
        const values = labels.map(key => distribution[key]);
        
        const colors = [
            { bg: 'rgba(34, 197, 94, 0.9)', border: 'rgb(22, 163, 74)' },
            { bg: 'rgba(59, 130, 246, 0.9)', border: 'rgb(37, 99, 235)' },
            { bg: 'rgba(249, 115, 22, 0.9)', border: 'rgb(234, 88, 12)' },
            { bg: 'rgba(168, 85, 247, 0.9)', border: 'rgb(147, 51, 234)' },
            { bg: 'rgba(234, 179, 8, 0.9)', border: 'rgb(202, 138, 4)' },
            { bg: 'rgba(107, 114, 128, 0.9)', border: 'rgb(75, 85, 99)' }
        ];

        if (this.assetPieChart) {
            this.assetPieChart.destroy();
        }

        this.assetPieChart = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: labels,
                datasets: [{
                    data: values,
                    backgroundColor: colors.slice(0, labels.length).map(c => c.bg),
                    borderColor: colors.slice(0, labels.length).map(c => c.border),
                    borderWidth: 3,
                    hoverBorderWidth: 4,
                    hoverOffset: 8
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                cutout: '65%',
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        backgroundColor: 'rgba(0, 0, 0, 0.8)',
                        padding: 12,
                        titleFont: { size: 14, weight: '600' },
                        bodyFont: { size: 13 },
                        callbacks: {
                            label: (context) => {
                                const label = context.label || '';
                                const value = context.parsed || 0;
                                const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                const percentage = ((value / total) * 100).toFixed(1);
                                return [`${label}`, `${Utils.formatCurrency(value)}`, `${percentage}% of total`];
                            }
                        },
                        displayColors: true,
                        boxPadding: 6
                    }
                },
                animation: {
                    animateRotate: true,
                    animateScale: true,
                    duration: 1000,
                    easing: 'easeOutQuart'
                },
                interaction: {
                    intersect: false,
                    mode: 'nearest'
                }
            }
        });

        // Render Legend
        const legendContainer = document.getElementById('pieChartLegend');
        const total = values.reduce((a, b) => a + b, 0);
        
        let legendHtml = '<div class="space-y-3">';
        labels.forEach((label, index) => {
            const value = distribution[label];
            const percentage = ((value / total) * 100).toFixed(1);
            const color = colors[index];
            
            legendHtml += `
                <div class="group p-4 bg-muted/50 rounded-lg border border-transparent hover:border-primary/20 hover:bg-muted transition-all cursor-pointer">
                    <div class="flex items-center justify-between mb-2">
                        <div class="flex items-center gap-3">
                            <div class="w-4 h-4 rounded-full shadow-sm" style="background: linear-gradient(135deg, ${color.bg}, ${color.border})"></div>
                            <span class="text-sm font-semibold text-foreground">${label}</span>
                        </div>
                        <span class="text-sm font-bold">${percentage}%</span>
                    </div>
                    <div class="flex items-center justify-between">
                        <p class="text-xs text-muted-foreground">Value</p>
                        <p class="text-sm font-semibold">${Utils.formatCurrency(value)}</p>
                    </div>
                    <div class="mt-2 w-full bg-secondary rounded-full h-1.5 overflow-hidden">
                        <div class="h-full rounded-full transition-all duration-500" style="width: ${percentage}%; background: linear-gradient(90deg, ${color.bg}, ${color.border})"></div>
                    </div>
                </div>
            `;
        });
        legendHtml += '</div>';
        legendContainer.innerHTML = legendHtml;
    }
};

