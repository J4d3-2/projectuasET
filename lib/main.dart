import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uas_komiku/screen/comic_list.dart';
import 'package:uas_komiku/screen/login.dart';

String active_user = "";

Future<String> checkUser() async {
  final prefs = await SharedPreferences.getInstance();
  String _user_id = prefs.getString("user_id") ?? '';
  return _user_id;
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  checkUser().then((String result) {
    if (result == '') {
      runApp(const MyLogin());
    } else {
      active_user = result;
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
      },
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  //final List<Widget> _screens = const [Home(), Search(), History()];
  final List<String> _title = ['Home', 'Search', 'History'];

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
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        titleTextStyle: const TextStyle(color: Colors.white),
        title: Text(_title[_currentIndex]),
      ),
      //body: _screens[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
      drawer: myDrawer(),
      persistentFooterButtons: <Widget>[
        ElevatedButton(
          onPressed: () {},
          child: const Icon(Icons.skip_previous),
        ),
        ElevatedButton(
          onPressed: () {},
          child: const Icon(Icons.skip_next),
        ),
      ],
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
          label: "Search",
          icon: Icon(Icons.search),
        ),
        BottomNavigationBarItem(
          label: "History",
          icon: Icon(Icons.history),
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
            accountName: Text(_user_id), // Update here
            accountEmail: Text("$_user_id@gmail.com"),
            currentAccountPicture: const CircleAvatar(
              backgroundImage: NetworkImage("https://i.pravatar.cc/150"),
            ),
          ),
          ListTile(
            title: const Text("Inbox"),
            leading: const Icon(Icons.inbox),
            onTap: () {},
          ),
          ListTile(
            title: const Text("My Basket"),
            leading: const Icon(Icons.shopping_basket),
            onTap: () {
              Navigator.pushNamed(context, "basket");
            },
          ),
          ListTile(
            title: const Text("Comic List"),
            leading: const Icon(Icons.book),
            onTap: () {
              Navigator.pushNamed(context, "ComicList");
            },
          ),
          ListTile(
            title: const Text("Popular Actor"),
            leading: const Icon(Icons.people),
            onTap: () {
              Navigator.pushNamed(context, "popularActor");
            },
          ),
          ListTile(
            title: const Text("Add New Movie"),
            leading: const Icon(Icons.movie_creation_sharp),
            onTap: () {
              Navigator.pushNamed(context, "newpopmovie");
            },
          ),
          ListTile(
            title: const Text("Add Recipe"),
            leading: const Icon(Icons.add),
            onTap: () {
              Navigator.pushNamed(context, "addrecipe");
            },
          ),
          ListTile(
            title: const Text("Quiz"),
            leading: const Icon(Icons.quiz),
            onTap: () {
              Navigator.pushNamed(context, "quiz");
            },
          ),
          ListTile(
            title: const Text("About"),
            leading: const Icon(Icons.help),
            onTap: () {
              Navigator.pushNamed(context, "about");
            },
          ),
          ListTile(
            title: const Text("Animation"),
            leading: const Icon(Icons.animation),
            onTap: () {
              Navigator.pushNamed(context, "animasi");
            },
          ),
          ListTile(
            title: const Text("Student List"),
            leading: const Icon(Icons.people),
            onTap: () {
              Navigator.pushNamed(context, "studentList");
            },
          ),
          ListTile(
            title: const Text("Highscore"),
            leading: const Icon(Icons.score),
            onTap: () {
              Navigator.pushNamed(context, "topUser");
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
