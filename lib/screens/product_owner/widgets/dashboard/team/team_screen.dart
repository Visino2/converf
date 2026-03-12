import 'package:flutter/material.dart';


import 'add_team_modal.dart';
import 'team_member_detail_sheet.dart';

class TeamScreen extends StatefulWidget {
  final VoidCallback? onNavigateToProjects;

  TeamScreen({
    Key? key,
    this.onNavigateToProjects,
  }) : super(key: key);

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  final List<Map<String, String>> _teamMembers = [
    {
      'name': 'Olamide...',
      'fullName': 'Olamide Akintan',
      'role': 'Project Mana...',
      'fullRole': 'Project Manager',
      'image': 'assets/images/olamide.png',
      'status': 'Active',
      'memberSince': 'Jan 2023',
      'location': 'Lagos, Nigeria',
      'email': 'adebayo@megastruct...',
      'phone': '+234 801 234 5678',
    },
    {
      'name': 'Alison Da...',
      'fullName': 'Alison Davis',
      'role': 'Site Engineer',
      'fullRole': 'Site Engineer',
      'image': 'assets/images/alison.png',
      'status': 'Active',
      'memberSince': 'Mar 2023',
      'location': 'Lagos, Nigeria',
      'email': 'alison@megastruct...',
      'phone': '+234 802 345 6789',
    },
    {
      'name': 'Megan W...',
      'fullName': 'Megan Williams',
      'role': 'Structural Eng...',
      'fullRole': 'Structural Engineer',
      'image': 'assets/images/megan.png',
      'status': 'Active',
      'memberSince': 'Jun 2023',
      'location': 'Abuja, Nigeria',
      'email': 'megan@megastruct...',
      'phone': '+234 803 456 7890',
    },
    {
      'name': 'Janelle L...',
      'fullName': 'Janelle Lewis',
      'role': 'Architect',
      'fullRole': 'Architect',
      'image': 'assets/images/janelle.png',
      'status': 'Active',
      'memberSince': 'Sep 2022',
      'location': 'Lagos, Nigeria',
      'email': 'janelle@megastruct...',
      'phone': '+234 804 567 8901',
    },
    {
      'name': 'King Fish...',
      'fullName': 'King Fisher',
      'role': 'QA/QC Inspe...',
      'fullRole': 'QA/QC Inspector',
      'image': 'assets/images/king.png',
      'status': 'Active',
      'memberSince': 'Dec 2022',
      'location': 'Port Harcourt, Nigeria',
      'email': 'king@megastruct...',
      'phone': '+234 805 678 9012',
    },
    {
      'name': 'Olivia Ma...',
      'fullName': 'Olivia Martin',
      'role': 'Contractor',
      'fullRole': 'Contractor',
      'image': 'assets/images/oliver.png',      'status': 'Active',
      'memberSince': 'Feb 2023',
      'location': 'Lagos, Nigeria',
      'email': 'olivia@megastruct...',
      'phone': '+234 806 789 0123',
    },
  ];

  void _showAddTeamMenu(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned(
              top: 100,
              right: 16,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 280,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFD0D5DD)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          icon: const Icon(Icons.file_download_outlined, color: Color(0xFF344054)),
                          label: const Text(
                            'Export CSV',
                            style: TextStyle(
                              color: Color(0xFF344054),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => AddTeamModal(
                                onNavigateToProjects: () {
                                  if (widget.onNavigateToProjects != null) {
                                    widget.onNavigateToProjects!();
                                  }
                                },
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF276572),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            minimumSize: const Size(double.infinity, 48),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                          label: const Text(
                            'Add Team',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        title: const Text(
          'Team Management',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black, size: 28),
            onPressed: () => _showAddTeamMenu(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: _teamMembers.length,
        itemBuilder: (context, index) {
          final member = _teamMembers[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.01),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[200]),
                  child: ClipOval(
                    child: Image.asset(
                      member['image']!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: Text(
                    member['name']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF101828),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  height: 48,
                  width: 1,
                  color: const Color(0xFFEAECF0),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      member['role']!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF667085),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Container(
                  height: 48,
                  width: 1,
                  color: const Color(0xFFEAECF0),
                  margin: const EdgeInsets.only(right: 12),
                ),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => TeamMemberDetailSheet(member: member),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF027A48),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      member['status']!,
                      style: const TextStyle(
                        fontSize: 12,
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
      ),
    );
  }
}
