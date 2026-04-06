import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ai_credits_models.dart';
import '../repositories/ai_credits_repository.dart';

final aiCreditsProvider = FutureProvider<AiCreditsBalance>((ref) async {
  final repository = ref.watch(aiCreditsRepositoryProvider);
  return repository.fetchAiCredits();
});
