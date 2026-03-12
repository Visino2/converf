import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CertificationTab extends StatelessWidget {
  const CertificationTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCertificationCard(
            title: 'Registered Civil Engineer',
            issuer: 'COREN (Council for the Regulation of Engineering in Nigeria)',
            issueDate: 'Jan 2018',
            expiryDate: 'Jan 2026',
            status: 'Valid',
            iconPath: 'assets/images/Diploma.svg',
          ),
          const SizedBox(height: 16),
          _buildCertificationCard(
            title: 'Project Management Professional (PMP)',
            issuer: 'COREN (Council for the Regulation of Engineering in Nigeria)',
            issueDate: 'Jan 2018',
            expiryDate: 'Jan 2026',
            status: 'Expiring Soon',
            iconPath: 'assets/images/Diploma.svg',
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add Certification',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF276572),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCertificationCard({
    required String title,
    required String issuer,
    required String issueDate,
    required String expiryDate,
    required String status,
    required String iconPath,
  }) {
    final isExpiring = status == 'Expiring Soon';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F2F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isExpiring ? const Color(0xFFFFF3E0) : const Color(0xFFE0F2F1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SvgPicture.asset(
                  iconPath,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    isExpiring ? const Color(0xFFD97706) : const Color(0xFF059669),
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isExpiring ? const Color(0xFFFEF3C7) : const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isExpiring ? const Color(0xFFB45309) : const Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            issuer,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF3F4F6)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDateItem('Issued', issueDate, 'assets/images/Calendar.svg'),
              _buildDateItem('Expiry', expiryDate, 'assets/images/shield-warning.svg'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateItem(String label, String date, String iconPath) {
    return Row(
      children: [
        SvgPicture.asset(
          iconPath,
          width: 14,
          height: 14,
          colorFilter: const ColorFilter.mode(Color(0xFF9CA3AF), BlendMode.srcIn),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              date,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
