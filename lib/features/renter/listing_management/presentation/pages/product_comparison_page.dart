import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../../core/utils/loading.dart'; 
import '../../models/rental_analytics.dart';
import '../../services/rental_service.dart'; 

class ProductComparisonPage extends StatefulWidget {
  final String productId1;
  final String productName1;
  final String productId2;
  final String productName2;

  const ProductComparisonPage({
    super.key,
    required this.productId1,
    required this.productName1,
    required this.productId2,
    required this.productName2,
  });

  @override
  State<ProductComparisonPage> createState() => _ProductComparisonPageState();
}

class _ProductComparisonPageState extends State<ProductComparisonPage> {
  final RentalService _rentalService = RentalService();
  bool isLoading = true;
  
  // Use 'RentalAnalytics'
  RentalAnalytics? data1;
  RentalAnalytics? data2;

  @override
  void initState() {
    super.initState();
    _fetchComparisonData();
  }

  Future<void> _fetchComparisonData() async {
    try {
      // THIN CLIENT: We just ask for the final numbers.
      final result1 = await _rentalService.getRentalAnalytics(widget.productId1);
      final result2 = await _rentalService.getRentalAnalytics(widget.productId2);

      if (mounted) {
        setState(() {
          data1 = result1;
          data2 = result2;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching comparison: $e");
      // Optional: Handle error state here
    }
  }

  @override
  Widget build(BuildContext context) {
    // Re-use your shared Loading widget
    if (isLoading) return const Loading(); 

    return Scaffold(
      appBar: AppBar(title: const Text("Product Comparison")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Legend (Color Key)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegend(Colors.blue, widget.productName1),
                const SizedBox(width: 20),
                _buildLegend(Colors.red, widget.productName2),
              ],
            ),
            const SizedBox(height: 40),
            
            // The Bar Chart
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxY(), // Dynamic height scaling
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, meta) {
                         return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
                      }),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0: return const Text('Earnings\n(RM)', textAlign: TextAlign.center);
                            case 1: return const Text('Orders\n(Count)', textAlign: TextAlign.center);
                            case 2: return const Text('Duration\n(Days)', textAlign: TextAlign.center);
                            default: return const Text('');
                          }
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  barGroups: [
                    // Group 0: Total Earnings
                    _makeGroupData(0, data1!.totalEarnings.toDouble(), data2!.totalEarnings.toDouble()),
                    // Group 1: Total Orders
                    _makeGroupData(1, data1!.totalOrders.toDouble(), data2!.totalOrders.toDouble()),
                    // Group 2: Total Duration
                    _makeGroupData(2, data1!.totalDuration.toDouble(), data2!.totalDuration.toDouble()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getMaxY() {
    double max = 0;
    // Simple logic to ensure the chart is tall enough
    for (var d in [data1!, data2!]) {
      if (d.totalEarnings > max) max = d.totalEarnings.toDouble();
      if (d.totalOrders > max) max = d.totalOrders.toDouble();
      if (d.totalDuration > max) max = d.totalDuration.toDouble();
    }
    return max == 0 ? 10 : max * 1.2; // Add 20% buffer, or default to 10 if empty
  }

  BarChartGroupData _makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(toY: y1, color: Colors.blue, width: 15, borderRadius: BorderRadius.circular(4)),
        BarChartRodData(toY: y2, color: Colors.red, width: 15, borderRadius: BorderRadius.circular(4)),
      ],
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}