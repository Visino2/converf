import 'package:flutter/material.dart';

class ContractorProjectSettingsScreen extends StatefulWidget {
  const ContractorProjectSettingsScreen({super.key});

  @override
  State<ContractorProjectSettingsScreen> createState() => _ContractorProjectSettingsScreenState();
}

class _ContractorProjectSettingsScreenState extends State<ContractorProjectSettingsScreen> {
  final Map<String, bool> _settings = {
    'Public Profile Visibility': false,
    'Show Earnings': false,
    'Show Active Project Count': false,
    'Quality Score Alerts': false,
    'Anonymous Bidding': false,
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
          'Project Settings',
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
                'Visibility & Public Profile',
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
                      _buildSettingItem(
                        'Public Profile Visibility',
                        'Allow Project owners to find you in marketplace directory',
                      ),
                      _buildSettingItem(
                        'Show Earnings',
                        'Display total earnings on your public profile cards.',
                      ),
                      _buildSettingItem(
                        'Show Active Project Count',
                        'Instant alerts for direct messages and bid discussions',
                      ),
                      _buildSettingItem(
                        'Quality Score Alerts',
                        'Display how many projects you are currently managing.',
                      ),
                      _buildSettingItem(
                        'Anonymous Bidding',
                        'Hide your company name during the initial bidding phase.',
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

  Widget _buildSettingItem(String title, String subtitle) {
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
            value: _settings[title] ?? false,
            onChanged: (v) => setState(() => _settings[title] = v),
            activeColor: const Color(0xFF276572),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFE5E7EB),
          ),
        ],
      ),
    );
  }
}
