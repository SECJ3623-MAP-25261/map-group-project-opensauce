import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/renter_service.dart';
import '../../widgets/dashboard/stat_card.dart';
import '../../widgets/dashboard/earnings_chart.dart';

class RenterHomePage extends StatefulWidget {
  const RenterHomePage({super.key});

  @override
  State<RenterHomePage> createState() => _RenterHomePageState();
}

class _RenterHomePageState extends State<RenterHomePage> {
  final RenterService _service = RenterService();
  late Future<Map<String, dynamic>> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _service.getDashboardStats();
  }

  Future<void> _refresh() async {
    setState(() {
      _dashboardFuture = _service.getDashboardStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: const Color(0xFF800000),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Removed Notification Icon
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: const Color(0xFF800000),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _dashboardFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            final data = snapshot.data!;
            final double earnings = data['totalEarnings'];
            final int pending = data['pendingCount'];
            final int active = data['activeCount'];
            final int completed = data['completedCount'];
            final List<Map<String, dynamic>> chartData = data['chartData'];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. WELCOME BANNER
                  const Text(
                    "Overview",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // 2. STATS GRID
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.3,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      StatCard(
                        title: "Total Earnings",
                        value: NumberFormat.currency(
                          symbol: "RM ",
                        ).format(earnings),
                        icon: Icons.monetization_on,
                        color: Colors.green,
                      ),
                      StatCard(
                        title: "Active Rentals",
                        value: active.toString(),
                        icon: Icons.sync,
                        color: Colors.blue,
                      ),
                      StatCard(
                        title: "Pending Requests",
                        value: pending.toString(),
                        icon: Icons.pending_actions,
                        color: Colors.orange,
                      ),
                      StatCard(
                        title: "Completed Orders",
                        value: completed.toString(),
                        icon: Icons.check_circle_outline,
                        color: Colors.grey,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 3. EARNINGS CHART
                  EarningsChart(chartData: chartData),

                  const SizedBox(height: 24),

                  // 4. QUICK TIP / BOTTOM AREA
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF800000).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF800000).withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          color: Color(0xFF800000),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            pending > 0
                                ? "You have $pending pending requests. Check your orders!"
                                : "No pending actions. Great job keeping up!",
                            style: const TextStyle(color: Color(0xFF800000)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
