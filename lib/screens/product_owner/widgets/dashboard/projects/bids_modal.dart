import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../../../../features/marketplace/providers/marketplace_providers.dart';
import '../../../../../features/marketplace/models/bid.dart';
import '../../../../contractor/projects/widgets/tools/bid_detail_screen.dart';
import '../../../../contractor/projects/widgets/tools/contractor_profile_screen.dart';

class BidsModal extends ConsumerWidget {
  final String projectId;

  const BidsModal({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bidsAsync = ref.watch(projectBidsProvider((projectId: projectId, page: 1)));

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Project Bids',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF101828),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 20, color: Color(0xFF4B5563)),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: bidsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF276572))),
              error: (error, _) => Center(child: Text('Error loading bids: $error')),
              data: (response) {
                final bids = response.data;
                if (bids.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset('assets/images/projects.svg', width: 64, height: 64, colorFilter: ColorFilter.mode(Colors.grey[300]!, BlendMode.srcIn)),
                        const SizedBox(height: 16),
                        const Text('No bids yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF667085))),
                        const SizedBox(height: 8),
                        const Text('Once contractors bid on this project,\nthey will appear here.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF98A2B3))),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: bids.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final bid = bids[index];
                    return _BidCard(bid: bid, projectId: projectId);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BidCard extends ConsumerWidget {
  final Bid bid;
  final String projectId;

  const _BidCard({required this.bid, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormat = NumberFormat.currency(symbol: '₦', decimalDigits: 0);
    final isLoading = ref.watch(marketplaceActionProvider).isLoading;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAECF0)),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: bid.contractor?.avatar != null ? NetworkImage(bid.contractor!.avatar!) : null,
                child: bid.contractor?.avatar == null ? const Icon(Icons.person) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${bid.contractor?.firstName} ${bid.contractor?.lastName}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF101828)),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ContractorProfileScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'View Profile',
                        style: TextStyle(fontSize: 12, color: const Color(0xFF276572), fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormat.format(bid.amount),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF276572)),
                  ),
                  const Text('Proposed Budget', style: TextStyle(fontSize: 11, color: Color(0xFF667085))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('PROPOSAL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475467), letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(
            bid.proposal,
            style: const TextStyle(fontSize: 14, color: Color(0xFF344054), height: 1.5),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (bid.duration != null || bid.paymentPreference != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (bid.duration != null)
                  Chip(
                    avatar: const Icon(Icons.access_time, size: 14, color: Color(0xFF667085)),
                    label: Text(bid.duration!, style: const TextStyle(fontSize: 12, color: Color(0xFF475467))),
                    backgroundColor: const Color(0xFFF9FAFB),
                    side: const BorderSide(color: Color(0xFFEAECF0)),
                  ),
                if (bid.paymentPreference != null)
                  Chip(
                    avatar: const Icon(Icons.payment, size: 14, color: Color(0xFF667085)),
                    label: Text(bid.paymentPreference!, style: const TextStyle(fontSize: 12, color: Color(0xFF475467))),
                    backgroundColor: const Color(0xFFF9FAFB),
                    side: const BorderSide(color: Color(0xFFEAECF0)),
                  ),
              ],
            ),
          ],
          if (bid.equipment != null && bid.equipment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text('EQUIPMENT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475467), letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: bid.equipment!.map((e) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFF2F4F7), borderRadius: BorderRadius.circular(4)),
                child: Text(e, style: const TextStyle(fontSize: 12, color: Color(0xFF344054))),
              )).toList(),
            ),
          ],
          if (bid.milestones != null && bid.milestones!.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text('MILESTONES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475467), letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: bid.milestones!.take(3).map((m) {
                final title = m['title'] ?? 'Milestone';
                final amount = m['amount']?.toString() ?? '0';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, size: 14, color: Color(0xFF276572)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(title.toString(), style: const TextStyle(fontSize: 12, color: Color(0xFF344054)))),
                      Text('₦$amount', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF344054))),
                    ],
                  ),
                );
              }).toList(),
            ),
            if (bid.milestones!.length > 3)
              Text('+ ${bid.milestones!.length - 3} more', style: const TextStyle(fontSize: 12, color: Color(0xFF276572))),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BidDetailScreen(bid: bid)),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFEAECF0)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('View Full Proposal', style: TextStyle(color: Color(0xFF344054), fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    try {
                      await ref.read(marketplaceActionProvider.notifier).acceptBid(bid.id, projectId: projectId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Bid accepted successfully! Contractor assigned.')),
                        );
                        Navigator.pop(context); // Close modal
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF276572),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Accept & Assign', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: isLoading ? null : () async {
                  try {
                    await ref.read(marketplaceActionProvider.notifier).rejectBid(bid.id, projectId: projectId);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bid declined successfully.')),
                      );
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFD0D5DD)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Decline', style: TextStyle(color: Color(0xFF344054))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
