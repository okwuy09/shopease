import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Mock Notification Data
    final notifications = [
      {
        'title': 'Order Shipped!',
        'body': 'Your order #12345 has been shipped and is on its way.',
        'time': '2 mins ago',
        'isRead': false,
        'icon': Icons.local_shipping_outlined,
      },
      {
        'title': 'New Product Alert',
        'body': 'Check out the new smartwatches in our electronics section.',
        'time': '1 hour ago',
        'isRead': false,
        'icon': Icons.new_releases_outlined,
      },
      {
        'title': 'Payment Successful',
        'body': 'Your payment for order #12344 was successful.',
        'time': 'Yesterday',
        'isRead': true,
        'icon': Icons.payment_outlined,
      },
      {
        'title': 'Account Update',
        'body': 'Your profile information was successfully updated.',
        'time': '2 days ago',
        'isRead': true,
        'icon': Icons.person_outline,
      },
       {
        'title': 'System Maintenance',
        'body': 'Scheduled maintenance will occur on Sunday at 2 AM.',
        'time': '3 days ago',
        'isRead': true,
        'icon': Icons.build_circle_outlined,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black87,
        ),
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[400]),
                   const SizedBox(height: 16),
                   Text(
                     'No notifications yet',
                     style: TextStyle(
                       fontSize: 18, 
                       color: isDark ? Colors.grey[400] : Colors.grey[600],
                     ),
                   ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final isRead = notification['isRead'] as bool;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: !isRead 
                        ? (isDark ? Colors.white.withOpacity(0.05) : Colors.blue.withOpacity(0.05)) 
                        : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        notification['icon'] as IconData,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      notification['title'] as String,
                      style: TextStyle(
                        fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          notification['body'] as String,
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          notification['time'] as String,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    trailing: !isRead
                        ? Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                width: 2,
                              ),
                            ),
                          )
                        : null,
                    onTap: () {
                      // Mark as read logic would go here
                    },
                  ),
                );
              },
            ),
    );
  }
}
