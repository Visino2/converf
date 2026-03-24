import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/contractor_models.dart';
import '../repositories/contractor_repository.dart';

/// Provider for fetching the list of contractors.
/// Mirrors the React `useContractors(specialisation?: string)` hook. 
final contractorsProvider = FutureProvider.family<ContractorsResponse, String?>((ref, specialisation) async {
  final repository = ref.read(contractorRepositoryProvider);
  return repository.fetchContractors(specialisation: specialisation);
});
