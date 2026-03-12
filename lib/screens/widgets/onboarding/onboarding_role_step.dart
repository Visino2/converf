import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingRoleStep extends StatefulWidget {
  final Function(String) onRoleSelected;
  final VoidCallback onLogin;

  const OnboardingRoleStep({
    super.key,
    required this.onRoleSelected,
    required this.onLogin,
  });

  @override
  State<OnboardingRoleStep> createState() => _OnboardingRoleStepState();
}

class _OnboardingRoleStepState extends State<OnboardingRoleStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bgAnimationController;

  @override
  void initState() {
    super.initState();
    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgAnimationController.dispose();
    super.dispose();
  }

  Widget _buildRoleCard({
    required String title,
    required String iconAsset,
    required String imageAsset,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: _bgAnimationController,
      builder: (context, child) {
        final scale = 1.0 + (_bgAnimationController.value * 0.1);

        return Container(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.transparent, width: 2),
            color: Colors.black87,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Transform.scale(
                scale: scale,
                child: Image.asset(imageAsset, fit: BoxFit.cover),
              ),
              // Dark gradient overlay for better readability
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.black.withOpacity(0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              child!,
            ],
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            iconAsset.endsWith('.svg')
                ? SvgPicture.asset(
                    iconAsset,
                    width: 28,
                    height: 28,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFFF25C19),
                      BlendMode.srcIn,
                    ),
                  )
                : Image.asset(
                    iconAsset,
                    width: 28,
                    height: 28,
                    color: const Color(0xFFF25C19),
                  ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('role'),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.45],
          colors: [Color(0xFF276572), Colors.white],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: widget.onLogin,
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 6),
              const Text(
                'Get started with\nConverf',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  letterSpacing: -1.0,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Build world-class infrastructure across Africa',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Join as',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => widget.onRoleSelected('project_owner'),
                      child: _buildRoleCard(
                        title:
                            "I'm a project owner,\nlooking to manage\nconstruction",
                        iconAsset: 'assets/images/tractor.svg',
                        imageAsset: 'assets/images/frame-1.png',
                        onTap: () => widget.onRoleSelected('project_owner'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => widget.onRoleSelected('contractor'),
                      child: _buildRoleCard(
                        title:
                            "I'm a contractor,\nlooking to execute\nprojects",
                        iconAsset: 'assets/images/vector.svg',
                        imageAsset: 'assets/images/frame-2.png',
                        onTap: () => widget.onRoleSelected('contractor'),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
