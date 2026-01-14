import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class RevenueGraphPopup extends StatefulWidget {
  final String itemId;
  const RevenueGraphPopup({super.key, required this.itemId});

  @override
  State<RevenueGraphPopup> createState() => _RevenueGraphPopupState();
}

class _RevenueGraphPopupState extends State<RevenueGraphPopup> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _chartData = []; // Stores {date, amount}

  @override
  void initState() {
    super.initState();
    _fetchChartData();
  }

  Future<void> _fetchChartData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('itemId', isEqualTo: widget.itemId)
          .where('status', isEqualTo: 'approved')
          .orderBy('startDate', descending: false)
          .get();

      // 1. Group Data by Date
      Map<String, double> groupedData = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final timestamp = data['startDate'] as Timestamp?;

        // --- FIX: Use 'rentalPrice' instead of 'totalPrice' ---
        final price = (data['rentalPrice'] ?? 0).toDouble();
        // -----------------------------------------------------

        if (timestamp != null && price > 0) {
          String dateLabel = DateFormat('MM/dd').format(timestamp.toDate());

          if (groupedData.containsKey(dateLabel)) {
            groupedData[dateLabel] = groupedData[dateLabel]! + price;
          } else {
            groupedData[dateLabel] = price;
          }
        }
      }

      // 2. Convert to List
      setState(() {
        _chartData = groupedData.entries
            .map((e) => {'date': e.key, 'amount': e.value})
            .toList();

        // Limit to last 7 entries for readability
        if (_chartData.length > 7) {
          _chartData = _chartData.sublist(_chartData.length - 7);
        }

        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Graph Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Revenue Trend",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Text(
              "Earnings per day (Completed Bookings)",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 30),

            // Chart Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _chartData.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bar_chart, size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            "No revenue data yet",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : BarChart(
                      BarChartData(
                        barGroups: _buildBarGroups(),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                int index = value.toInt();
                                if (index >= 0 && index < _chartData.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      _chartData[index]['date'],
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                        ),
                        gridData: const FlGridData(show: false),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(_chartData.length, (index) {
      final amount = _chartData[index]['amount'] as double;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: amount,
            color: const Color(0xFF800000),
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _getMaxY(),
              color: Colors.grey.shade100,
            ),
          ),
        ],
        showingTooltipIndicators: [0],
      );
    });
  }

  double _getMaxY() {
    double max = 0;
    for (var item in _chartData) {
      if (item['amount'] > max) max = item['amount'];
    }
    return max == 0 ? 100 : max * 1.2; // Avoid 0 height if max is 0
  }
}
