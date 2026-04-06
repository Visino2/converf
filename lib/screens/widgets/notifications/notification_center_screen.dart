import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../features/auth/models/auth_response.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/notifications/models/notification_models.dart';
import '../../../features/notifications/providers/notification_providers.dart';
import '../../../features/notifications/services/notification_lifecycle_service.dart';
import '../../../features/profile/models/profile_models.dart';
import '../../../features/profile/providers/profile_providers.dart';
import '../../../features/projects/providers/project_providers.dart';
import '../../product_owner/widgets/dashboard/messages/message_details_screen.dart';
import '../../product_owner/widgets/dashboard/messages/project_inbox_screen.dart';

class NotificationCenterScreen extends ConsumerStatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  ConsumerState<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState
    extends ConsumerState<NotificationCenterScreen> {
  int _selectedTabIndex = 0;
  bool _showUnreadOnly = false;
  NotificationSettings? _localSettings;
  bool _hasChanges = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        debugPrint('[Notifications] Auto-refreshing notifications...');
        ref.invalidate(notificationsProvider(false));
        ref.invalidate(notificationsProvider(true));
        ref.invalidate(unreadNotificationsCountProvider);
        ref.invalidate(unreadMessageNotificationsCountProvider);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _onToggle(String key, bool value, NotificationSettings current) {
    final updated = current.toJson();
    updated[key] = value;
    setState(() {
      _localSettings = NotificationSettings.fromJson(updated);
      _hasChanges = true;
    });
  }

  Future<void> _saveChanges(NotificationSettings remoteSettings) async {
    final localSettings = _localSettings;
    if (localSettings == null) return;

    final previousPushState = remoteSettings.pushNotifications ?? false;
    final nextPushState = localSettings.pushNotifications ?? false;
    final supportsNativePush = ref.read(nativePushSupportedProvider);

    try {
      await ref
          .read(profileNotifierProvider.notifier)
          .updateNotificationSettings(localSettings.toJson());

      if (previousPushState != nextPushState) {
        final lifecycle = ref.read(notificationLifecycleProvider);
        if (!nextPushState) {
          await lifecycle.unregisterCurrentDeviceToken();
        }
      }

      if (mounted) {
        setState(() => _hasChanges = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              nextPushState && !supportsNativePush
                  ? 'Settings updated. Realtime in-app alerts are active; device push is not configured on this build.'
                  : 'Notification settings updated successfully',
            ),
          ),
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final notificationActionState = ref.watch(notificationActionProvider);
    final supportsNativePush = ref.watch(nativePushSupportedProvider);
    final role = authState.asData?.value?.role ?? UserRole.unknown;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
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
        actions: [
          if (_selectedTabIndex == 0)
            TextButton(
              onPressed: notificationActionState.isLoading
                  ? null
                  : () async {
                      try {
                        await ref
                            .read(notificationActionProvider.notifier)
                            .markAllRead();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('All notifications marked as read'),
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to mark all as read: $e'),
                          ),
                        );
                      }
                    },
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: _buildTabSelector(),
            ),
            Expanded(
              child: IndexedStack(
                index: _selectedTabIndex,
                children: [
                  _buildInboxTab(),
                  _buildPreferencesTab(role, supportsNativePush),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTabButton(label: 'Inbox', index: 0)),
          Expanded(child: _buildTabButton(label: 'Preferences', index: 1)),
        ],
      ),
    );
  }

  Widget _buildTabButton({required String label, required int index}) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? const Color(0xFF111827)
                : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _buildInboxTab() {
    final notificationsAsync = ref.watch(
      notificationsProvider(_showUnreadOnly),
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Activity',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  Text(
                    _showUnreadOnly
                        ? 'Showing unread notifications only'
                        : 'Showing all notifications',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              FilterChip(
                selected: _showUnreadOnly,
                label: const Text('Unread only'),
                onSelected: (selected) =>
                    setState(() => _showUnreadOnly = selected),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: notificationsAsync.when(
            loading: () => notificationsAsync.hasValue
                ? _buildNotificationList(notificationsAsync.value!)
                : const Center(
                    child: CircularProgressIndicator(color: Color(0xFF276572)),
                  ),
            error: (error, stackTrace) =>
                Center(child: Text('Failed to load notifications: $error')),
            data: (notifications) => _buildNotificationList(notifications),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationList(List<AppNotification> notifications) {
    if (notifications.isEmpty) {
      return _buildEmptyInbox();
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(notificationsProvider(false));
        ref.invalidate(notificationsProvider(true));
        await ref.read(notificationsProvider(_showUnreadOnly).future);
      },
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) =>
            _buildNotificationCard(notifications[index]),
      ),
    );
  }

  Widget _buildEmptyInbox() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: const [
        SizedBox(height: 80),
        Icon(
          Icons.notifications_none_rounded,
          size: 56,
          color: Color(0xFF98A2B3),
        ),
        SizedBox(height: 16),
        Text(
          'No notifications yet',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        SizedBox(height: 8),
        Text(
          'When messages and updates arrive, they will appear here.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    final createdText = notification.createdAt != null
        ? DateFormat('MMM d, h:mm a').format(notification.createdAt!.toLocal())
        : 'Just now';

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _handleNotificationTap(notification),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isUnread ? const Color(0xFFF5FAFB) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: notification.isUnread
                ? const Color(0xFFB7E7EA)
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: notification.isUnread
                    ? const Color(0xFF309DAA)
                    : const Color(0xFFD0D5DD),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        createdText,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification.body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleNotificationTap(AppNotification notification) async {
    if (notification.isUnread) {
      try {
        await ref
            .read(notificationActionProvider.notifier)
            .markRead(notification.id);
      } catch (_) {}
    }

    if (!mounted) return;

    if (notification.isMessageNotification) {
      await _openMessageNotification(notification);
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: Text(notification.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _openMessageNotification(AppNotification notification) async {
    final projectId = notification.projectId;
    if (projectId != null && projectId.isNotEmpty) {
      try {
        final projectResponse = await ref.read(
          projectDetailsProvider(projectId).future,
        );
        final project = projectResponse.data;
        if (project != null && mounted) {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MessageDetailsScreen(project: project),
            ),
          );
          return;
        }
      } catch (_) {}
    }

    if (!mounted) return;
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ProjectInboxScreen()));
  }

  Widget _buildPreferencesTab(UserRole role, bool supportsNativePush) {
    final settingsAsync = ref.watch(notificationSettingsProvider);
    final profileActionState = ref.watch(profileNotifierProvider);

    return settingsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFF276572)),
      ),
      error: (error, stackTrace) =>
          Center(child: Text('Failed to load notification settings: $error')),
      data: (remoteSettings) {
        final settings = _localSettings ?? remoteSettings;
        final sections = _buildPreferenceSections(role, settings);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Preferences',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Control how you receive platform and project updates.',
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
              if (!supportsNativePush) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD5E3EA)),
                  ),
                  child: const Text(
                    'Realtime message and activity alerts work while the app is open. Background device push is not enabled on this build yet.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: Color(0xFF475467),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              ...sections,
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _hasChanges && !profileActionState.isLoading
                      ? () => _saveChanges(remoteSettings)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF276572),
                    disabledBackgroundColor: const Color(0xFFD1D5DB),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: profileActionState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildPreferenceSections(
    UserRole role,
    NotificationSettings settings,
  ) {
    final sections = role == UserRole.contractor
        ? [
            _NotificationPreferenceSectionData(
              title: 'Project Opportunities',
              items: [
                (
                  'New Project Matches',
                  settings.newProjectMatches ?? false,
                  'new_project_matches',
                ),
                (
                  'Bid Status Updates',
                  settings.bidStatusUpdates ?? false,
                  'bid_status_updates',
                ),
                (
                  'Payment Received',
                  settings.paymentReceived ?? false,
                  'payment_received',
                ),
                (
                  'Quality Score Alerts',
                  settings.qualityScoreAlerts ?? false,
                  'quality_score_alerts',
                ),
                (
                  'Ball-in-court Notifications',
                  settings.ballInCourtUpdates,
                  'ball_in_court_updates',
                ),
              ],
            ),
            _NotificationPreferenceSectionData(
              title: 'Platform Communication',
              items: [
                (
                  'Email Notifications',
                  settings.emailNotifications,
                  'email_notifications',
                ),
                ('New Messages', settings.newMessages, 'new_messages'),
                (
                  'Push Notifications',
                  settings.pushNotifications ?? false,
                  'push_notifications',
                ),
              ],
            ),
          ]
        : [
            _NotificationPreferenceSectionData(
              title: 'Project Intelligence',
              items: [
                (
                  'Critical Quality Score Drops',
                  settings.qualityScoreAlerts ?? false,
                  'quality_score_alerts',
                ),
                (
                  'Phase Completion Approvals',
                  settings.milestoneCompletions ?? false,
                  'milestone_completions',
                ),
                (
                  'Ball-in-court Notifications',
                  settings.ballInCourtUpdates,
                  'ball_in_court_updates',
                ),
                ('New Bids Alerts', settings.newBids ?? false, 'new_bids'),
              ],
            ),
            _NotificationPreferenceSectionData(
              title: 'Platform Communication',
              items: [
                (
                  'Email Notifications',
                  settings.emailNotifications,
                  'email_notifications',
                ),
                ('New Messages', settings.newMessages, 'new_messages'),
                (
                  'Push Notifications',
                  settings.pushNotifications ?? false,
                  'push_notifications',
                ),
              ],
            ),
          ];

    return sections
        .map(
          (section) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildPreferenceSection(section, settings),
          ),
        )
        .toList(growable: false);
  }

  Widget _buildPreferenceSection(
    _NotificationPreferenceSectionData section,
    NotificationSettings settings,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              section.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
          ),
          const Divider(color: Color(0xFFE5E7EB)),
          ...section.items.asMap().entries.map((entry) {
            final item = entry.value;
            return Column(
              children: [
                _buildToggleRow(
                  item.$1,
                  item.$2,
                  (value) => _onToggle(item.$3, value, settings),
                ),
                if (entry.key != section.items.length - 1)
                  const Divider(color: Color(0xFFE5E7EB), height: 1),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildToggleRow(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF276572),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFE5E7EB),
          ),
        ],
      ),
    );
  }
}

class _NotificationPreferenceSectionData {
  final String title;
  final List<(String, bool, String)> items;

  const _NotificationPreferenceSectionData({
    required this.title,
    required this.items,
  });
}
