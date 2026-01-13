import 'package:flutter/material.dart';
import '../../services/renter_service.dart';
import '../../models/booking_model.dart';
import '../../widgets/renter/renter_order_card.dart'; // <--- Import Widget

class RenterOrdersPage extends StatelessWidget {
  const RenterOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final RenterService service = RenterService();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text("Incoming Orders"),
          backgroundColor: const Color(0xFF800000),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "Requests"),
              Tab(text: "Active & History"),
            ],
          ),
        ),
        body: StreamBuilder<List<BookingModel>>(
          stream: service.getRenterOrdersStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No orders yet"));
            }

            final orders = snapshot.data!;
            final requests = orders
                .where((o) => o.status == 'pending')
                .toList();
            final activeHistory = orders
                .where((o) => o.status != 'pending')
                .toList();

            return TabBarView(
              children: [
                _buildOrderList(requests, service, isRequest: true),
                _buildOrderList(activeHistory, service, isRequest: false),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderList(
    List<BookingModel> orders,
    RenterService service, {
    required bool isRequest,
  }) {
    if (orders.isEmpty) {
      return const Center(child: Text("No orders in this category"));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return RenterOrderCard(
          order: orders[index],
          service: service,
          isRequestTab: isRequest,
        );
      },
    );
  }
}
