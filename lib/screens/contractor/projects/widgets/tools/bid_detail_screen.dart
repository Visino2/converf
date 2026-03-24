import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:converf/features/marketplace/models/bid.dart';
import 'package:converf/screens/contractor/projects/widgets/tools/contractor_profile_screen.dart';

class BidDetailScreen extends StatelessWidget {
  final Bid bid;

  const BidDetailScreen({super.key, required this.bid});

  @override
  Widget build(BuildContext context) {
    final project = bid.project;
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
          style: TextStyle(color: Color(0xFF111827), fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
                      _buildStatusBadge(bid.status),
                      Text(
                        DateFormat('MMM d, y').format(DateTime.parse(bid.createdAt)),
                        style: const TextStyle(fontSize: 12, color: Color(0xFF667085)),
                      ),
                    ],
                   ),
                  const SizedBox(height: 16),
                  Text(
                    project?.title ?? 'Project Title',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      if (bid.contractorId.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ContractorProfileScreen(),
                          ),
                        );
                      }
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline, size: 16, color: Color(0xFF276572)),
                        const SizedBox(width: 4),
                        Text(
                          '${bid.contractor?.firstName} ${bid.contractor?.lastName}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF276572)),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF276572)),
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
                    style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(bid.amount),
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  if (bid.paymentPreference != null) ...[
                    const SizedBox(height: 16),
                     Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        bid.paymentPreference!,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Duration and Stats
            if (bid.duration != null)
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
                    const Icon(Icons.access_time_outlined, color: Color(0xFF667085), size: 20),
                    const SizedBox(width: 12),
                    const Text('Proposed Duration', style: TextStyle(color: Color(0xFF667085))),
                    const Spacer(),
                    Text(
                      bid.duration!,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF101828)),
                    ),
                  ],
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
                bid.proposal,
                style: const TextStyle(fontSize: 15, color: Color(0xFF4B5563), height: 1.6),
              ),
            ),

            // Milestones
            if (bid.milestones != null && bid.milestones!.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSectionHeader('Execution Milestones'),
              Container(
                color: Colors.white,
                child: Column(
                  children: bid.milestones!.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final m = entry.value;
                    final title = m['title'] ?? 'Milestone';
                    final amount = m['amount']?.toString() ?? '0';
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: idx < bid.milestones!.length - 1 
                            ? const Border(bottom: BorderSide(color: Color(0xFFF2F4F7))) 
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
                            child: Text('${idx + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475467))),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title.toString(), style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF101828))),
                                const SizedBox(height: 4),
                                const Text('Payment upon completion', style: TextStyle(fontSize: 12, color: Color(0xFF667085))),
                              ],
                            ),
                          ),
                          Text(
                            currencyFormat.format(num.parse(amount)),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF101828)),
                          ),
                        ],
                      ),
                    );
                  }).cast<Widget>().toList(),
                ),
              ),
            ],

            // Equipment
            if (bid.equipment != null && bid.equipment!.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSectionHeader('Equipment & Resources'),
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: bid.equipment!.map((e) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE4E7EC)),
                    ),
                    child: Text(e, style: const TextStyle(color: Color(0xFF344054), fontWeight: FontWeight.w500)),
                  )).toList(),
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
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }
}
