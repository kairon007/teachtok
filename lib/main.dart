import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:teachtok/widgets/numberediconbutton.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MCQ Feed App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, dynamic>? jsonData;
  List<Map<String, dynamic>>? options;
  String selectedAnswer = ''; // Initialize to a default value
  String correctAnswer = ''; // To store the correct answer
  bool isAnswerSelected = false;
  int _currentIndex = 0;
  bool showAnimation = false;

  @override
  void initState() {
    super.initState();
    // Fetch JSON data from the server
    fetchJsonData();
  }
  Future<void> onRefresh() async {
    // Simulate a refresh operation
    await fetchJsonData();

    setState(() {
      // Reset the state for a new question or update the data accordingly
      jsonData = {
        "type": "mcq",
        "id": 8282,
        // ... (other data)
      };
      selectedAnswer = '';
      correctAnswer = '';
      showAnimation = false;
    });
  }


  Future<void> fetchJsonData() async {
    final response = await http
        .get(Uri.parse('https://cross-platform.rp.devfactory.com/for_you'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        jsonData = data;
        options = List<Map<String, dynamic>>.from(data['options']);
      });

      // Fetch correct answer from the server
      fetchCorrectAnswer();
    } else {
      // Handle error
      print('Failed to fetch JSON data. Status code: ${response.statusCode}');
    }
  }

  Future<void> fetchCorrectAnswer() async {
    if (jsonData == null) {
      return;
    }

    final response = await http.get(Uri.parse(
        'https://cross-platform.rp.devfactory.com/reveal?id=${jsonData!['id']}'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        correctAnswer = data['correct_options'][0]['id'];
        // correctAnswer = List<String>.from(data['correct_options'].map((option) => option['id'])).first;
      });
    } else {
      // Handle error
      print(
          'Failed to fetch correct answer. Status code: ${response.statusCode}');
    }
  }

  void checkAnswer(String answer) {
    if (!showAnimation) {
      setState(() {
        selectedAnswer = answer;
        // isAnswerSelected = true;
        showAnimation = true;
      });
    }
  }

  Widget buildOptions() {
    return SizedBox(
      width: 300.0,
      child: Column(
        children: options!
            .map(
              (option) => GestureDetector(
                onTap: () => checkAnswer(option['id']),
                child: AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(10.0),
                    color: showAnimation
                        ? (option['id'] == correctAnswer &&
                                selectedAnswer.isNotEmpty)
                            ? Colors.green
                            : option['id'] == selectedAnswer
                                ? Colors.red
                                : Colors.white
                        : Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(
                        option['answer'],
                        style: TextStyle(
                          fontSize: 18.0,
                          color: showAnimation
                              ? option['id'] == selectedAnswer
                                  ? option['id'] == correctAnswer
                                      ? Colors.white
                                      : Colors.black
                                  : Colors.black
                              : Colors.black,
                        ),
                      )),
                      if (showAnimation && option['id'] == selectedAnswer)
                        Icon(
                          option['id'] == correctAnswer
                              ? Icons.thumb_up
                              : Icons.thumb_down,
                          color: Colors.white,
                        ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0), // Set the preferred height
          child: SafeArea(
            child: AppBar(
              backgroundColor: Colors.transparent,
              title: Row(
                children: [
                  Spacer(),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20.0),
                      // Adjust the radius as needed
                      onTap: () {
                        // Handle tab tap
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          'For You',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // Set your desired text color
                          ),
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                ],
              ),
              actions: [
                IconButton(
                  color: Colors.white,
                  icon: Icon(Icons.search),
                  onPressed: () {
                    // Handle search action
                  },
                ),
              ],
              leading: const Row(
                children: [
                  Icon(
                    Icons.timer,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 4.0),
                  Text(
                    '12', // Replace with your timer logic

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: RefreshIndicator(onRefresh: onRefresh, child: Stack(
          children: [
            if (jsonData != null)
              Positioned.fill(
                child: Image.network(
                  jsonData!['image'],
                  fit: BoxFit.cover,
                ),
              ),
            Container(
              color: Colors.black.withOpacity(0.5),
              // Adjust the opacity as needed
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (jsonData != null)
                      Text(
                        jsonData!['question'],
                        style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    const SizedBox(height: 16.0),
                    if (options != null) buildOptions(),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  NumberedIconButton(icon: Icons.favorite, number: '87'),
                  NumberedIconButton(icon: Icons.message, number: '2'),
                  NumberedIconButton(icon: Icons.save, number: '203'),
                  NumberedIconButton(icon: Icons.share, number: '17'),
                ],
              ),
            ),
          ],
        )),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              color: Colors.black,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Playlist',
                      style: TextStyle(color: Colors.white, fontSize: 18.0),
                    ),
                  ),
                  Icon(
                    Icons.navigate_next,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            BottomNavigationBar(
              backgroundColor: Colors.white,
              currentIndex: _currentIndex,
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.grey,
              // Change this color as needed
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.explore),
                  label: 'Discover',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.notifications),
                  label: 'Activity',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bookmark),
                  label: 'Bookmarks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ],
        ));
  }
}
