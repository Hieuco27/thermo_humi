import 'package:thermo_humi/features/member_management/domain/entities/member.dart';

abstract class MemberRepository {
  Future<List<Member>> getMembers();
  Future<void> updateRole(String id, MemberRole newRole);
  Future<void> removeMember(String id);
  Future<void> resendInvite(String id);
  Future<void> revokeInvite(String id);
}
