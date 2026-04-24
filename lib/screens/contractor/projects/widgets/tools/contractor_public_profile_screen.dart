import 'package:flutter/material.dart';
import '../../../../../features/projects/models/project.dart';

class ContractorPublicProfileScreen extends StatelessWidget {
  final ProjectParty contractor;

  const ContractorPublicProfileScreen({super.key, required this.contractor});

  @override
  Widget build(BuildContext context) {
    final displayName = contractor.companyName?.isNotEmpty == true
        ? contractor.companyName!
        : '${contractor.firstName} ${contractor.lastName}';

    final avatarUrl = contractor.avatarUrl ?? contractor.avatar;

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
          'Contractor Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF0F2F5)),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                    backgroundColor: const Color(0xFFF3C08B),
                    child: avatarUrl == null
                        ? Text(
                            contractor.firstName.isNotEmpty
                                ? contractor.firstName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.verified, color: Color(0xFF309DAA), size: 20),
                    ],
                  ),
                  if (contractor.companyName?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${contractor.firstName} ${contractor.lastName}',
                      style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    contractor.email,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
