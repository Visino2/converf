import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:converf/features/marketplace/models/bid.dart';
import 'package:converf/features/marketplace/providers/marketplace_providers.dart';
import 'package:converf/screens/contractor/projects/schedule/schedule_screen.dart';
import 'package:converf/screens/contractor/projects/widgets/tools/contractor_profile_screen.dart';

class BidDetailScreen extends ConsumerStatefulWidget {
  final Bid bid;

  const BidDetailScreen({super.key, required this.bid});

  @override
  ConsumerState<BidDetailScreen> createState() => _BidDetailScreenState();
}

class _BidDetailScreenState extends ConsumerState<BidDetailScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        debugPrint('[BidDetail] Auto-refreshing bid ${widget.bid.id}...');
        ref.invalidate(myBidsProvider(1));
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Try to find the latest version of this bid if myBidsProvider has been refreshed
    final bidsAsync = ref.watch(myBidsProvider(1));
    final currentBid = bidsAsync.maybeWhen(
      data: (response) {
        try {
          return response.data.firstWhere((b) => b.id == widget.bid.id);
        } catch (_) {
          return widget.bid;
        }
      },
      orElse: () => widget.bid,
    );

    final project = currentBid.project;
    final currencyFormat = NumberFormat.currency(symbol: '₦', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Proposal Details',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatusBadge(currentBid.status),
                      Text(
                        DateFormat(
                          'MMM d, y',
                        ).format(DateTime.parse(currentBid.createdAt)),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF667085),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    project?.title ?? 'Project Title',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      if (currentBid.contractorId.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ContractorProfileScreen(),
                          ),
                        );
                      }
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 16,
                          color: Color(0xFF276572),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${currentBid.contractor?.firstName} ${currentBid.contractor?.lastName}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF276572),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: Color(0xFF276572),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Bid Amount Card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF276572),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF276572).withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bid Amount',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(currentBid.amount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (currentBid.paymentPreference != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        currentBid.paymentPreference!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Duration and Stats
            if (currentBid.duration != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEAECF0)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time_outlined,
                      color: Color(0xFF667085),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Proposed Duration',
                      style: TextStyle(color: Color(0xFF667085)),
                    ),
                    const Spacer(),
                    Text(
                      currentBid.duration!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF101828),
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 8),

            // Proposed Schedule Access
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEAECF0)),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ScheduleScreen(
                        bidId: currentBid.id,
                        projectId: currentBid.projectId,
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_outlined,
                      color: Color(0xFF667085),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Proposed Schedule',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF101828),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF276572),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Color(0xFF276572),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Proposal Text
            _buildSectionHeader('Contractor Proposal'),
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Text(
                currentBid.proposal,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF4B5563),
                  height: 1.6,
                ),
              ),
            ),

            // Milestones
            if (currentBid.milestones != null &&
                currentBid.milestones!.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSectionHeader('Execution Milestones'),
              Container(
                color: Colors.white,
                child: Column(
                  children: currentBid.milestones!
                      .asMap()
                      .entries
                      .map((entry) {
                        final idx = entry.key;
                        final m = entry.value;
                        final title = m['title'] ?? 'Milestone';
                        final amount = m['amount']?.toString() ?? '0';
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: idx < currentBid.milestones!.length - 1
                                ? const Border(
                                    bottom: BorderSide(
                                      color: Color(0xFFF2F4F7),
                                    ),
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF0F2F5),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${idx + 1}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF475467),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title.toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF101828),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Payment upon completion',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF667085),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                currencyFormat.format(num.parse(amount)),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF101828),
                                ),
                              ),
                            ],
                          ),
                        );
                      })
                      .cast<Widget>()
                      .toList(),
                ),
              ),
            ],

            // Equipment
            if (currentBid.equipment != null &&
                currentBid.equipment!.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSectionHeader('Equipment & Resources'),
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: currentBid.equipment!
                      .map(
                        (e) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F4F7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE4E7EC)),
                          ),
                          child: Text(
                            e,
                            style: const TextStyle(
                              color: Color(0xFF344054),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],

            // Documents Section
            if (currentBid.documents != null && currentBid.documents!.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSectionHeader('Supporting Documents'),
              Container(
                color: Colors.white,
                child: Column(
                  children: currentBid.documents!.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final doc = entry.value;
                    return ListTile(
                      leading: const Icon(Icons.description_outlined, color: Color(0xFF276572)),
                      title: Text(
                        doc.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF101828),
                        ),
                      ),
                      trailing: const Icon(Icons.open_in_new, size: 18, color: Color(0xFF667085)),
                      onTap: () => _openDocument(doc.url),
                      shape: idx < currentBid.documents!.length - 1
                          ? const Border(bottom: BorderSide(color: Color(0xFFF2F4F7)))
                          : null,
                    );
                  }).toList(),
                ),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF667085),
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    switch (status.toLowerCase()) {
      case 'accepted':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF166534);
        break;
      case 'shortlisted':
        bg = const Color(0xFFF0FBFB);
        fg = const Color(0xFF309DAA);
        break;
      case 'rejected':
      case 'declined':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFF991B1B);
        break;
      case 'pending':
      default:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFF92400E);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Future<void> _openDocument(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open document')),
        );
      }
    }
  }
}
