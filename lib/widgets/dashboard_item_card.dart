
import 'package:flutter/material.dart';
import '../models/models.dart';

class DashboardItemCard extends StatelessWidget {
  final ItemModel item;
  final VoidCallback onTap;

  const DashboardItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine status text/color logic
    final isComplete = item.status.toLowerCase() == 'completed';
    final statusColor = isComplete 
        ? Colors.green 
        : Theme.of(context).colorScheme.secondary;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white, // White bg for product images to pop
                    borderRadius: BorderRadius.circular(8),
                    border: !isDark ? Border.all(color: Colors.grey[200]!) : null,
                    image: item.image != null 
                        ? DecorationImage(
                            image: NetworkImage(item.image!),
                            fit: BoxFit.contain, // Fit contain for products
                          )
                        : null,
                  ),
                  child: item.image == null 
                      ? const Icon(Icons.inventory_2, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 12),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.body, 
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Price, Category, Date
                      Row(
                        children: [
                          if (item.price != null) ...[
                            Text(
                              '\$${item.price!.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.greenAccent : Colors.green[700],
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          
                          // Category Chip (Compact)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white70 : Colors.black54, // Dimmer black for light mode
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.category.toUpperCase(),
                              style: TextStyle(
                                color: isDark ? Colors.black : Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          
                          const Spacer(),

                          Icon(Icons.access_time, size: 12, color: isDark ? Colors.grey[600] : Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            item.date != null 
                              ? "${item.date!.day}/${item.date!.month}/${item.date!.year}" 
                              : "No Date", 
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? Colors.grey[600] : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            

          ],
        ),
      ),
    );
  }
}
