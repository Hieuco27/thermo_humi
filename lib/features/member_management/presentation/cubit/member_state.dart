import 'package:equatable/equatable.dart';
import 'package:thermo_humi/features/member_management/domain/entities/member.dart';

enum MemberStatus { initial, loading, success, failure }

class MemberState extends Equatable {
  final MemberStatus status;
  final List<Member> members;
  final String searchQuery;
  final String? errorMessage;

  const MemberState({
    this.status = MemberStatus.initial,
    this.members = const [],
    this.searchQuery = '',
    this.errorMessage,
  });

  List<Member> get filteredMembers {
    if (searchQuery.trim().isEmpty) {
      return members;
    }
    final q = searchQuery.trim().toLowerCase();
    return members.where((m) {
      return m.name.toLowerCase().contains(q) || m.email.toLowerCase().contains(q);
    }).toList();
  }

  bool get isLastAdmin {
    // Check if there is only 1 admin who has accepted (not pending)
    int adminCount = members.where((m) => m.role == MemberRole.admin && !m.isPending).length;
    return adminCount <= 1;
  }

  MemberState copyWith({
    MemberStatus? status,
    List<Member>? members,
    String? searchQuery,
    String? errorMessage,
  }) {
    return MemberState(
      status: status ?? this.status,
      members: members ?? this.members,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage, // Có thể muốn null out error
    );
  }

  @override
  List<Object?> get props => [status, members, searchQuery, errorMessage];
}
