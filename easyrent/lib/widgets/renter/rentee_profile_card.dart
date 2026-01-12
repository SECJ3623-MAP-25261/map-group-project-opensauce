import 'package:flutter/material.dart';
import '../../services/renter_service.dart';

class RenteeProfileCard extends StatefulWidget {
  final String renteeId;
  final bool isLoadingChat;
  final Function(String name) onMessageTap;

  const RenteeProfileCard({
    super.key,
    required this.renteeId,
    required this.isLoadingChat,
    required this.onMessageTap,
  });

  @override
  State<RenteeProfileCard> createState() => _RenteeProfileCardState();
}

class _RenteeProfileCardState extends State<RenteeProfileCard> {
  late Future<Map<String, dynamic>> _profileFuture;
  final RenterService _service = RenterService();

  @override
  void initState() {
    super.initState();
    _profileFuture = _service.getUserProfile(widget.renteeId);
  }

  @override
  void didUpdateWidget(covariant RenteeProfileCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.renteeId != oldWidget.renteeId) {
      _profileFuture = _service.getUserProfile(widget.renteeId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _profileFuture,
      builder: (context, snapshot) {
        String renteeName = "";
        String renteeImage = "";

        if (snapshot.connectionState == ConnectionState.waiting) {
          renteeName = "Loading...";
        } else if (snapshot.hasData) {
          renteeName =
              snapshot.data!['name'] ??
              snapshot.data!['username'] ??
              "Unknown Rentee";
          renteeImage = snapshot.data!['profileImage'] ?? "";
        } else {
          renteeName = "Unknown Rentee";
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.grey[200],
                backgroundImage: renteeImage.isNotEmpty
                    ? NetworkImage(renteeImage)
                    : null,
                child: renteeImage.isEmpty
                    ? const Icon(Icons.person, size: 35, color: Colors.grey)
                    : null,
              ),
              const SizedBox(height: 8),
              Text(
                renteeName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Rentee",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: widget.isLoadingChat
                    ? const Center(
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : OutlinedButton.icon(
                        onPressed: () => widget.onMessageTap(
                          renteeName == "Loading..." ? "Rentee" : renteeName,
                        ),
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text("Message Rentee"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF800000),
                          side: const BorderSide(color: Color(0xFF800000)),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
