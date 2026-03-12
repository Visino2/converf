import 'package:flutter/material.dart';


class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Project Intelligence toggles
  bool _criticalQuality = false;
  bool _phaseCompletion = false;
  bool _ballInCourts = false;
  bool _budgetThreshold = false;

  // Platform Communication toggles
  bool _dailySummary = false;
  bool _featureAnnouncements = false;
  bool _securityAlerts = false;

  Widget _buildToggle(bool value, ValueChanged<bool> onChanged) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF276572),
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: const Color(0xFFE5E7EB),
    );
  }

  Widget _buildToggleRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
              ),
            ),
          ),
          _buildToggle(value, onChanged),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Project Highlights',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Control your correspondence flow and project updates',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 8, bottom: 4),
                    child: Text(
                      'Project Intelligence',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  const Divider(color: Color(0xFFE5E7EB)),
                  _buildToggleRow('Critcical Quality Score Drops (>10%)',
                      _criticalQuality, (v) => setState(() => _criticalQuality = v)),
                  const Divider(color: Color(0xFFE5E7EB), height: 1),
                  _buildToggleRow('Phase Completion Approvals',
                      _phaseCompletion, (v) => setState(() => _phaseCompletion = v)),
                  const Divider(color: Color(0xFFE5E7EB), height: 1),
                  _buildToggleRow('Ball-in-courts Transfer Notifications',
                      _ballInCourts, (v) => setState(() => _ballInCourts = v)),
                  const Divider(color: Color(0xFFE5E7EB), height: 1),
                  _buildToggleRow('Budget Threshold Alerts (80%)',
                      _budgetThreshold, (v) => setState(() => _budgetThreshold = v)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 8, bottom: 4),
                    child: Text(
                      'Platform Communication',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  const Divider(color: Color(0xFFE5E7EB)),
                  _buildToggleRow('Daily Project Summary Digest',
                      _dailySummary, (v) => setState(() => _dailySummary = v)),
                  const Divider(color: Color(0xFFE5E7EB), height: 1),
                  _buildToggleRow('Converf Feature Announcememnts',
                      _featureAnnouncements, (v) => setState(() => _featureAnnouncements = v)),
                  const Divider(color: Color(0xFFE5E7EB), height: 1),
                  _buildToggleRow('Security and Access Alerts',
                      _securityAlerts, (v) => setState(() => _securityAlerts = v)),
                ],
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A8090),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
