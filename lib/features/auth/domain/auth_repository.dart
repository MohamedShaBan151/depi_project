abstract class AuthRepository {
  Future<void> signIn(String email, String password);
  Future<void> signOut();
  Future<bool> isSignedIn();

  Future<bool> checkEmailExists(String email);
}