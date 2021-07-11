import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

FirebaseAuth _auth = FirebaseAuth.instance;

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _auth
        .authStateChanges()
        .listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        if(user.emailVerified){
          debugPrint('User logged In email verified');
        }else{
          debugPrint('User logged In email not verified');
        }
        print('User is signed in!');
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('Email,password User create'),
              onPressed: _emailPasswordUserCreate,
            ),
            ElevatedButton(
              child: Text('Email,password User Login'),
              onPressed: _emailPasswordUserLogin,
            ),
            ElevatedButton(
              child: Text('Email,password User Logout'),
              onPressed: _emailPasswordUserSignOut,
            ),
            ElevatedButton(
              child: Text('Reset Password'),
              onPressed: _resetPassword,
            ),
            ElevatedButton(
              child: Text('Update Password'),
              onPressed: _updatePassword,
            ),
            ElevatedButton(
              child: Text('Update Email'),
              onPressed: _updateEmail,
            ),
            ElevatedButton(
              child: Text('Sign In with Google Account'),
              onPressed: _signInWithGoogle,
            ),
            ElevatedButton(
              child: Text('SignIn with Phone Number '),
              onPressed: _signInwithPhoneNumber,
            ),
          ],
        ),
      ),
    );
  }

  Future<UserCredential?> _signInWithGoogle() async {
    // Trigger the authentication flow
    try{
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return await _auth.signInWithCredential(credential);
    }catch(e){
      debugPrint('Google SignIn Error $e');
    }
  }


  void _emailPasswordUserCreate() async {
    String? _email = 'emirhan.kalem320@gmail.com';
    String? _password = 'passwordnew';
    try{
      UserCredential _credential = await _auth.createUserWithEmailAndPassword(
          email: _email, password: _password);
      User? _newUser =  _credential.user;
      User? user = _auth.currentUser;

      if (user!= null && !user.emailVerified) {
        await user.sendEmailVerification();
        await _auth.signOut();
      }

    }catch(e){
      debugPrint(e.toString());
    }
  }

  void _emailPasswordUserLogin() async{
    String? _email = 'emirhan.kalem320@gmail.com';
    String? _password = 'password';

    try {
      if(_auth.currentUser == null){
        User? _loggedInUser = (await _auth.signInWithEmailAndPassword(email: _email, password: _password)).user;
        if(_loggedInUser!.emailVerified){
          debugPrint('Thanks mail verified ');
        }else{
          debugPrint('Please verify your mail');
          _auth.signOut();
        }
      }else{
        debugPrint('User already exist');
      }
    }catch(e){
      debugPrint(e.toString());
    }

  }

  void _emailPasswordUserSignOut() async{
    try{
      if(_auth.currentUser!= null){
        await _auth.signOut();
      }else{
        debugPrint('User already not exist');
      }
    }catch(e){
      e.toString();
    }
  }

  void _resetPassword() async{
    String? _email = 'emirhan.kalem320@gmail.com';
    debugPrint('email send');

    try{
      await _auth.sendPasswordResetEmail(email: _email);

    }catch(e){
      debugPrint('Error $e');
    }
  }

  void _updatePassword() async{
    try{
      await _auth.currentUser!.updatePassword('password');
      debugPrint('password updated');
    }catch(e){
      try{
        String email = 'emirhan.kalem320@example.com';
        String password = 'SuperSecretPassword!';


        AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);

        await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(credential);
      }catch(e){
        debugPrint('Error $e');
      }
      debugPrint('password couldn\'t updated $e');
    }
  }

  void _updateEmail() async{
    try{
      await _auth.currentUser!.updateEmail('emir@gmail.com');
      debugPrint('email updated');
    }catch(e){
      try{
        String email = 'barry.allen@example.com';
        String password = 'SuperSecretPassword!';
        AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
        await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(credential);
      }catch(e){
        debugPrint('Error $e');
      }
      debugPrint('email couldn\'t updated $e');
    }
  }

  void _signInwithPhoneNumber() async {
    try{
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+905459451932',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            print('The provided phone number is not valid.');
          }
        },
        codeSent: (String verificationId, int? resendToken)async {
          try{
            String smsCode = '123456';

            // Create a PhoneAuthCredential with the code
            PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);

            // Sign the user in (or link) with the credential
            await _auth.signInWithCredential(credential);
          }catch(e){
            debugPrint('Code Error $e');
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {

        },
      );
    }catch(e){
      debugPrint('Error $e');
    }
  }
}
