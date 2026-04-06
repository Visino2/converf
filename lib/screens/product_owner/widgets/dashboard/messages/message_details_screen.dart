import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../../../features/notifications/providers/notification_providers.dart';
import '../../../../../features/projects/models/project.dart';
import '../../../../../features/messages/providers/message_providers.dart';
import '../../../../../features/messages/models/message.dart';
import '../../../../../features/auth/providers/auth_provider.dart';
import 'message_info_screen.dart';

class MessageDetailsScreen extends ConsumerStatefulWidget {
  final Project project;

  const MessageDetailsScreen({super.key, required this.project});

  @override
  ConsumerState<MessageDetailsScreen> createState() =>
      _MessageDetailsScreenState();
}

class _MessageDetailsScreenState extends ConsumerState<MessageDetailsScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _startAutoRefresh();
    Future<void>(() async {
      try {
        await ref
            .read(notificationActionProvider.notifier)
            .markMessageNotificationsRead(projectId: widget.project.id);
      } catch (_) {}
    });
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        debugPrint('[Messages] Auto-refreshing messages and notifications...');
        ref.invalidate(projectMessagesProvider(widget.project.id));
        ref.invalidate(unreadMessageNotificationsCountProvider);
      }
    });

    // Initial scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchController.dispose();
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool _matchesSearch(String message, String name) {
    if (_searchQuery.isEmpty) return true;
    return message.toLowerCase().contains(_searchQuery) ||
        name.toLowerCase().contains(_searchQuery);
  }

  void _sendMessage() {
    final body = _replyController.text.trim();
    if (body.isEmpty) return;

    _replyController.clear();
    FocusScope.of(context).unfocus();
    ref.read(sendMessageProvider.notifier).send(widget.project.id, body);
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(projectMessagesProvider(widget.project.id));
    final currentUser = ref.watch(authProvider).value?.data?.user;
    final currentUserId = currentUser?['id'] ?? '';

    // Listen for new messages to auto-scroll
    ref.listen(projectMessagesProvider(widget.project.id), (previous, next) {
      if (next is AsyncData && next.value != null) {
        // Delay slightly to allow the ListView to render the new item
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(fontSize: 16, color: Colors.black),
                decoration: const InputDecoration(
                  hintText: 'Search messages...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              )
            : Text(
                widget.project.title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                  _searchQuery = '';
                });
              },
            )
          else
            IconButton(
              icon: SvgPicture.asset(
                'assets/images/search.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF667085),
                  BlendMode.srcIn,
                ),
              ),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MessageInfoScreen(),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16, left: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD0D5DD)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: SvgPicture.asset(
                'assets/images/infro.svg',
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF667085),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              skipLoadingOnReload: true,
              data: (messages) {
                // Determine creator of conversation
                final creatorName = widget.project.owner != null
                    ? '${widget.project.owner!.firstName} ${widget.project.owner!.lastName}'
                    : 'System';

                // Sort ascending so newest is at the bottom
                final sortedMessages = List<Message>.from(messages)
                  ..sort(
                    (a, b) => DateTime.parse(
                      a.createdAt,
                    ).compareTo(DateTime.parse(b.createdAt)),
                  );

                return ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    if (_searchQuery.isEmpty)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xFFEAECF0)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$creatorName created this conversation for ${widget.project.title}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF667085),
                            ),
                          ),
                        ),
                      ),

                    if (sortedMessages.isEmpty && _searchQuery.isEmpty)
                      const Center(
                        child: Text(
                          'No messages yet. Send the first message!',
                          style: TextStyle(
                            color: Color(0xFF667085),
                            fontSize: 14,
                          ),
                        ),
                      ),

                    for (final msg in sortedMessages)
                      if (_matchesSearch(msg.body, msg.sender?.firstName ?? ''))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildMessageBubble(
                            id: msg.id,
                            name: msg.sender != null
                                ? '${msg.sender!.firstName} ${msg.sender!.lastName}'
                                : 'System',
                            time: _formatMessageTime(msg.createdAt),
                            company: msg.sender?.role ?? 'Participant',
                            message: msg.body,
                            hasAttachment:
                                false, // Attachment handling omitted for simplicity
                            sentByYou: msg.sender?.id == currentUserId,
                            avatarUrl: msg.sender?.avatarUrl,
                          ),
                        ),
                  ],
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF276572)),
              ),
              error: (err, st) =>
                  Center(child: Text('Failed to load messages: $err')),
            ),
          ),
          _buildBottomInputArea(),
        ],
      ),
    );
  }

  String _formatMessageTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inDays > 1) {
        return DateFormat('MMM d, h:mm a').format(date);
      } else if (diff.inDays == 1) {
        return "Yesterday ${DateFormat('h:mm a').format(date)}";
      } else {
        return DateFormat('h:mm a').format(date); // Today
      }
    } catch (_) {
      return '';
    }
  }

  Widget _buildMessageBubble({
    required String id,
    required String name,
    required String time,
    required String company,
    required String message,
    required bool hasAttachment,
    required bool sentByYou,
    String? avatarUrl,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                child: ClipOval(
                  child: avatarUrl != null && avatarUrl.isNotEmpty
                      ? Image.network(
                          avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.person, color: Colors.grey),
                        )
                      : const Icon(Icons.person, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF101828),
                          ),
                        ),
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/clock.svg',
                              width: 16,
                              height: 16,
                              colorFilter: const ColorFilter.mode(
                                Color(0xFF276572),
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              time,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF475467),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/Plate.svg',
                          width: 14,
                          height: 14,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF276572),
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            company,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF475467),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: Color(0xFFEAECF0)),
          ),

          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF475467),
              height: 1.5,
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: Color(0xFFEAECF0)),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (sentByYou) ...[
                GestureDetector(
                  onTap: () {
                    // Show delete confirmation dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Delete Message"),
                          content: const Text(
                            "Are you sure you want to delete this message?",
                          ),
                          actions: [
                            TextButton(
                              child: const Text("Cancel"),
                              onPressed: () => Navigator.pop(context),
                            ),
                            TextButton(
                              child: const Text(
                                "Delete",
                                style: TextStyle(color: Colors.red),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                ref
                                    .read(deleteMessageProvider.notifier)
                                    .delete(widget.project.id, id);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFF9D0A8)),
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xFFFFF6ED),
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.delete_outline,
                          size: 16,
                          color: Color(0xFFD92D20),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFD92D20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Text(
                  'Sent by you',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF276572),
                  ),
                ),
              ] else ...[
                // Not sent by you (Quote Reply placeholder for original behavior)
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFD0D5DD)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/reply.svg',
                          width: 16,
                          height: 16,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF667085),
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Quote Reply',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475467),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(), // Spacer
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInputArea() {
    final isSending = ref.watch(sendMessageProvider).isLoading;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF98A2B3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.format_italic,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF98A2B3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.format_underlined,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF98A2B3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SvgPicture.asset(
                      'assets/images/upload.svg',
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              width: double.infinity,
              height: 110,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 16.0,
                  bottom: 20.0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _replyController,
                        maxLines: null,
                        decoration: const InputDecoration(
                          hintText: 'Write Reply...',
                          hintStyle: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: Color(0xFF475367),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: isSending ? null : _sendMessage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A8090),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      icon: isSending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.send,
                              size: 16,
                              color: Colors.white,
                            ),
                      label: Text(
                        isSending ? 'Sending...' : 'Send Reply',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
