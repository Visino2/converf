import 'package:flutter/material.dart';
import 'message_info_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MessageDetailsScreen extends StatefulWidget {
  final String title;

  const MessageDetailsScreen({super.key, required this.title});

  @override
  State<MessageDetailsScreen> createState() => _MessageDetailsScreenState();
}

class _MessageDetailsScreenState extends State<MessageDetailsScreen> {
  bool _showProjectOwnerPopup = false;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesSearch(String message, String name) {
    if (_searchQuery.isEmpty) return true;
    return message.toLowerCase().contains(_searchQuery) ||
           name.toLowerCase().contains(_searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
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
                widget.title,
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
              icon: SvgPicture.asset('assets/images/search.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(Color(0xFF667085), BlendMode.srcIn),
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.search,
                  color: Color(0xFF667085),
                ),
              ),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          IconButton(
            icon: SvgPicture.asset('assets/images/reply.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(Color(0xFF667085), BlendMode.srcIn),
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.reply,
                color: Color(0xFF667085),
              ),
            ),
            onPressed: () {},
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MessageInfoScreen()),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16, left: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD0D5DD)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: SvgPicture.asset('assets/images/infro.svg',
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(Color(0xFF667085), BlendMode.srcIn),
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Color(0xFF667085),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                if (_searchQuery.isEmpty) ...[
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFEAECF0)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Chinedu Okafor created this conversation • 2 days ago',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF667085),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                if (_matchesSearch('We need to discuss the foundation quality issues. The latest test results show bearing capacity below specification.', 'Chinedu Okafor')) ...[
                  _buildMessageBubble(
                    name: 'Chinedu Okafor',
                    time: '2 days ago',
                    company: 'Megastructures Africa Ltd • Stakeholder',
                    message:
                        'We need to discuss the foundation quality issues. The latest test results show bearing capacity below specification.',
                    hasAttachment: true,
                    sentByYou: true,
                  ),
                  const SizedBox(height: 16),
                ],

                if (_matchesSearch('I\'ve reviewed the report. We\'ll need to redesign the foundation. I\'ll have Chukwudi work on revised calculations.', 'Chinedu Okafor')) ...[
                  _buildMessageBubble(
                    name: 'Chinedu Okafor',
                    time: '2 days ago',
                    company: 'Megastructures Africa Ltd • Stakeholder',
                    message:
                        'I\'ve reviewed the report. We\'ll need to redesign the foundation. I\'ll have Chukwudi work on revised calculations.',
                    hasAttachment: false,
                    sentByYou: false,
                    showPopup: _showProjectOwnerPopup,
                    onQuoteReply: () {
                      setState(() {
                        _showProjectOwnerPopup = true;
                      });
                    },
                    onPopupClose: () {
                      setState(() {
                        _showProjectOwnerPopup = false;
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
          _buildBottomInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required String name,
    required String time,
    required String company,
    required String message,
    required bool hasAttachment,
    required bool sentByYou,
    bool showPopup = false,
    VoidCallback? onQuoteReply,
    VoidCallback? onPopupClose,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
                  child: Image.asset(
                    'assets/images/okafor.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.grey),
                  ),
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
                            SvgPicture.asset('assets/images/clock.svg',
                              width: 16,
                              height: 16,
                              colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn),
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.access_time, size: 16, color: Color(0xFF276572)),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              time,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF475467)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        SvgPicture.asset('assets/images/Plate.svg',
                          width: 14,
                          height: 14,
                          colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn),
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.business_center_outlined,
                            size: 14,
                            color: Color(0xFF276572),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            company,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF475467)),
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
            style: const TextStyle(fontSize: 14, color: Color(0xFF475467), height: 1.5),
          ),

          if (showPopup) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF6ED),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF9D0A8)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SvgPicture.asset('assets/images/shield-warning.svg',
                          width: 24,
                          height: 24,
                          colorFilter: const ColorFilter.mode(Color(0xFFD92D20), BlendMode.srcIn),
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error_outline, color: Color(0xFFD92D20), size: 24),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ball-in-court', style: TextStyle(fontSize: 12, color: Color(0xFF667085))),
                          Text('Project Owner', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Confirm roofing tile color and material',
                    style: TextStyle(fontSize: 14, color: Color(0xFFE55C00), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () { if (onPopupClose != null) onPopupClose(); },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2A8090),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.check_circle, size: 16, color: Colors.white),
                          label: const Text('Approve', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () { if (onPopupClose != null) onPopupClose(); },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD92D20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 0,
                          ),
                          child: const Text('Decline', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          if (hasAttachment) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                border: Border.all(color: const Color(0xFFEAECF0)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FADF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SvgPicture.asset('assets/images/document.svg',
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(Color(0xFF027A48), BlendMode.srcIn),
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.description, size: 20, color: Color(0xFF027A48)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Soil-Test-Results.pdf',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
                        const SizedBox(height: 4),
                        Text(
                          '11 Sep, 2023    12:24pm • 13MB',
                          style: TextStyle(fontSize: 12, color: const Color(0xFF98A2B3).withOpacity(0.8)),
                        ),
                      ],
                    ),
                  ),
                  SvgPicture.asset('assets/images/icon.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(Color(0xFF475467), BlendMode.srcIn),
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.file_download_outlined, size: 24, color: Color(0xFF475467)),
                  ),
                ],
              ),
            ),
          ],

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: Color(0xFFEAECF0)),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onQuoteReply,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFD0D5DD)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/images/reply.svg',
                        width: 16,
                        height: 16,
                        colorFilter: const ColorFilter.mode(Color(0xFF667085), BlendMode.srcIn),
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.reply, size: 16, color: Color(0xFF667085)),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Quote Reply',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475467)),
                      ),
                    ],
                  ),
                ),
              ),
              if (sentByYou)
                const Text(
                  'Sent by you',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF276572)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInputArea() {
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
                    child: const Icon(Icons.format_italic, size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF98A2B3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.format_underlined, size: 16, color: Colors.white),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF98A2B3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SvgPicture.asset('assets/images/upload.svg',
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.arrow_upward, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              width: double.infinity,
              height: 110,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Write Reply',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        height: 1.45,
                        color: Color(0xFF475367),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A8090),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      icon: SvgPicture.asset('assets/images/white.svg',
                        width: 16,
                        height: 16,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.reply, size: 16, color: Colors.white),
                      ),
                      label: const Text(
                        'Quote Reply',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          height: 1.45,
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
