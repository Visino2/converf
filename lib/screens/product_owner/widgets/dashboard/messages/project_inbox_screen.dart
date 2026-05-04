import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../../../features/notifications/providers/notification_providers.dart';
import '../../../../../features/projects/providers/project_providers.dart';
import '../../../../../features/projects/models/project.dart';
import 'message_details_screen.dart';

class ProjectInboxScreen extends ConsumerStatefulWidget {
  const ProjectInboxScreen({super.key});

  @override
  ConsumerState<ProjectInboxScreen> createState() => _ProjectInboxScreenState();
}

class _ProjectInboxScreenState extends ConsumerState<ProjectInboxScreen> {
  String _selectedFilter = 'All';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
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
            .markMessageNotificationsRead();
      } catch (_) {}
    });
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        debugPrint('[Inbox] Auto-refreshing projects and notifications...');
        ref.invalidate(projectsListProvider(1));
        ref.invalidate(unreadMessageNotificationsCountProvider);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // For now we fetch page 1 of projects
    final projectsAsync = ref.watch(projectsListProvider(1));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
                  hintText: 'Search projects...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              )
            : const Text(
                'Project Inbox',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
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
                  Colors.black,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          IconButton(
            icon: SvgPicture.asset(
              'assets/images/message.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Color(0xFF276572),
                BlendMode.srcIn,
              ),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    _buildFilterButton('All'),
                    const SizedBox(width: 12),
                    _buildFilterButton('Projects'),
                    const SizedBox(width: 12),
                    _buildFilterButton('Unread'),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFEAECF0)),
            ],
          ),
        ),
      ),
      body: projectsAsync.when(
        data: (projectsResponse) {
          final projects = projectsResponse.data;

          List<Project> displayedProjects = projects.where((proj) {
            bool matchesFilter = true;
            // Fake filter logic since API doesn't expose unread right now
            if (_selectedFilter == 'Unread') matchesFilter = false;

            if (!matchesFilter) return false;

            if (_searchQuery.isNotEmpty) {
              return proj.title.toLowerCase().contains(_searchQuery) ||
                  (proj.latestMessage?.body.toLowerCase().contains(
                        _searchQuery,
                      ) ??
                      false);
            }
            return true;
          }).toList();

          // Sort by latest message date descending
          displayedProjects.sort((a, b) {
            final dateA = a.latestMessage?.createdAt ?? a.createdAt;
            final dateB = b.latestMessage?.createdAt ?? b.createdAt;
            return DateTime.parse(dateB).compareTo(DateTime.parse(dateA));
          });

          if (displayedProjects.isEmpty) {
            return const Center(
              child: Text(
                'No messages found.',
                style: TextStyle(color: Color(0xFF667085)),
              ),
            );
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            itemCount: displayedProjects.length,
            itemBuilder: (context, index) {
              final proj = displayedProjects[index];
              return _buildMessageItem(proj: proj);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF276572)),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Error loading inbox: \${error.toString()}',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(String title) {
    bool isSelected = _selectedFilter == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF276572) : const Color(0xFFF2F4F7),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF667085),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageItem({required Project proj}) {
    String messageBody = proj.latestMessage?.body ?? 'No messages yet';
    String timeStr = '';

    try {
      final dateToFormat = proj.latestMessage?.createdAt ?? proj.createdAt;
      final date = DateTime.parse(dateToFormat);

      // Simple relative format, e.g. "Just now", "2m ago"
      final diff = DateTime.now().difference(date);
      if (diff.inDays > 1) {
        timeStr = DateFormat('MMM d').format(date);
      } else if (diff.inDays == 1) {
        timeStr = 'Yesterday';
      } else if (diff.inHours > 0) {
        timeStr = '\${diff.inHours}h ago';
      } else if (diff.inMinutes > 0) {
        timeStr = '\${diff.inMinutes}m ago';
      } else {
        timeStr = 'Just now';
      }
    } catch (_) {}

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MessageDetailsScreen(project: proj),
          ),
        );
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        proj.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF101828),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          timeStr,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF475467),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  messageBody,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF475467),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEAECF0)),
        ],
      ),
    );
  }
}
