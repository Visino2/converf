import 'package:flutter/material.dart';

class SearchResultsState extends StatelessWidget {
  final String query;

  const SearchResultsState({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
      child: Column(
        children: [
          Container(
            height: 240,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(
                image: AssetImage('assets/images/bg-1.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF8DC0DC).withOpacity(0.9),
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Lekki Residential Complex',
                              style: TextStyle(
                                color: Color(0xFF111827),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF6E7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  'AT RISK',
                                  style: TextStyle(
                                    color: Color(0xFFC26E2B),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(
                                      0xFF0F973D,
                                    ), // Green dot per Image 3
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.black54,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Lekki Phase 1, Lagos',
                            style: TextStyle(
                              color: Colors.black87.withOpacity(0.7),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Progress bar area
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/routing.png',
                            width: 16,
                            height: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Current Phase',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: 0.65,
                                backgroundColor: Colors.white,
                                minHeight: 8,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF2A8090), // Teal color
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildPillItem(
                              'assets/images/bill-list.png',
                              '₦45,000,000',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: _buildPillItem(
                              'assets/images/Calendar.png',
                              '78',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: _buildPillItem(
                              'assets/images/group.png',
                              '12',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'End of search result',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillItem(
    String imagePath,
    String text, {
    bool expanded = false,
  }) {
    Widget content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, width: 16, height: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );

    if (expanded) {
      return Expanded(child: content);
    }
    return content;
  }
}
