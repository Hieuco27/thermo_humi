import 'dart:math';
import 'package:thermo_humi/features/member_management/domain/entities/member.dart';
import 'package:thermo_humi/features/member_management/domain/repositories/member_repository.dart';

class FakeMemberRepository implements MemberRepository {
  // Hardcoded mock data
  final List<Member> _members = [
    const Member(
      id: '1',
      name: 'Nguyễn Văn A',
      email: 'a.nguyen@hms.tech',
      role: MemberRole.admin,
      isCurrentUser: true,
    ),
    const Member(
      id: '2',
      name: 'Trần Thị B',
      email: 'b.tran@hms.tech',
      role: MemberRole.editor,
    ),
    const Member(
      id: '3',
      name: 'Lê Văn C',
      email: 'c.le@hms.tech',
      role: MemberRole.viewer,
    ),
    const Member(
      id: '4',
      name: 'Phạm Thị D',
      email: 'd.pham@hms.tech',
      role: MemberRole.editor,
    ),
    const Member(
      id: '5',
      name: 'Hoàng Văn E',
      email: 'e.hoang@hms.tech',
      role: MemberRole.viewer,
      isPending: true,
    ),
  ];

  final Random _random = Random();

  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  Future<void> _simulateRandomError() async {
    if (_random.nextDouble() < 0.1) {
      throw Exception('Lỗi kết nối máy chủ. Vui lòng thử lại sau.');
    }
  }

  @override
  Future<List<Member>> getMembers() async {
    await _simulateNetworkDelay();
    return List.from(_members); // Return a copy
  }

  @override
  Future<void> updateRole(String id, MemberRole newRole) async {
    await _simulateNetworkDelay();
    await _simulateRandomError();
    
    final index = _members.indexWhere((m) => m.id == id);
    if (index != -1) {
      _members[index] = _members[index].copyWith(role: newRole);
    } else {
      throw Exception('Không tìm thấy thành viên');
    }
  }

  @override
  Future<void> removeMember(String id) async {
    await _simulateNetworkDelay();
    await _simulateRandomError();
    
    _members.removeWhere((m) => m.id == id);
  }

  @override
  Future<void> resendInvite(String id) async {
    await _simulateNetworkDelay();
    await _simulateRandomError();
    // Simulate sending email success
  }

  @override
  Future<void> revokeInvite(String id) async {
    await _simulateNetworkDelay();
    await _simulateRandomError();
    _members.removeWhere((m) => m.id == id);
  }
}
