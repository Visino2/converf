import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../features/projects/providers/project_team_providers.dart';
import '../../../../../../features/team/providers/team_providers.dart';
import '../../../../../../features/projects/models/project_member.dart';
import '../../../../../../features/team/models/team_member.dart';

class ProjectTeamModal extends ConsumerWidget {
  final String projectId;

  const ProjectTeamModal({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamAsync = ref.watch(projectTeamProvider(projectId));

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Project Team',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF101828),
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showAssignMemberSheet(context, ref),
                      icon: const Icon(Icons.person_add, size: 18, color: Colors.white),
                      label: const Text('Assign', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF276572),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF2F4F7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 20, color: Color(0xFF475467)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEAECF0)),
          
          // Body
          Expanded(
            child: teamAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF276572))),
              error: (error, _) => Center(child: Text('Error loading team: $error')),
              data: (members) {
                if (members.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.group_off_outlined, size: 48, color: Color(0xFFD0D5DD)),
                        SizedBox(height: 16),
                        Text('No team members assigned', style: TextStyle(fontSize: 16, color: Color(0xFF667085))),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: members.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return _buildMemberCard(context, ref, member);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, WidgetRef ref, ProjectMember member) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFF2F4F7),
            radius: 24,
            backgroundImage: member.avatarUrl != null ? NetworkImage(member.avatarUrl!) : null,
            child: member.avatarUrl == null ? const Icon(Icons.person, color: Color(0xFF98A2B3)) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF101828)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  member.displayRole,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF667085)),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeMember(context, ref, member),
            icon: const Icon(Icons.highlight_remove, color: Color(0xFFD92D20)),
            tooltip: 'Remove from Project',
          ),
        ],
      ),
    );
  }

  void _removeMember(BuildContext context, WidgetRef ref, ProjectMember member) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text('Remove ${member.displayName} from this project?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD92D20)),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(projectTeamNotifierProvider.notifier).removeMember(projectId, member.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Member removed from project.')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to remove: $e')));
        }
      }
    }
  }

  void _showAssignMemberSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AssignMemberSheet(projectId: projectId),
    );
  }
}

class _AssignMemberSheet extends ConsumerWidget {
  final String projectId;

  const _AssignMemberSheet({required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch all global team members
    final globalTeamAsync = ref.watch(teamMembersProvider((projectId: null, page: 1, perPage: 100)));
    // Fetch existing project members to filter out already assigned ones
    final currentProjectTeamAsync = ref.watch(projectTeamProvider(projectId));

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Team Member',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF101828)),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Color(0xFFF2F4F7), shape: BoxShape.circle),
                    child: const Icon(Icons.close, size: 18),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEAECF0)),
          Expanded(
            child: globalTeamAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (teamResponse) {
                final allMembers = teamResponse.data;
                
                final assignedIds = currentProjectTeamAsync.value?.map((pm) => pm.teamMember?.id).toSet() ?? {};
                final availableMembers = allMembers.where((m) => !assignedIds.contains(m.id)).toList();

                if (availableMembers.isEmpty) {
                   return const Center(child: Text('All platform members are already assigned to this project.', style: TextStyle(color: Color(0xFF667085))));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: availableMembers.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final member = availableMembers[index];
                    return _buildSelectableCard(context, ref, member);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectableCard(BuildContext context, WidgetRef ref, TeamMember member) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFEAECF0)),
      ),
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFF2F4F7),
        backgroundImage: member.user?.avatar != null ? NetworkImage(member.user!.avatar!) : null,
        child: member.user?.avatar == null ? const Icon(Icons.person, color: Color(0xFF98A2B3)) : null,
      ),
      title: Text(member.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(member.role),
      trailing: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF276572),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () => _assignMember(context, ref, member),
        child: const Text('Assign', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _assignMember(BuildContext context, WidgetRef ref, TeamMember member) async {
    try {
      // Show loading overlay
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.white)),
      );

      await ref.read(projectTeamNotifierProvider.notifier).assignMember(projectId, member.id);
      
      if (context.mounted) {
        Navigator.pop(context); // close loading
        Navigator.pop(context); // close sheet
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${member.displayName} assigned successfully.')));
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // close loading
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to assign: $e')));
      }
    }
  }
}
