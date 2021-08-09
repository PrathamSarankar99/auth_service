library auth_service;

import 'package:auth_service/auth_service_exception.dart';
import 'package:auth_service/auth_service_objects.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

class AuthService {
  //It is a stream of user. The data in the stream will be null if the current user is null
  static Stream<User?> userStream() {
    return FirebaseAuth.instance.authStateChanges();
  }

  //This function should be called in the main method of the app.
  static initialize() async {
    await Firebase.initializeApp();
  }

  //The function below will return the current User.
  static User? get currentUser => FirebaseAuth.instance.currentUser;

  //The function below should be used to log in with Google. If the log in is successful, it will
  //return True, else false.
  static Future<bool> signInWithGoogle() async {
    try {
      GoogleSignIn googleSignIn = GoogleSignIn();
      GoogleSignInAccount? account = await googleSignIn.signIn();
      GoogleSignInAuthentication authentication = await account!.authentication;
      OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authentication.accessToken,
        idToken: authentication.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      return true;
    } catch (e) {
      return false;
    }
  }

  //The function below should be called to log in anonymously
  static Future<bool> signInAnonymously() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      return true;
    } catch (e) {
      return false;
    }
  }

  //The function below will send the OTP to the formated phoneno provided and the timeout will be the duration
  //specified.
  static Future<bool> sendOTP(String phoneno, Duration timeout) async {
    bool result = false;
    await FirebaseAuth.instance.verifyPhoneNumber(
      timeout: timeout,
      phoneNumber: phoneno,
      verificationCompleted: (phoneAuthCredential) {
        FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
        result = true;
      },
      verificationFailed: (error) {
        AuthServiceException.exception = error;
      },
      codeSent: (verificationId, forceResendingToken) {
        AuthServiceObjects.phoneAuthVerificationID = verificationId;
        AuthServiceObjects.phoneAuthResendingID = forceResendingToken;
      },
      codeAutoRetrievalTimeout: (verificationId) {
        AuthServiceObjects.phoneAuthVerificationID = verificationId;
      },
    );
    return result;
  }

  //The method below will be used to check the OTP sent to the user. It will return True, if it's matches,
  //else, it will return False.
  static Future<bool> verifyOTP(String otp) async {
    try {
      PhoneAuthCredential authCredential = PhoneAuthProvider.credential(
          verificationId: AuthServiceObjects.phoneAuthVerificationID,
          smsCode: otp);
      await FirebaseAuth.instance.signInWithCredential(authCredential);
      return true;
    } catch (e) {
      return false;
    }
  }

  //The function below is called when user need to log in with facebook. It will only use web
  //to initiate it.
  static Future<bool> signInWithFacebook() async {
    FacebookLogin facebookLogin = FacebookLogin();
    facebookLogin.loginBehavior = FacebookLoginBehavior.webOnly;
    FacebookLoginResult result = await facebookLogin.logIn(['email']);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;
        OAuthCredential authCredential =
            FacebookAuthProvider.credential(accessToken.token);
        await FirebaseAuth.instance.signInWithCredential(authCredential);
        return true;
      default:
        {
          return false;
        }
    }
  }

  // The method below is called when we the user needs to signOut. The currentUser will return null once this // method is called.
  static Future<bool> signOut() async {
    try {
      await GoogleSignIn().signOut();
      await FacebookLogin().logOut();
      await FirebaseAuth.instance.signOut();
      return true;
    } catch (e) {
      return false;
    }
  }
}
