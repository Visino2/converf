import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../features/profile/models/profile_models.dart';
import '../../../../../features/profile/providers/profile_providers.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  NotificationSettings? _localSettings;
  bool _hasChanges = false;

  void _onToggle(String key, bool value, NotificationSettings current) {
    final Map<String, dynamic> json = current.toJson();
    json[key] = value;
    setState(() {
      _localSettings = NotificationSettings.fromJson(json);
      _hasChanges = true;
    });
  }

  Future<void> _saveChanges() async {
    if (_localSettings == null) return;
    
    try {
      await ref.read(profileNotifierProvider.notifier).updateNotificationSettings(_localSettings!.toJson());
      setState(() => _hasChanges = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification settings updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update settings: $e')),
        );
      }
    }
  }

  Widget _buildToggle(bool value, ValueChanged<bool> onChanged) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeThumbColor: const Color(0xFF276572),
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
    final settingsAsync = ref.watch(notificationSettingsProvider);
    final actionState = ref.watch(profileNotifierProvider);

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
      body: settingsAsync.when(
        data: (remoteSettings) {
          final settings = _localSettings ?? remoteSettings;
          
          return SingleChildScrollView(
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
                      _buildToggleRow('Critical Quality Score Drops',
                          settings.qualityScoreAlerts ?? false, (v) => _onToggle('quality_score_alerts', v, settings)),
                      const Divider(color: Color(0xFFE5E7EB), height: 1),
                      _buildToggleRow('Phase Completion Approvals',
                          settings.milestoneCompletions ?? false, (v) => _onToggle('milestone_completions', v, settings)),
                      const Divider(color: Color(0xFFE5E7EB), height: 1),
                      _buildToggleRow('Ball-in-courts Notifications',
                          settings.ballInCourtUpdates, (v) => _onToggle('ball_in_court_updates', v, settings)),
                      const Divider(color: Color(0xFFE5E7EB), height: 1),
                      _buildToggleRow('New Bids Alerts',
                          settings.newBids ?? false, (v) => _onToggle('new_bids', v, settings)),
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
                      _buildToggleRow('Email Notifications',
                          settings.emailNotifications, (v) => _onToggle('email_notifications', v, settings)),
                      const Divider(color: Color(0xFFE5E7EB), height: 1),
                      _buildToggleRow('New Messages',
                          settings.newMessages, (v) => _onToggle('new_messages', v, settings)),
                      const Divider(color: Color(0xFFE5E7EB), height: 1),
                      _buildToggleRow('Push Notifications',
                          settings.pushNotifications ?? false, (v) => _onToggle('push_notifications', v, settings)),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _hasChanges && !actionState.isLoading ? _saveChanges : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _hasChanges ? const Color(0xFF2A8090) : const Color(0xFFD1D5DB),
                      disabledBackgroundColor: const Color(0xFFD1D5DB),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: actionState.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _hasChanges ? Colors.white : Colors.white70,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
