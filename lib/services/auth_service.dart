import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();
final FacebookLogin _fbLogin = FacebookLogin();
final Firestore _firestore = Firestore.instance;

Future<String> signInWithGoogle() async {
  try {
    final GoogleSignInAccount googleSignInAccount =
        await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final AuthResult authResult = await _auth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    String name;
    String email;
    String photoUrl;

    assert(user.email != null);
    assert(user.displayName != null);
    assert(user.photoUrl != null);

    name = user.displayName;
    email = user.email;
    photoUrl = user.photoUrl;

    DocumentSnapshot doc =
        await _firestore.collection("/users").document(user.uid).get();

    if (!doc.exists) {
      _firestore.collection("/users").document(user.uid).setData({
        "name": name,
        "email": email,
        "photoUrl": photoUrl,
      });
    }

    return 'Success';
  } catch (error) {
    return 'Failure';
  }
}

Future<String> signInWithFacebook() async {
  Dio dio = Dio();

  try {
    final FacebookLoginResult result = await _fbLogin.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.cancelledByUser:
        print("Login cancelled by user");
        return "Failure";

      case FacebookLoginStatus.error:
        print("Login error encountered");
        return "Failure";

      case FacebookLoginStatus.loggedIn:
        final AuthCredential credential = FacebookAuthProvider.getCredential(
            accessToken: result.accessToken.token);

        // Using Facebook Graph API
        var graphResponse = await dio.get(
            'https://graph.facebook.com/v2.12/me?fields=name,email,picture.height(200)&access_token=${result.accessToken.token}');
        var profileData = json.decode(graphResponse.data);
        print(profileData.toString());

        final AuthResult authResult =
            await _auth.signInWithCredential(credential);
        final FirebaseUser user = authResult.user;

        assert(!user.isAnonymous);
        assert(await user.getIdToken() != null);

        final FirebaseUser currentUser = await _auth.currentUser();
        assert(user.uid == currentUser.uid);

        String name;
        String email;
        String photoUrl;

        name = profileData["name"];
        email = profileData["email"];
        photoUrl = profileData["picture"]["data"]["url"];

        DocumentSnapshot doc =
            await _firestore.collection("/users").document(user.uid).get();

        if (!doc.exists) {
          _firestore.collection("/users").document(user.uid).setData({
            "name": name,
            "email": email,
            "photoUrl": photoUrl,
          });
        }

        return 'Success';

      default:
        return 'Failure';
    }
  } catch (error) {
    return 'Failure';
  }
}

Future<String> signInGuest() async {
  try {
    AuthResult authResult = await _auth.signInAnonymously();
    FirebaseUser user = authResult.user;
    print("${user.uid}");
    return 'Success';
  } catch (error) {
    return 'Failure';
  }
}

Future<void> signOutGoogle() async {
  await _googleSignIn.signOut();
  await _auth.signOut();

  print("User Sign Out");
}

Future<void> signOutFacebook() async {
  await _fbLogin.logOut();
  await _auth.signOut();

  print("User Sign Out");
}

Future<void> signOutGuest() async {
  await _auth.signOut();
  print("User Sign Out");
}
