
import 'package:flutter_test/flutter_test.dart';
import 'package:skillsapp/models/models.dart';

void main() {
  group('UserModel', () {
    test('fromJson creates correct user', () {
      final json = {
        'email': 'test@example.com',
        'name': 'Test User',
        'avatarUrl': 'http://example.com/avatar.png'
      };

      final user = UserModel.fromJson(json);

      expect(user.email, 'test@example.com');
      expect(user.name, 'Test User');
      expect(user.avatarUrl, 'http://example.com/avatar.png');
    });

    test('toJson creates correct map', () {
      final user = UserModel(
        email: 'test@example.com',
        name: 'Test User',
        avatarUrl: 'http://example.com/avatar.png'
      );

      final json = user.toJson();

      expect(json['email'], 'test@example.com');
      expect(json['name'], 'Test User');
      expect(json['avatarUrl'], 'http://example.com/avatar.png');
    });
  });
}
