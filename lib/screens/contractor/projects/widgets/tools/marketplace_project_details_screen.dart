import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'submit_proposal/submit_proposal_modal.dart';

class MarketplaceProjectDetailsScreen extends StatelessWidget {
  const MarketplaceProjectDetailsScreen({super.key});


  void _showOverview(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _OverviewSheet(),
    );
  }

  void _showDocuments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _DocumentsSheet(),
    );
  }

  void _showSite(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _SiteSheet(),
    );
  }

  void _showClient(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _ClientSheet(),
    );
  }

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
          'Lekki Residential Complex',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.menu, color: Colors.black),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
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
                      'Lekki Phase 1, Lagos',
                      style:
                          TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                    ),
                    const Spacer(),
                    _badge('Urgent', const Color(0xFFFEF3C7),
                        const Color(0xFFB45309)),
                    const SizedBox(width: 8),
                    _badge('RESIDENTIAL', const Color(0xFFF0F2F5),
                        const Color(0xFF374151),
                        letterSpacing: 0.5),
                  ],
                ),
              ),

              
              Stack(
                children: [
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: Image.asset(
                      'assets/images/lekki-complex.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: const Color(0xFF309DAA)),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/images/camera.svg',
                            width: 16,
                            height: 16,
                            colorFilter: const ColorFilter.mode(
                                Colors.white, BlendMode.srcIn),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Update Thumbnail',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Bid Deadline',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFF6B7280))),
                        SizedBox(height: 4),
                        Text('12d : 04h : 22m',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827))),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const SubmitProposalModal(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF276572),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Submit Proposal',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),

             
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/infro.svg',
                      width: 22,
                      height: 22,
                      colorFilter: const ColorFilter.mode(
                          Color(0xFF276572), BlendMode.srcIn),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Project Description',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Complete renovation of 40-room luxury hotel including structural reinforcement and interior remodeling.',
                  style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4B5563),
                      height: 1.6),
                ),
              ),
              const SizedBox(height: 20),

              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _detailRow(
                      icon: 'assets/images/check-circle.svg',
                      label: 'PROJECT TYPE',
                      value: 'Commercial',
                      color: const Color(0xFF059669),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _detailItem(
                            'assets/images/bill-list.svg',
                            'ESTIMATED BUDGET',
                            '₦45,000,000',
                            const Color(0xFF276572),
                          ),
                        ),
                        Expanded(
                          child: _detailItem(
                            'assets/images/Calendar.svg',
                            'EXPECTED START',
                            'March 2026',
                            const Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _detailItem(
                            'assets/images/clock-circle.svg',
                            'DURATION',
                            '6 Months',
                            const Color(0xFF6B7280),
                          ),
                        ),
                        Expanded(
                          child: _detailItem(
                            'assets/images/map-1.svg',
                            'EXACT LOCATION',
                            'Lekki, Lagos',
                            const Color(0xFFF5B546),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _detailRow(
                      icon: 'assets/images/shield-warning.svg',
                      label: 'VERIFICATION',
                      value: 'Required',
                      color: const Color(0xFF6B7280),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                      top: BorderSide(color: Color(0xFFF0F2F5))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _tabButton(
                      context,
                      label: 'Overview',
                      iconPath: 'assets/images/home-2.svg',
                      iconColor: const Color(0xFF98A2B3),
                      onTap: () => _showOverview(context),
                    ),
                    _tabButton(
                      context,
                      label: 'Documents',
                      iconPath: 'assets/images/document-1.svg',
                      iconColor: const Color(0xFF98A2B3),
                      onTap: () => _showDocuments(context),
                    ),
                    _tabButton(
                      context,
                      label: 'Site',
                      iconPath: 'assets/images/site.svg',
                      iconColor: const Color(0xFF98A2B3),
                      onTap: () => _showSite(context),
                    ),
                    _tabButton(
                      context,
                      label: 'Client',
                      iconPath: 'assets/images/more.svg',
                      iconColor: const Color(0xFF98A2B3),
                      onTap: () => _showClient(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }



  static Widget _badge(String text, Color bg, Color fg,
      {double letterSpacing = 0}) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: fg,
            letterSpacing: letterSpacing),
      ),
    );
  }

  static Widget _tabButton(
    BuildContext context, {
    required String label,
    required String iconPath,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            iconPath,
            width: 22,
            height: 22,
            colorFilter:
                ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
                fontSize: 12, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  static Widget _detailRow({
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(icon,
            width: 18,
            height: 18,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9CA3AF),
                    letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827))),
          ],
        ),
      ],
    );
  }

  static Widget _detailItem(
      String icon, String label, String value, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(icon,
            width: 18,
            height: 18,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9CA3AF),
                      letterSpacing: 0.5)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827))),
            ],
          ),
        ),
      ],
    );
  }
}



class _OverviewSheet extends StatelessWidget {
  const _OverviewSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.all(24),
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgPicture.asset(
                  'assets/images/home-2.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                      Color(0xFF276572), BlendMode.srcIn),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Overview',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827)),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                      color: Color(0xFFF3F4F6),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.close,
                      size: 18, color: Color(0xFF6B7280)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text('Phases',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827))),
          const SizedBox(height: 20),
          _phaseItem('Documents Submitted', false),
          _phaseItem('Identity Vetted', false),
          _phaseItem('Field Office Inspection', false),
          _phaseItem('Verification Finalized', true),
        ],
      ),
    );
  }

  Widget _phaseItem(String label, bool isLast) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: const Color(0xFFBFDBFE), width: 2),
                ),
                child: Center(
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFF276572), width: 2),
                    ),
                    child: Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: Color(0xFF276572),
                            shape: BoxShape.circle),
                      ),
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Container(width: 2, height: 36, color: const Color(0xFFE5E7EB)),
            ],
          ),
          const SizedBox(width: 16),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111827)),
            ),
          ),
        ],
      ),
    );
  }
}



class _DocumentsSheet extends StatelessWidget {
  const _DocumentsSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.all(24),
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgPicture.asset(
                  'assets/images/document-1.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                      Color(0xFF276572), BlendMode.srcIn),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Documents',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827)),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                      color: Color(0xFFF3F4F6),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.close,
                      size: 18, color: Color(0xFF6B7280)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Project Documents',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827)),
          ),
          const SizedBox(height: 4),
          const Text(
            '2 files stored securely',
            style:
                TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 16),
          // Upload button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: SvgPicture.asset(
                'assets/images/uplaod-2.svg',
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                    Colors.white, BlendMode.srcIn),
              ),
              label: const Text(
                'Upload Document',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF276572),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Header row
          const Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              children: [
                Expanded(
                    child: Text('Document Name',
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9CA3AF)))),
                Text('Size',
                    style: TextStyle(
                        fontSize: 12, color: Color(0xFF9CA3AF))),
              ],
            ),
          ),
          const Divider(color: Color(0xFFF0F2F5)),
          _docRow('Roofing_Plan_V1', '2.5MB'),
          const Divider(color: Color(0xFFF0F2F5)),
          _docRow('Lekki_Permit_App', '2.5MB'),
          const Divider(color: Color(0xFFF0F2F5)),
        ],
      ),
    );
  }

  Widget _docRow(String name, String size) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SvgPicture.asset(
              'assets/images/document.svg',
              width: 18,
              height: 18,
              colorFilter: const ColorFilter.mode(
                  Color(0xFF059669), BlendMode.srcIn),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(name,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827))),
          ),
          Text(size,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }
}



class _SiteSheet extends StatelessWidget {
  const _SiteSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.all(24),
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgPicture.asset(
                  'assets/images/site.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                      Color(0xFF276572), BlendMode.srcIn),
                ),
              ),
              const SizedBox(width: 12),
              const Text('Site',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827))),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                      color: Color(0xFFF3F4F6),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.close,
                      size: 18, color: Color(0xFF6B7280)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Map image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/container-1.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: const Color(0xFF309DAA)),
                  ),
                ),
                const Positioned(
                  top: 16,
                  left: 16,
                  child: Text(
                    'Site Locator',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // GPS Coordinates box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF0F2F5)),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 4,
                    offset: Offset(0, 1))
              ],
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/street.svg',
                  width: 24,
                  height: 24,
                  // street.svg native color is #2A8090 — no colorFilter needed
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'GPS Coordinates',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827)),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '6.4281° N, 3.4219° E',
                      style: TextStyle(
                          fontSize: 13, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _ClientSheet extends StatelessWidget {
  const _ClientSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.50,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.all(24),
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgPicture.asset(
                  'assets/images/more.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                      Color(0xFF276572), BlendMode.srcIn),
                ),
              ),
              const SizedBox(width: 12),
              const Text('Client',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827))),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                      color: Color(0xFFF3F4F6),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.close,
                      size: 18, color: Color(0xFF6B7280)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Client profile row
          Row(
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/images/chinedu.png',
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const CircleAvatar(
                    radius: 26,
                    backgroundColor: Color(0xFF276572),
                    child: Text('CO',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Text(
                        'Chinedu Okafor',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827)),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.verified,
                          color: Color(0xFF2A8090), size: 18),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: const [
                      Icon(Icons.star,
                          color: Color(0xFFF59E0B), size: 14),
                      SizedBox(width: 4),
                      Text('4.9',
                          style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280))),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFF0F2F5)),
          const SizedBox(height: 16),
          // Stats grid
          Row(
            children: [
              _statCell('PROJECTS', '8'),
              _statCell('HIRE RATE', '90%'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statCell('AVG. PAY', 'On time'),
              _statCell('REPLIES', '1 hour'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCell(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9CA3AF),
                letterSpacing: 0.4),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827)),
          ),
        ],
      ),
    );
  }
}
