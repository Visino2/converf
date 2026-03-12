import 'package:flutter/material.dart';
import 'message_details_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProjectInboxScreen extends StatefulWidget {
  const ProjectInboxScreen({super.key});

  @override
  State<ProjectInboxScreen> createState() => _ProjectInboxScreenState();
}

class _ProjectInboxScreenState extends State<ProjectInboxScreen> {
  String _selectedFilter = 'All';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _allMessages = [
    {
      'title': 'Lekki Residential Complex',
      'message': 'Let\'s schedule an urgent review meeting for tomorrow morning.',
      'time': '10:45 AM',
      'isUnread': true,
      'type': 'project',
    },
    {
      'title': 'Ikeja Commercial Plaza',
      'message': 'Let\'s schedule an urgent review meeting for tomorrow morning.',
      'time': '10:45 AM',
      'isUnread': false,
      'type': 'project',
    },
    {
      'title': 'Lekki Residential Complex',
      'message': 'Let\'s schedule an urgent review meeting for tomorrow morning.',
      'time': '10:45 AM',
      'isUnread': false,
      'type': 'project',
    },
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> displayedMessages = _allMessages.where((msg) {
      bool matchesFilter = true;
      if (_selectedFilter == 'Unread') matchesFilter = msg['isUnread'] == true;
      if (_selectedFilter == 'Projects') matchesFilter = msg['type'] == 'project';

      if (!matchesFilter) return false;

      if (_searchQuery.isNotEmpty) {
        return msg['title'].toString().toLowerCase().contains(_searchQuery) ||
               msg['message'].toString().toLowerCase().contains(_searchQuery);
      }
      return true;
    }).toList();

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
              icon: SvgPicture.asset('assets/images/search.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
              ),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          IconButton(
            icon: SvgPicture.asset('assets/images/message.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn),
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
      body: displayedMessages.isEmpty
          ? const Center(
              child: Text(
                'No messages found.',
                style: TextStyle(color: Color(0xFF667085)),
              ),
            )
          : ListView.builder(
              itemCount: displayedMessages.length,
              itemBuilder: (context, index) {
                final msg = displayedMessages[index];
                return _buildMessageItem(
                  title: msg['title'],
                  message: msg['message'],
                  time: msg['time'],
                  isUnread: msg['isUnread'],
                );
              },
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

  Widget _buildMessageItem({
    required String title,
    required String message,
    required String time,
    required bool isUnread,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MessageDetailsScreen(title: title),
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
                        title,
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
                          time,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF475467)),
                        ),
                        if (isUnread) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF276572),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF475467), height: 1.5),
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
