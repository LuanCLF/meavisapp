import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;
import 'package:meavisapp/controller/controller.dart';
import 'package:meavisapp/pages/about.dart';
import 'package:meavisapp/pages/home.dart';
import 'package:meavisapp/pages/profile.dart';
import 'package:meavisapp/pages/register.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  await dotenv.dotenv.load(fileName: '.env');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Registercontroller()),
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
  int _selectedIndex = 0;
  bool _isRegisterPageVisible = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _isRegisterPageVisible = false;
    });
  }

  void _openRegisterPage() {
    setState(() {
      _isRegisterPageVisible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_selectedIndex == 0)
            Home(
              onRegister: _openRegisterPage,
            )
          else if (_selectedIndex == 1)
            Profile()
          else if (_selectedIndex == 2)
            About(),
          if (_isRegisterPageVisible)
            Register(
              onClose: () {
                setState(() {
                  _isRegisterPageVisible = false;
                });
              },
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
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
