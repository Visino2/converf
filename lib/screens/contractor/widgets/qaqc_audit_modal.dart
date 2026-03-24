import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void showQaQcAuditModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const QaQcAuditModal(),
  );
}

class QaQcAuditModal extends StatefulWidget {
  const QaQcAuditModal({super.key});

  @override
  State<QaQcAuditModal> createState() => _QaQcAuditModalState();
}

class _QaQcAuditModalState extends State<QaQcAuditModal> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolledToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent == 0) {
        setState(() => _isScrolledToBottom = true);
      }
    });
  }

  void _onScroll() {
    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent - 20) {
      if (!_isScrolledToBottom) {
        setState(() => _isScrolledToBottom = true);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onActionPressed(BuildContext context) {
    // Close all modals/sheets and go back to milestone screen
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.90,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'QA/QC Audit Certificate',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF101828),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Phase 7 - Electrical Rough-In',
                        style: TextStyle(fontSize: 14, color: Color(0xFF667085)),
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
                      child: const Icon(Icons.close, size: 16, color: Color(0xFF667085)),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFFEAECF0), height: 1),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Report meta info
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetaField('REPORT TO:', 'CVF-RPT-2024-1X'),
                        ),
                        Expanded(
                          child: _buildMetaField('AUDITOR', 'Engr. Ibrahim Musa'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetaField('AUDIT DATE', 'Feb 10, 2026 11:30am'),
                        ),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'RESULT',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF94A3B8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F973D),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'Compliant',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Score card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEAECF0)),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _DottedGridPainter(),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '94%',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF276572),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFECFDF3),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'EXCELLENT',
                                      style: TextStyle(
                                        color: Color(0xFF039855),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: const LinearProgressIndicator(
                                  value: 0.94,
                                  minHeight: 8,
                                  backgroundColor: Color(0xFFEAECF0),
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF276572)),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Physical Standards Met', style: TextStyle(fontSize: 12, color: Color(0xFF667085))),
                                      const SizedBox(height: 2),
                                      const Text('Audit Status', style: TextStyle(fontSize: 12, color: Color(0xFF667085))),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Certified',
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2A8090)),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text('18/19 Passed', style: TextStyle(fontSize: 12, color: Color(0xFF101828), fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 2),
                                      const Text('Total Deviations', style: TextStyle(fontSize: 12, color: Color(0xFF667085))),
                                      const SizedBox(height: 2),
                                      const Text('1 Findings', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2A8090))),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Minor findings box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFAEB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFEDF89)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Minor Findings - Remediation Advised',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF344054)),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Some terminal blocks in the secondary distribution panel lack permanent UV-stable labeling. While this does not impact electrical safety or performance, it is required for ISO maintenance standards.',
                            style: TextStyle(fontSize: 12, color: Color(0xFFB4543E), fontWeight: FontWeight.w500, height: 1.5),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF79009),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text('Impact: Low', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'PANEL LOCATION: BLOCK 2B-IV',
                                style: TextStyle(fontSize: 11, color: Color(0xFF667085), fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Material / System checks table
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEAECF0)),
                      ),
                      child: Column(
                        children: [
                          // Table header
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('MAterial/System Check', style: TextStyle(fontSize: 12, color: Color(0xFF667085), fontWeight: FontWeight.w500)),
                                Text('STandard Ref', style: TextStyle(fontSize: 12, color: Color(0xFF667085), fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          _buildTableRow('Core Integrity Test', 'IEC - 60364', showDivider: true),
                          _buildTableRow('Terminal Tightness', 'BS - 7671', showDivider: true),
                          _buildTableRow('Phase Balancing', 'NEC - 300', showDivider: false),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Auditor signature
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FBFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFB7E7EA)),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _DottedGridPainter(),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Auditor Signature',
                                    style: TextStyle(fontSize: 12, color: Color(0xFF667085)),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      ClipOval(
                                        child: Image.asset(
                                          'assets/images/chinedu.png',
                                          width: 36,
                                          height: 36,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Text(
                                        'Ibrahim : Converf',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF101828),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SvgPicture.asset(
                                'assets/images/logo.svg',
                                width: 28,
                                height: 28,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Sticky footer buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isScrolledToBottom
                            ? () => _onActionPressed(context)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF276572),
                          disabledBackgroundColor: const Color(0xFF276572).withValues(alpha: 0.5),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/images/export.svg',
                              width: 18,
                              height: 18,
                              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Export Audit',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isScrolledToBottom
                            ? () => _onActionPressed(context)
                            : null,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: _isScrolledToBottom
                                ? const Color(0xFF276572)
                                : const Color(0xFFD0D5DD),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/images/uplaod-2.svg',
                              width: 18,
                              height: 18,
                              colorFilter: ColorFilter.mode(
                                _isScrolledToBottom ? const Color(0xFF276572) : const Color(0xFF94A3B8),
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Download Certificate',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _isScrolledToBottom ? const Color(0xFF276572) : const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF101828)),
        ),
      ],
    );
  }

  Widget _buildTableRow(String check, String ref, {required bool showDivider}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: Color(0xFFEAECF0)))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(check, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
          Text(ref, style: const TextStyle(fontSize: 14, color: Color(0xFF475467))),
        ],
      ),
    );
  }
}

class _DottedGridPainter extends CustomPainter {
  final Color? color;
  _DottedGridPainter({this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color ?? const Color(0xFFF1F5F9).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    const spacing = 12.0;
    const dotSize = 1.5;

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize / 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
