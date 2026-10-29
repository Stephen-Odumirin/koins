import '../models/user_profile.dart';
import '../services/user_api_service.dart';

class ProfileRepository {
  ProfileRepository(this._api);

  final UserApiService _api;

  Future<UserProfile> getProfile() => _api.fetchUser(1);
}
