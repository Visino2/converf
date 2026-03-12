import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'verification_tab.dart';
import 'certification_tab.dart';

class ContractorProfileScreen extends StatefulWidget {
  const ContractorProfileScreen({super.key});

  @override
  State<ContractorProfileScreen> createState() => _ContractorProfileScreenState();
}

class _ContractorProfileScreenState extends State<ContractorProfileScreen> {
  bool _isVerificationExpanded = false;
  String _selectedFilter = 'Overview';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Profile Card ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF0F2F5), width: 1),
                  ),
                  child: Column(
                    children: [
                      // Top portion with Image and Camera Circle
                      Stack(
                        alignment: Alignment.bottomCenter,
                        clipBehavior: Clip.none,
                        children: [
                          // Top Image
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16)),
                            child: SizedBox(
                              height: 140,
                              width: double.infinity,
                              child: Image.asset(
                                'assets/images/lekki-complex.png',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: const Color(0xFF309DAA),
                                ),
                              ),
                            ),
                          ),
                          // Camera / Upload Circle
                          Positioned(
                            bottom: -40,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFF3C08B),
                                border:
                                    Border.all(color: Colors.white, width: 3),
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/images/camera.svg',
                                  width: 24,
                                  height: 24,
                                  colorFilter: const ColorFilter.mode(
                                      Colors.white, BlendMode.srcIn),
                                  errorBuilder: (_, __, ___) => const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 50),
                      // Profile Info
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Converf Construction Ltd',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.verified,
                                    color: Color(0xFF309DAA), size: 20),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/map.svg',
                                  width: 14,
                                  height: 14,
                                  colorFilter: const ColorFilter.mode(
                                      Color(0xFF6B7280), BlendMode.srcIn),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Lagos, Nigeria',
                                  style: TextStyle(
                                      fontSize: 13, color: Color(0xFF6B7280)),
                                ),
                                const SizedBox(width: 16),
                                SvgPicture.asset(
                                  'assets/images/calendar-3.svg',
                                  width: 14,
                                  height: 14,
                                  colorFilter: const ColorFilter.mode(
                                      Color(0xFF6B7280), BlendMode.srcIn),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Member since Jan 2021',
                                  style: TextStyle(
                                      fontSize: 13, color: Color(0xFF6B7280)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Statistics Grid
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatItem('COMPLETED', '12', 'assets/images/circle.svg'),
                                _buildStatItem('SUCCESS RATE', '96%', 'assets/images/star.svg'),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatItem('AVG. QUALITY', '94%', 'assets/images/star-1.svg'),
                                _buildStatItem('RESPONSE', '<2h', 'assets/images/clock-circle.svg'),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Edit Profile Button
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: SvgPicture.asset(
                                  'assets/images/edit-profile.svg',
                                  width: 20,
                                  height: 20,
                                  colorFilter: const ColorFilter.mode(
                                      Color(0xFF276572), BlendMode.srcIn),
                                ),
                                label: const Text(
                                  'Edit Profile',
                                  style: TextStyle(
                                    color: Color(0xFF276572),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF276572)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

    
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isVerificationExpanded = !_isVerificationExpanded;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF309DAA), Color(0xFF276572)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Verification Status',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.verified,
                              color: Colors.white,
                              size: 20,
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF143038),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFF143038)),
                              ),
                              child: Icon(
                                _isVerificationExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                        if (_isVerificationExpanded) ...[
                          const SizedBox(height: 16),
                          const Divider(color: Colors.white24),
                          const SizedBox(height: 16),
                          _buildVerificationRow('Company Registration', 'VERIFIED'),
                          _buildVerificationRow('Engineering License', 'VERIFIED'),
                          _buildVerificationRow('Tax Clearance ID', 'VERIFIED'),
                          _buildVerificationRow('Liability Insurance', 'VERIFIED'),
                          _buildVerificationRow('Past Project Review', 'VERIFIED'),
                          const SizedBox(height: 16),
                          const Divider(color: Colors.white24),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Last Verified: Jan 12, 2024',
                                style: TextStyle(color: Colors.white70, fontSize: 11),
                              ),
                              Text(
                                'Renewal Date: Jan 12, 2025',
                                style: TextStyle(color: Colors.white70, fontSize: 11),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    'Overview',
                    'Portfolio',
                    'Verification',
                    'Certification',
                  ].map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedFilter = filter),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF276572) : const Color(0xFFF0F2F5),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF6B7280),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

           
              if (_selectedFilter == 'Overview') ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF0F2F5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'About Company',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Converf Construction Ltd is a premier civil engineering and general contracting firm based in Lagos, with a footprint across West Africa. For over 15 years, we have specialized in high-end residential complexes, industrial logistics hubs, and urban road infrastructure.\n\nOur team of 45+ registered professionals is dedicated to safety, precision, and the integration of sustainable building practices. We pride ourselves on transparent project management and a commitment to quality that consistently exceeds client expectations.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Color(0xFFE5E7EB)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              'YEARS EXPERIENCE',
                              '12+ years',
                              'assets/images/years.svg',
                              const Color(0xFFE0F2F1),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInfoCard(
                              'CORE TEAM',
                              '12 Professionals',
                              'assets/images/group.svg',
                              const Color(0xFFFFF3E0),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

             
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
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
                      const Text(
                        'Skills & Expertise',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildSkillChip('Civil Engineering'),
                          _buildSkillChip('Project Management'),
                          _buildSkillChip('Roofing'),
                          _buildSkillChip('HVAC'),
                          _buildSkillChip('Solar Integration'),
                          _buildSkillChip('Road Construction'),
                          _buildSkillChip('Quality Assurance'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
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
                      const Text(
                        'Service Areas',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildServiceAreaItem('Nigeria'),
                      _buildServiceAreaItem('Ghana'),
                      _buildServiceAreaItem('Kenya'),
                    ],
                  ),
                ),
              ),
              ] else if (_selectedFilter == 'Portfolio') ...[
                _buildPortfolioTab(),
              ] else if (_selectedFilter == 'Verification') ...[
                const VerificationTab(),
              ] else if (_selectedFilter == 'Certification') ...[
                const CertificationTab(),
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String icon) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                icon,
                width: 14,
                height: 14,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B7280),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationRow(String label, String status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SvgPicture.asset('assets/images/mark.svg', width: 14, height: 14),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          const Spacer(),
          Text(
            status,
            style: const TextStyle(
              color: Color(0xFFA7F3D0),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, String icon, Color iconBgColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            offset: Offset(0, 1),
            blurRadius: 2,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SvgPicture.asset(icon, width: 20, height: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFF4B5563),
        ),
      ),
    );
  }

  Widget _buildServiceAreaItem(String area) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const Icon(Icons.language, color: Color(0xFF6B7280), size: 18),
          const SizedBox(width: 12),
          Text(
            area,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildPortfolioCard(),
        ],
      ),
    );
  }

  Widget _buildPortfolioCard() {
    return Container(
      height: 380,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage('assets/images/bg-1.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 120,
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black54,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lekki Residential Complex',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/map.svg',
                      width: 14,
                      height: 14,
                      colorFilter: const ColorFilter.mode(Color(0xFF4B5563), BlendMode.srcIn),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Lekki Phase 1, Lagos',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Row(
              children: [
                Expanded(
                  flex: 11,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: SvgPicture.asset('assets/images/Invoice.svg', width: 14, height: 14),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '₦30,600,000',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 9,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, size: 12, color: Color(0xFF16A34A)),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Completed',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
    );
  }
}
