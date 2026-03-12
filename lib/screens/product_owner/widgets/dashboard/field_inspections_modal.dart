import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FieldInspectionsModal extends StatelessWidget {
  const FieldInspectionsModal({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAECF0),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/camera-1.svg',
                              width: 24,
                              height: 24,
                              colorFilter: const ColorFilter.mode(
                                  Color(0xFF276572), BlendMode.srcIn),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Field Inspections',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF101828),
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF2F4F7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Color(0xFF667085),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Field Inspection Timeline',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF101828),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Real-time visual verification from verified QA/QC inspectors across active project phases.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF475467),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAvatarGroup(),
                    const SizedBox(height: 24),
                    _buildInspectionCard(),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF276572),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                        child: const Text(
                          'Log Inspection',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatarGroup() {
    return Row(
      children: [
        SizedBox(
          width: 90,
          height: 32,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[200]),
                  child: ClipOval(child: Image.asset('assets/images/image.png', fit: BoxFit.cover)),
                ),
              ),
              Positioned(
                left: 20,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[300]),
                  child: ClipOval(child: Image.asset('assets/images/woman.png', fit: BoxFit.cover)),
                ),
              ),
              Positioned(
                left: 40,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[400]),
                  child: ClipOval(child: Image.asset('assets/images/man.png', fit: BoxFit.cover)),
                ),
              ),
              Positioned(
                left: 60,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.transparent),
                  child: ClipOval(child: SvgPicture.asset('assets/images/+3.svg', fit: BoxFit.cover)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInspectionCard() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: SvgPicture.asset(
            'assets/images/timeline.svg',
            width: 16,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFEAECF0)),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(12),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Image
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Image.asset('assets/images/Inspection.png',
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(178),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'PHASE: ROOFING',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Inspector Header
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[200]),
                            child: ClipOval(child: Image.asset('assets/images/musa.png', fit: BoxFit.cover)),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CONVERF QUALITY AUDITOR',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: Color(0xFF98A2B3),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Ibrahim Musa',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF101828),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'June 05, 2024 • 11:00 WAT',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF101828),
                        ),
                      ),
                      const Text(
                        'TIMESTAMP',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF98A2B3),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Comment block
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '"Roof truss installation verified against architectural plans. Spacing and anchoring meet Lagos building code requirements."',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475467),
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'KEY FINDINGS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: Color(0xFF98A2B3),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFEAECF0)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset('assets/images/check.svg',
                              width: 16,
                              height: 16,
                              colorFilter: const ColorFilter.mode(Color(0xFF12B76A), BlendMode.srcIn),
                            ), // Green check
                            const SizedBox(width: 8),
                            const Text(
                              'Truss spacing OK',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF344054),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
