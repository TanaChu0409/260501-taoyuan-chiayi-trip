import 'package:flutter_test/flutter_test.dart';
import 'package:trip_planner_app/features/trips/data/invite_member_result.dart';

void main() {
  group('inviteMemberStatusFromBackend', () {
    test('maps backend success status', () {
      expect(
        inviteMemberStatusFromBackend('success'),
        InviteMemberStatus.success,
      );
    });

    test('maps backend user not found status', () {
      expect(
        inviteMemberStatusFromBackend('user_not_found'),
        InviteMemberStatus.userNotFound,
      );
    });

    test('maps backend already member status', () {
      expect(
        inviteMemberStatusFromBackend('already_member'),
        InviteMemberStatus.alreadyMember,
      );
    });

    test('maps backend not owner status', () {
      expect(
        inviteMemberStatusFromBackend('not_owner'),
        InviteMemberStatus.notOwner,
      );
    });

    test('maps backend cannot invite self status', () {
      expect(
        inviteMemberStatusFromBackend('cannot_invite_self'),
        InviteMemberStatus.cannotInviteSelf,
      );
    });

    test('falls back to invalid permission for unknown backend status', () {
      expect(
        inviteMemberStatusFromBackend('invalid_permission'),
        InviteMemberStatus.invalidPermission,
      );
      expect(
        inviteMemberStatusFromBackend('unexpected'),
        InviteMemberStatus.invalidPermission,
      );
      expect(
        inviteMemberStatusFromBackend(null),
        InviteMemberStatus.invalidPermission,
      );
    });
  });
}
