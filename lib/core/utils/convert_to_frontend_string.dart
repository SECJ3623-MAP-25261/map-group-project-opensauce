String convertToFrontendString (String status) {
  switch (status) {
    // Pre-Fulfillment
    case 'pending_payment':
      return 'Pending Payment';
    case 'processing':
      return 'Processing Order';
    case 'cancelled':
      return 'Cancelled';

    // Fulfillment
    case 'ready_for_pickup':
      return 'Ready for Pickup';
    case 'in_transit':
      return 'In Transit';
    case 'delivered':
      return 'Delivered';

    // Post-Fulfillment
    case 'returned':
      return 'Returned';
    case 'issues_report':
      return 'Issue Reported';

    default:
      // A fallback for any unknown or new status from the database.
      return 'Unknown Status';
  }
}