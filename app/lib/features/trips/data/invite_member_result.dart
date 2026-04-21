enum InviteMemberStatus {
  success,
  userNotFound,
  alreadyMember,
  notOwner,
  cannotInviteSelf,
  invalidPermission,
}

InviteMemberStatus inviteMemberStatusFromBackend(String? value) {
  switch (value) {
    case 'success':
      return InviteMemberStatus.success;
    case 'user_not_found':
      return InviteMemberStatus.userNotFound;
    case 'already_member':
      return InviteMemberStatus.alreadyMember;
    case 'not_owner':
      return InviteMemberStatus.notOwner;
    case 'cannot_invite_self':
      return InviteMemberStatus.cannotInviteSelf;
    case 'invalid_permission':
    default:
      return InviteMemberStatus.invalidPermission;
  }
}

class InviteMemberResult {
  const InviteMemberResult({required this.status});

  final InviteMemberStatus status;

  bool get isSuccess => status == InviteMemberStatus.success;
}
