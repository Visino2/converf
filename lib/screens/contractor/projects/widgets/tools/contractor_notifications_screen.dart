import 'package:flutter/material.dart';

class ContractorNotificationsScreen extends StatefulWidget {
  const ContractorNotificationsScreen({super.key});

  @override
  State<ContractorNotificationsScreen> createState() => _ContractorNotificationsScreenState();
}

class _ContractorNotificationsScreenState extends State<ContractorNotificationsScreen> {
  final Map<String, bool> _notificationSettings = {
    'New Project Matches': false,
    'Payment Received': false,
    'New Client Messages': false,
    'Quality Score Alerts': false,
    'Ball-in-court': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Email & Push Notifications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      _buildNotificationItem(
                        'New Project Matches',
                        'ALerts when a project matching your skills is posted',
                      ),
                      _buildNotificationItem(
                        'Payment Received',
                        'Notification for successful invoice payouts',
                      ),
                      _buildNotificationItem(
                        'New Client Messages',
                        'Instant alerts for direct messages and bid discussions',
                      ),
                      _buildNotificationItem(
                        'Quality Score Alerts',
                        'Updates regarding your quality score and inspections.',
                      ),
                      _buildNotificationItem(
                        'Ball-in-court',
                        'When a project phase requires your immediate action.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: _notificationSettings[title] ?? false,
            onChanged: (v) => setState(() => _notificationSettings[title] = v),
            activeColor: const Color(0xFF276572),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFE5E7EB),
          ),
        ],
      ),
    );
  }
}
