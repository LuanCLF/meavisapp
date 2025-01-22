import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;
import 'package:meavisapp/controller/controller.dart';
import 'package:meavisapp/domain/entities.dart';
import 'package:meavisapp/pages/about.dart';
import 'package:meavisapp/pages/admin.dart';
import 'package:meavisapp/pages/home.dart';
import 'package:meavisapp/pages/notifcations.dart';
import 'package:meavisapp/pages/profile.dart';
import 'package:meavisapp/pages/register.dart';
import 'package:meavisapp/pages/login.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Future<void> main() async {
  await dotenv.dotenv.load(fileName: '.env');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminController()),
        ChangeNotifierProvider(create: (_) => UserController()),
        ChangeNotifierProvider(create: (_) => NotificationController()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MEAVISA',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue.shade900, brightness: Brightness.light),
      ),
      home: const MyPage(),
    );
  }
}

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  late AdminController adminController;
  late UserController userController;
  late NotificationController notificationController;
  int _selectedIndex = 0;
  bool _isLoading = true;
  UserLogged? _userLogged;
  bool isLogged = false;

  @override
  void initState() {
    super.initState();
    adminController = Provider.of<AdminController>(context, listen: false);
    userController = Provider.of<UserController>(context, listen: false);
    notificationController =
        Provider.of<NotificationController>(context, listen: false);
    _simulateLoading();
    _onUserLogged();
  }

  void _simulateLoading() async {
    await Future.delayed(Duration(seconds: 3));
    setState(() {
      _isLoading = false;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openRegisterPage() {
    setState(() {
      if (isLogged) {
        _selectedIndex = 1;
      } else {
        _selectedIndex = 3;
      }
    });
  }

  void _onUserLogged() async {
    await userController.getLoggedUser();
    setState(() {
      isLogged = userController.isLogged;
      _userLogged = userController.userLogged;
    });
  }

  Widget _home() {
    if (userController.isLogged) {
      return NotificationHistory(
        notificationController: notificationController,
        userLogged: _userLogged!,
      );
    } else {
      return Home(onRegister: _openRegisterPage);
    }
  }

  Widget _profile() {
    if (isLogged && _userLogged?.isAdmin == false) {
      return Profile(
        userLogged: _userLogged!,
        userController: userController,
        onLogout: () {
          userController.logout();
          _onUserLogged();
          _onItemTapped(0);
        },
      );
    } else if (isLogged && _userLogged?.isAdmin == true) {
      return Admin(
        adminController: adminController,
        onLogout: () {
          userController.logout();
          _onUserLogged();
          _onItemTapped(0);
        },
        userController: userController,
      );
    } else {
      return Login(
        userController: userController,
        onRegister: _openRegisterPage,
        userLogged: _userLogged,
        onLogin: () {
          _onUserLogged();
          _onItemTapped(1);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedOpacity(
            opacity: _isLoading ? 1.0 : 0.0,
            duration: Duration(milliseconds: 500),
            child: Center(
              child: SpinKitCircle(
                color: Colors.blue.shade900,
                size: 50.0,
              ),
            ),
          ),
          if (!_isLoading)
            AnimatedOpacity(
              opacity: _isLoading ? 0.0 : 1.0,
              duration: Duration(milliseconds: 500),
              child: Stack(
                children: [
                  if (_selectedIndex == 0)
                    _home()
                  else if (_selectedIndex == 1)
                    _profile()
                  else if (_selectedIndex == 2)
                    About()
                  else if (_selectedIndex == 3)
                    Register(
                      userController: userController,
                      onClose: () {
                        _onItemTapped(0);
                      },
                      onSave: (UserLogged userLogged) {
                        setState(() {
                          _userLogged = userLogged;
                        });
                        _onItemTapped(1);
                      },
                    )
                  // Substitua por sua outra página
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Sobre',
          ),
        ],
        currentIndex: _selectedIndex < 3 ? _selectedIndex : 0,
        onTap: (index) {
          if (index < 3) {
            _onItemTapped(index);
          }
        },
      ),
    );
  }
}
