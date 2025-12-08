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
                maintainAspectRatio: false,
                aspectRatio: 1,
                cutout: '70%',
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        backgroundColor: 'rgba(0, 0, 0, 0.8)',
                        padding: 8,
                        titleFont: { size: 12, weight: '600' },
                        bodyFont: { size: 11 },
                        callbacks: {
                            label: (context) => {
                                const label = context.label || '';
                                const value = context.parsed || 0;
                                const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                const percentage = ((value / total) * 100).toFixed(1);
                                return [`${label}`, `${Utils.formatCurrency(value)}`, `${percentage}%`];
                            }
                        },
                        displayColors: true,
                        boxPadding: 4
                    }
                },
                animation: {
                    animateRotate: true,
                    animateScale: false,
                    duration: 600
                },
                interaction: {
                    intersect: false,
                    mode: 'nearest'
                }
            }
        });

        // Render Compact Legend
        const legendContainer = document.getElementById('pieChartLegend');
        const total = values.reduce((a, b) => a + b, 0);
        
        let legendHtml = '<div class="space-y-2">';
        labels.forEach((label, index) => {
            const value = distribution[label];
            const percentage = ((value / total) * 100).toFixed(1);
            const color = colors[index];
            
            legendHtml += `
                <div class="flex items-center justify-between p-2 bg-gray-50 rounded border border-gray-200">
                    <div class="flex items-center gap-2 flex-1 min-w-0">
                        <div class="w-3 h-3 rounded-full flex-shrink-0" style="background: ${color.bg}"></div>
                        <span class="text-xs font-medium text-gray-900 truncate">${label}</span>
                    </div>
                    <div class="flex items-center gap-2 flex-shrink-0 ml-2">
                        <span class="text-xs font-semibold text-gray-700">${percentage}%</span>
                        <span class="text-xs font-semibold text-gray-900">${Utils.formatCurrency(value)}</span>
                    </div>
                </div>
            `;
        });
        legendHtml += '</div>';
        legendContainer.innerHTML = legendHtml;
    }
};

