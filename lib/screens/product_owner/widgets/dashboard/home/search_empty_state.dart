import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SearchEmptyState extends StatelessWidget {
  final String query;

  const SearchEmptyState({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/images/emptystate.svg',
            width: 140,
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
          ), 
        ],
      ),
    );
  }
}
