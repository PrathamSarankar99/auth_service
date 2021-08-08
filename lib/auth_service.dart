library auth_service;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter_facebook_login/flutter_facebook_login.dart';

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}

class AuthService {
  static Stream<User?> authStream() {
    return FirebaseAuth.instance.authStateChanges();
  }

  static User? currentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  static Future<String> signInWithGoogle() async {
    GoogleSignIn googleSignIn = GoogleSignIn();
    GoogleSignInAccount? account = await googleSignIn.signIn();
    GoogleSignInAuthentication authentication = await account!.authentication;
    OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: authentication.accessToken,
      idToken: authentication.idToken,
    );
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    String? name = userCredential.user!.displayName;
    return "Logged in as $name";
  }

  // static Future<String> signInWithFacebook() async {
  //   String response = '';
  //   FacebookLogin facebookLogin = FacebookLogin();
  //   facebookLogin.loginBehavior = FacebookLoginBehavior.webOnly;
  //   FacebookLoginResult result = await facebookLogin.logIn(['email']);
  //   switch (result.status) {
  //     case FacebookLoginStatus.loggedIn:
  //       final FacebookAccessToken accessToken = result.accessToken;
  //       OAuthCredential authCredential =
  //           FacebookAuthProvider.credential(accessToken.token);
  //       UserCredential usercredential =
  //           await FirebaseAuth.instance.signInWithCredential(authCredential);
  //       String name = usercredential.user.displayName;
  //       response = 'Logged in as $name';
  //       break;
  //     case FacebookLoginStatus.cancelledByUser:
  //       response = 'Cancelled by user';
  //       break;
  //     case FacebookLoginStatus.error:
  //       response = 'An error occured';
  //       break;
  //   }
  //   return response;
  // }

  static Future<bool> signOut() async {
    await GoogleSignIn().signOut();
    // await FacebookLogin().logOut();
    await FirebaseAuth.instance.signOut();
    return true;
  }
}
