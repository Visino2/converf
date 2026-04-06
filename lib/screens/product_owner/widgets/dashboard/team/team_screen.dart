import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../../features/team/providers/team_providers.dart';
import '../../../../../../features/team/models/team_member.dart';

import 'add_team_modal.dart';
import 'team_member_detail_sheet.dart';

class TeamScreen extends ConsumerStatefulWidget {
  final VoidCallback? onNavigateToProjects;

  const TeamScreen({
    super.key,
    this.onNavigateToProjects,
  });

  @override
  ConsumerState<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends ConsumerState<TeamScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedRole = 'All';

  final List<String> _roles = [
    'All',
    'Project Manager',
    'Architect',
    'Engineer',
    'Designer',
    'Contractor',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddTeamMenu(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
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
                        color: Colors.black.withValues(alpha: 0.1),
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
                          onPressed: () async {
                            Navigator.pop(context);
                            try {
                              final result = await ref.read(teamActionProvider.notifier).exportTeamMembers();
                              
                              if (result != null && result['status'] == true && result['data'] != null) {
                                final urlString = result['data'].toString();
                                if (urlString.isNotEmpty) {
                                  final uri = Uri.tryParse(urlString);
                                  if (uri != null && await canLaunchUrl(uri)) {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  }
                                }
                              }
                              
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Export command sent')),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Export failed: $e')),
                                );
                              }
                            }
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
    final teamMembersAsync = ref.watch(teamMembersProvider((projectId: null, page: 1, perPage: 100)));

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Team Management',
              style: TextStyle(
                color: Color(0xFF101828),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            teamMembersAsync.when(
              data: (res) => Text(
                'Manage ${res.data.length} team members',
                style: const TextStyle(
                  color: Color(0xFF667085),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: Color(0xFF344054)),
            onPressed: () async {
              try {
                final result = await ref.read(teamActionProvider.notifier).exportTeamMembers();
                if (result != null && result['status'] == true && result['data'] != null) {
                  final urlString = result['data'].toString();
                  if (urlString.isNotEmpty) {
                    final uri = Uri.parse(urlString);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Export failed: $e')),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF276572), size: 28),
            onPressed: () {
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
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search and Filters Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            color: const Color(0xFFF9FAFB),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFD0D5DD)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search members...',
                            hintStyle: TextStyle(color: Color(0xFF667085), fontSize: 14),
                            prefixIcon: Icon(Icons.search, color: Color(0xFF667085), size: 20),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFD0D5DD)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedRole,
                          icon: const Icon(Icons.filter_list, size: 18, color: Color(0xFF344054)),
                          style: const TextStyle(
                            color: Color(0xFF344054),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedRole = newValue;
                              });
                            }
                          },
                          items: _roles.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Expanded(
            child: teamMembersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF276572))),
              error: (error, _) => Center(child: Text('Error: $error', style: const TextStyle(color: Colors.red))),
              data: (response) {
                // Apply client-side filtering
                final filteredMembers = response.data.where((m) {
                  final nameMatch = m.displayName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      (m.user?.email.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
                  
                  final roleMatch = _selectedRole == 'All' || m.role.toLowerCase() == _selectedRole.toLowerCase();
                  
                  return nameMatch && roleMatch;
                }).toList();

                if (filteredMembers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search_outlined, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty ? 'No team members yet' : 'No members match your search',
                          style: const TextStyle(color: Color(0xFF667085), fontSize: 16),
                        ),
                        if (_searchQuery.isNotEmpty || _selectedRole != 'All')
                          TextButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _selectedRole = 'All');
                            },
                            child: const Text('Clear filters', style: TextStyle(color: Color(0xFF276572))),
                          ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredMembers.length,
                  itemBuilder: (context, index) {
                    final member = filteredMembers[index];
                    return _buildTeamMemberCard(context, member);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMemberCard(BuildContext context, TeamMember member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAECF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => TeamMemberDetailSheet(member: member),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF2F4F7),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipOval(
                  child: member.user?.avatar != null
                      ? Image.network(
                          member.user!.avatar!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildAvatarPlaceholder(member),
                        )
                      : _buildAvatarPlaceholder(member),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.displayName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF101828),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      member.user?.email ?? 'No email',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF667085),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFEAECF0)),
                    ),
                    child: Text(
                      member.role.isNotEmpty ? member.role : 'Member',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF344054),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: member.status.toLowerCase() == 'active' 
                              ? const Color(0xFF12B76A) 
                              : const Color(0xFFF79009),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        member.status.isNotEmpty ? member.status : 'Active',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: member.status.toLowerCase() == 'active' 
                              ? const Color(0xFF027A48) 
                              : const Color(0xFFB54708),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder(TeamMember member) {
    final initials = member.displayName.isNotEmpty 
        ? member.displayName.trim().split(' ').map((l) => l[0]).take(2).join().toUpperCase()
        : '?';
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          color: Color(0xFF475467),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
