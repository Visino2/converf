import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OverviewModal extends StatelessWidget {
  const OverviewModal({super.key});

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
                    SvgPicture.asset('assets/images/home-2.svg',
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(Color(0xFF276572), BlendMode.srcIn),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Overview',
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
              'Project Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Luxury housing development featuring 12 units of 4-bedroom terrace houses with premium finishes, integrated smart home systems, and communal leisure facilities.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF475467),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Project Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF101828),
              ),
            ),
            const Divider(height: 24, color: Color(0xFFEAECF0)),
            _buildDetailRow('Lead Contractor', 'BuildRight Africa'),
            const SizedBox(height: 16),
            _buildDetailRow('Start Date', 'August 15, 2023'),
            const SizedBox(height: 16),
            _buildDetailRow('Expected Completion', 'July 30, 2024'),
            const SizedBox(height: 16),
            _buildDetailRow('Team Size', '12 Active Members'),
            const SizedBox(height: 24),
            const Text(
              'Current Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF101828),
              ),
            ),
            const Divider(height: 24, color: Color(0xFFEAECF0)),
            _buildDetailRow('Current Phase', 'Roofing'),
            const SizedBox(height: 16),
            _buildDetailRow('Phases Completed', '2 of 16'),
            const SizedBox(height: 16),
            _buildDetailRowStatus('BIC Holder', 'Project Owner'),
            const SizedBox(height: 16),
            _buildDetailRow('Last Activity', '2 hours ago'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF667085)),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF101828),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRowStatus(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF667085)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 12.3,
              height: 17.5 / 12.3,
              color: Color(0xFFEA580C),
            ),
          ),
        ),
      ],
    );
  }
}
