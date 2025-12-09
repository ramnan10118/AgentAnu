import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/asset_model.dart';
import '../utils/constants.dart';

class AssetPieChart extends StatelessWidget {
  final List<AssetModel> assets;

  const AssetPieChart({super.key, required this.assets});

  Map<String, double> _calculateDistribution() {
    final distribution = <String, double>{};
    
    for (var asset in assets) {
      final category = _getAssetCategory(asset.type);
      distribution[category] = (distribution[category] ?? 0) + asset.value;
    }
    
    return distribution;
  }

  String _getAssetCategory(String type) {
    switch (type) {
      case 'bank_account':
      case 'fd':
        return 'Cash/Savings';
      case 'mutual_fund':
        return 'Mutual Funds';
      case 'securities':
      case 'stocks':
        return 'Stocks & Equity';
      case 'insurance':
        return 'Insurance';
      case 'nps':
        return 'NPS';
      case 'property':
      case 'real_estate':
        return 'Property/Real Estate';
      default:
        return 'Other Assets';
    }
  }

  List<PieChartSectionData> _buildSections(Map<String, double> distribution) {
    final total = distribution.values.fold(0.0, (sum, value) => sum + value);
    if (total == 0) return [];

    final colors = [
      const Color(0xFF22C55E), // Property - Green
      const Color(0xFF3B82F6), // Cash - Blue
      const Color(0xFFF97316), // Stocks - Orange
      const Color(0xFFA855F7), // Mutual Funds - Purple
      const Color(0xFFEAB308), // Gold - Yellow
      const Color(0xFF6B7280), // Other - Gray
    ];

    final categories = distribution.keys.toList();
    final sections = <PieChartSectionData>[];

    for (int i = 0; i < categories.length; i++) {
      final category = categories[i];
      final value = distribution[category]!;
      final percentage = (value / total * 100);
      final color = colors[i % colors.length];

      sections.add(
        PieChartSectionData(
          value: value,
          title: percentage > 5 ? '${percentage.toStringAsFixed(0)}%' : '',
          color: color,
          radius: 70,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return sections;
  }

  @override
  Widget build(BuildContext context) {
    if (assets.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final distribution = _calculateDistribution();
    
    if (distribution.isEmpty) {
      return const SizedBox.shrink();
    }

    final sections = _buildSections(distribution);
    if (sections.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final categories = distribution.keys.toList();

    return Card(
      elevation: 2,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMD),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Asset Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMD),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                double chartSize;
                if (isWide) {
                  chartSize = (constraints.maxWidth * 0.35);
                  if (chartSize < 150) chartSize = 150;
                  if (chartSize > 220) chartSize = 220;
                } else {
                  chartSize = constraints.maxWidth * 0.7;
                  if (chartSize < 150) chartSize = 150;
                  if (chartSize > 200) chartSize = 200;
                }
                final centerSpaceRadius = chartSize * 0.3;
                
                if (isWide) {
                  // Wide layout: Chart and legend side by side
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pie Chart - Flexible width
                      Flexible(
                        flex: 2,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: PieChart(
                            PieChartData(
                              sections: sections,
                              sectionsSpace: 2,
                              centerSpaceRadius: centerSpaceRadius,
                              startDegreeOffset: -90,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingLG),
                      // Legend - Flexible width
                      Flexible(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: categories.asMap().entries.map((entry) {
                            final index = entry.key;
                            final category = entry.value;
                            final value = distribution[category]!;
                            final total = distribution.values.fold(0.0, (sum, v) => sum + v);
                            final percentage = (value / total * 100);
                            
                            final colors = [
                              const Color(0xFF22C55E),
                              const Color(0xFF3B82F6),
                              const Color(0xFFF97316),
                              const Color(0xFFA855F7),
                              const Color(0xFFEAB308),
                              const Color(0xFF6B7280),
                            ];
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppConstants.spacingSM),
                              child: Row(
                                children: [
                                  Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: colors[index % colors.length],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: AppConstants.spacingSM),
                                  Expanded(
                                    child: Text(
                                      category,
                                      style: const TextStyle(fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      '₹${value.toStringAsFixed(0).replaceAllMapped(
                                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                        (Match m) => '${m[1]},',
                                      )} (${percentage.toStringAsFixed(1)}%)',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.right,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  );
                } else {
                  // Narrow layout: Chart centered, legend below
                  return Column(
                    children: [
                      Center(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: chartSize,
                              maxHeight: chartSize,
                            ),
                            child: PieChart(
                              PieChartData(
                                sections: sections,
                                sectionsSpace: 2,
                                centerSpaceRadius: centerSpaceRadius,
                                startDegreeOffset: -90,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingMD),
                      // Legend
                      ...categories.asMap().entries.map((entry) {
                        final index = entry.key;
                        final category = entry.value;
                        final value = distribution[category]!;
                        final total = distribution.values.fold(0.0, (sum, v) => sum + v);
                        final percentage = (value / total * 100);
                        
                        final colors = [
                          const Color(0xFF22C55E),
                          const Color(0xFF3B82F6),
                          const Color(0xFFF97316),
                          const Color(0xFFA855F7),
                          const Color(0xFFEAB308),
                          const Color(0xFF6B7280),
                        ];
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppConstants.spacingSM),
                          child: Row(
                            children: [
                              Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: colors[index % colors.length],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: AppConstants.spacingSM),
                              Expanded(
                                child: Text(
                                  category,
                                  style: const TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  '₹${value.toStringAsFixed(0).replaceAllMapped(
                                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                    (Match m) => '${m[1]},',
                                  )} (${percentage.toStringAsFixed(1)}%)',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.right,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
