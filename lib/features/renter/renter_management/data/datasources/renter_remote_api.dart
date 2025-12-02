class RenterRemoteApi {
  Future<List<Map<String, dynamic>>> fetchRequestedItems() async {
    return [
      {
        "id": "1",
        "name": "TMA-2HD Wireless",
        "price": "RM 20 / day",
        "rentalInfo": "2 days | Total: RM 40",
        "imageUrl": "assets/headphone.jpg",
        "status": "pending" // optional but recommended
      }
    ];
  }
}
