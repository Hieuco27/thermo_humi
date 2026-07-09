import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thermo_humi/features/member_management/domain/entities/member.dart';
import 'package:thermo_humi/features/member_management/domain/repositories/member_repository.dart';
import 'package:thermo_humi/features/member_management/presentation/cubit/member_state.dart';

class MemberCubit extends Cubit<MemberState> {
  final MemberRepository repository;

  MemberCubit({required this.repository}) : super(const MemberState());

  Future<void> fetchMembers() async {
    emit(state.copyWith(status: MemberStatus.loading));
    try {
      final members = await repository.getMembers();
      emit(state.copyWith(
        status: MemberStatus.success,
        members: members,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MemberStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void search(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  Future<void> updateRole(String memberId, MemberRole newRole) async {
    final oldMembers = List<Member>.from(state.members);
    
    // Optimistic Update
    final newMembers = oldMembers.map((m) {
      if (m.id == memberId) {
        return m.copyWith(role: newRole);
      }
      return m;
    }).toList();
    
    emit(state.copyWith(members: newMembers, errorMessage: null));

    try {
      await repository.updateRole(memberId, newRole);
    } catch (e) {
      // Rollback on failure
      emit(state.copyWith(
        members: oldMembers,
        status: MemberStatus.failure,
        errorMessage: e.toString(),
      ));
      // Revert to success to clear error event
      emit(state.copyWith(status: MemberStatus.success, errorMessage: null));
    }
  }

  Future<void> removeMember(String memberId) async {
    final oldMembers = List<Member>.from(state.members);
    
    // Optimistic Update
    final newMembers = oldMembers.where((m) => m.id != memberId).toList();
    emit(state.copyWith(members: newMembers, errorMessage: null));

    try {
      await repository.removeMember(memberId);
    } catch (e) {
      // Rollback
      emit(state.copyWith(
        members: oldMembers,
        status: MemberStatus.failure,
        errorMessage: e.toString(),
      ));
      emit(state.copyWith(status: MemberStatus.success, errorMessage: null));
    }
  }

  Future<void> resendInvite(String memberId) async {
    // No optimistic update for UI list needed here
    try {
      await repository.resendInvite(memberId);
    } catch (e) {
      emit(state.copyWith(
        status: MemberStatus.failure,
        errorMessage: e.toString(),
      ));
      emit(state.copyWith(status: MemberStatus.success, errorMessage: null));
    }
  }

  Future<void> revokeInvite(String memberId) async {
    await removeMember(memberId); // Same logic as remove
  }
}
