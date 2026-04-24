import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:converf/screens/product_owner/widgets/dashboard/new_project/providers/wizard_provider.dart';
import 'package:converf/screens/product_owner/widgets/dashboard/projects/project_details_screen.dart';
import 'package:converf/screens/product_owner/widgets/dashboard/team/add_team_modal.dart';
import 'package:converf/features/projects/providers/project_providers.dart';
import 'package:converf/features/dashboard/providers/dashboard_providers.dart';
import 'package:converf/features/team/providers/team_providers.dart';
import 'package:converf/core/ui/app_navigation.dart';

class SuccessView extends ConsumerStatefulWidget {
  const SuccessView({super.key});

  @override
  ConsumerState<SuccessView> createState() => _SuccessViewState();
}

class _SuccessViewState extends ConsumerState<SuccessView> {
  bool _checkingTeam = false;

  Future<void> _onInviteTeamTapped() async {
    if (_checkingTeam) return;
    setState(() => _checkingTeam = true);

    try {
      final teamResponse = await ref.read(
        teamMembersProvider((projectId: null, page: 1, perPage: 1)).future,
      );
      if (!mounted) return;

      final hasMembers = teamResponse.data.isNotEmpty;
      final wizState = ref.read(wizardStateProvider);
      final projectId = wizState.projectId;

      ref.read(wizardStateProvider.notifier).reset();
      ref.invalidate(dashboardStatsProvider);
      ref.invalidate(projectsListProvider(1));

      // Use root navigator so we can push after closing the bottom sheet
      final nav = Navigator.of(context, rootNavigator: true);
      nav.pop(); // close wizard

      if (hasMembers) {
        // Team members exist — go to project details where owner can assign them
        if (projectId != null) {
          nav.push(
            MaterialPageRoute(
              builder: (_) => ProjectDetailsScreen(projectId: projectId),
            ),
          );
        }
      } else {
        // No team members yet — open the invite modal
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final ctx = appNavigatorKey.currentContext;
          if (ctx != null) {
            showModalBottomSheet(
              context: ctx,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => AddTeamModal(onNavigateToProjects: () {}),
            );
          }
        });
      }
    } catch (_) {
      if (mounted) setState(() => _checkingTeam = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wizardStateProvider);
    final notifier = ref.read(wizardStateProvider.notifier);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  notifier.reset();
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 20, color: Color(0xFF4B5563)),
                ),
              ),
            ],
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset('assets/images/colourful.png', height: 150, fit: BoxFit.cover),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F6EC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: SvgPicture.asset('assets/images/check.svg', width: 56, height: 56),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Project Created Successfully!',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF171717),
              height: 1.2,
              letterSpacing: -0.48,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
              children: [
                const TextSpan(text: 'Your project "'),
                TextSpan(
                  text: state.title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF276572),
                  ),
                ),
                const TextSpan(text: '" is ready\nfor management.'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFEAECF0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Reference ID: ', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                const Text(
                  'CV-2024-001',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF111827)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Invite Team card — tappable with conditional logic
          GestureDetector(
            onTap: _onInviteTeamTapped,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _checkingTeam ? const Color(0xFF276572) : const Color(0xFFE5E7EB),
                  width: _checkingTeam ? 1.5 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFF3F4F6)),
                    ),
                    child: SvgPicture.asset(
                      'assets/images/map.svg',
                      colorFilter: const ColorFilter.mode(Color(0xFF2A8090), BlendMode.srcIn),
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Invite Team Members',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add contractors and team members',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (_checkingTeam)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF2A8090),
                          ),
                        )
                      else ...[
                        const Text(
                          'Invite Team',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2A8090)),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward, color: Color(0xFF2A8090), size: 16),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                final projectId = state.projectId;
                notifier.reset();
                Navigator.of(context).pop();
                if (projectId != null) {
                  ref.invalidate(dashboardStatsProvider);
                  ref.invalidate(projectsListProvider(1));
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) => ProjectDetailsScreen(projectId: projectId),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF276572),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Go to Project Dashboard',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  SvgPicture.asset(
                    'assets/images/projects.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
