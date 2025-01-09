import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uas_komiku/screen/category_screen.dart';
import 'package:uas_komiku/screen/comic_add.dart';
import 'package:uas_komiku/screen/comic_list.dart';
import 'package:uas_komiku/screen/login.dart';

String active_user = "";

Future<String> checkUser() async {
  final prefs = await SharedPreferences.getInstance();
  String _user_id = prefs.getString("user_id") ?? '';
  return _user_id;
}

Future<String> userName() async {
  final prefs = await SharedPreferences.getInstance();
  String user_name = prefs.getString("user_name") ?? '';
  return user_name;
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  checkUser().then((String result) {
    if (result == '') {
      runApp(const MyLogin());
    } else {
      //active_user = result;
      runApp(const MyApp());
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        'ComicList': (context) => const ComicList(),
        'NewComic': (context) => const NewComic(),
      },
      title: 'Komiku - Baca Komik',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Komiku - Baca Komik'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int _currentIndex = 0;
  String _user_id = ""; // Add this line to declare _user_id
  String _user_name = "";
  final List<Widget> _screens = const [ComicList(), CategoryList()];

  void doLogout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("user_id");
    main();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();
    checkUser().then((value) {
      setState(() {
        _user_id = value; // Use the defined _user_id variable
        active_user = _user_id;
      });
    });
    userName().then((value) => setState(
          () {
            _user_name = value;
            //active_user = _user_name;
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        titleTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),
        title: Text('KOMIKU'),
      ),
      body: _screens[_currentIndex],
      drawer: myDrawer(),
      bottomNavigationBar: myBottomNav(),
    );
  }

  BottomNavigationBar myBottomNav() {
    return BottomNavigationBar(
      fixedColor: Colors.teal,
      items: const [
        BottomNavigationBarItem(
          label: "Home",
          icon: Icon(Icons.home),
        ),
        BottomNavigationBarItem(
          label: "Cattegory",
          icon: Icon(Icons.search),
        ),
      ],
      currentIndex: _currentIndex,
      onTap: (int index) {
        setState(() {
          _currentIndex = index;
        });
      },
    );
  }

  Drawer myDrawer() {
    return Drawer(
      elevation: 16.0,
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(_user_name), // Update here
            accountEmail: Text("$_user_id@gmail.com"),
            currentAccountPicture: const CircleAvatar(
              backgroundImage: NetworkImage("https://i.pravatar.cc/150"),
            ),
          ),
          ListTile(
            title: const Text("Tambah Komik Baru"),
            leading: const Icon(Icons.library_add),
            onTap: () {
              Navigator.pushNamed(context, "NewComic");
            },
          ),
          ListTile(
            title: const Text("Logout"),
            leading: const Icon(Icons.logout),
            onTap: () {
              doLogout();
            },
          ),
        ],
      ),
    );
  }
}
