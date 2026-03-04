import 'package:flutter/material.dart';

class SearchEmptyState extends StatelessWidget {
  final String query;

  const SearchEmptyState({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/emptystate.png',
            width: 140, // Slightly scaled down based on design
            height: 140,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 24),
          const Text(
            'No search result',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(
            height: 100,
          ), // Push it slightly up from absolute center
        ],
      ),
    );
  }
}
