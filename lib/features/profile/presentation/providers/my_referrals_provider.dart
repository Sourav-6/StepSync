import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_sync/features/auth/domain/entities/user_entity.dart';
import 'package:step_sync/features/auth/presentation/providers/auth_provider.dart';

final myReferralsProvider = FutureProvider.autoDispose<List<UserEntity>>((ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return [];

  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.getReferredUsers(user.uid);
});
