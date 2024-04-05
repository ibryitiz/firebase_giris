import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late FirebaseAuth auth;
  final String _email = "test@gmail.com";
  final String _password = "123456";
  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
    auth.authStateChanges().listen((User? user) {
      if (user == null) {
        // User oturum kapalı
        debugPrint("user is currently signed out!");
      } else {
        // User oturum açık ve email durumu
        debugPrint("user is signed in! ${user.email} and email state ${user.emailVerified}");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppbar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppbar() {
    return AppBar(
      title: const Text('Home'),
    );
  }

  Widget _buildBody() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          functions(() {
            createUserEmailAndPassword();
          }, "Register"),
          functions(() {
            loginUserEmailAndPassword();
          }, "Login"),
          functions(() {
            signOutUser();
          }, "Sign Out"),
          functions(() {
            deleteUser();
          }, "Delete User"),
          functions(() {
            changePassword();
          }, "Change Password"),
        ],
      ),
    );
  }

// Buttons

  Widget functions(void Function() funcName, String buttonName) {
    return ElevatedButton(
        onPressed: () {
          funcName();
        },
        child: Text(buttonName));
  }

// FUNCTIONS

// KULLANICI KAYIT
  void createUserEmailAndPassword() async {
    try {
      // ignore: no_leading_underscores_for_local_identifiers
      var _userCredential = await auth.createUserWithEmailAndPassword(email: _email, password: _password);
      // ignore: no_leading_underscores_for_local_identifiers
      var _myUser = _userCredential.user;
      if (!_myUser!.emailVerified) {
        _myUser.sendEmailVerification();
      } else {
        debugPrint("email is verified!");
      }
      debugPrint(_userCredential.toString());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

//KULLANICI GİRİŞ
  void loginUserEmailAndPassword() async {
    try {
      // ignore: no_leading_underscores_for_local_identifiers
      var _userCredential = await auth.signInWithEmailAndPassword(email: _email, password: _password);
      // giriş başarılı
      debugPrint("Login Success");
      debugPrint(_userCredential.toString());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

// KULLANICI ÇIKIŞ
  void signOutUser() async {
    await auth.signOut();
  }

// KULLANICI HESABINI SİL
  void deleteUser() async {
    if (auth.currentUser != null) {
      await auth.currentUser!.delete();
    } else {
      // oturum açık değil giriş yap önce
      debugPrint("user is not signed in!");
    }
  }

// KULLANICI ŞİFRE DEĞİŞTİR
  void changePassword() async {
    try {
      await auth.currentUser!.updatePassword("123456");
      await auth.signOut();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        debugPrint("reauthenticate olunacak");
        var credential = EmailAuthProvider.credential(email: _email, password: _password);
        await auth.currentUser!.reauthenticateWithCredential(credential);
        await auth.currentUser!.updatePassword("123456");
        await auth.signOut();
        debugPrint("Password updated");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
