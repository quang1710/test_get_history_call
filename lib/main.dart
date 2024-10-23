import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: CallLogScreen(),
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

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CallLogService {
  static const platform = MethodChannel('com.example.test_get_history_call');

  Future<List<dynamic>> getCallLogs() async {
    try {
      final List<dynamic> result = await platform.invokeMethod('getCallLogs');
      print("result: $result");
      return result;
    } on PlatformException catch (e) {
      print("Failed to get call logs: '${e.message}'.");
      return [];
    }
  }
}

class CallLogScreen extends StatefulWidget {
  @override
  _CallLogScreenState createState() => _CallLogScreenState();
}

class _CallLogScreenState extends State<CallLogScreen> {
  List<dynamic> _callLogs = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    fetchCallLogs();
  }

  void fetchCallLogs() async {
    try {
      final logs = await CallLogService().getCallLogs();
      setState(() {
        _callLogs = logs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String formatDate(String timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch Sử Cuộc Gọi'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text('Error: $_error'))
              : ListView.builder(
                  itemCount: _callLogs.length,
                  itemBuilder: (context, index) {
                    final log = _callLogs[index];
                    return ListTile(
                      leading: Icon(
                        log['type'] == 'Cuộc gọi đi'
                            ? Icons.call_made
                            : log['type'] == 'Cuộc gọi đến'
                                ? Icons.call_received
                                : Icons.call_missed,
                        color: log['type'] == 'Cuộc gọi nhỡ' ? Colors.red : Colors.green,
                      ),
                      title: Text(log['number'] ?? 'Không rõ số'),
                      subtitle: Text(
                          'Ngày: ${formatDate(log['date'])} - Thời gian: ${log['duration']} giây'),
                      trailing: Text(log['type']),
                    );
                  },
                ),
    );
  }
}
