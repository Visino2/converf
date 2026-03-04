import 'package:flutter/material.dart';

class FieldInspectionsModal extends StatelessWidget {
  const FieldInspectionsModal({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/images/camera-1.png',
                      width: 24,
                      height: 24,
                      color: const Color(0xFF276572),
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
          ],
        ),
      ),
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
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: const AssetImage('assets/images/Image.png'),
                  backgroundColor: Colors.grey[200],
                ),
              ),
              Positioned(
                left: 20,
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: const AssetImage('assets/images/woman.png'),
                  backgroundColor: Colors.grey[300],
                ),
              ),
              Positioned(
                left: 40,
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: const AssetImage('assets/images/man.png'),
                  backgroundColor: Colors.grey[400],
                ),
              ),
              Positioned(
                left: 60,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF101928),
                  child: const Text(
                    '+3',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.45,
                    ),
                  ),
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
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Color(0xFF276572),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 2,
              height: 400,
              color: const Color(0xFFF2F4F7),
            ), // Timeline line
          ],
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
                      child: Image.asset(
                        'assets/images/Inspection.png',
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
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: const AssetImage(
                              'assets/images/Container.png',
                            ),
                            backgroundColor: Colors.grey[200],
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
                            Image.asset(
                              'assets/images/check.png',
                              width: 16,
                              height: 16,
                              color: const Color(0xFF12B76A),
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
