import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class WebsocketClient {
  Stream<int> getCounterStream([int start]);
}

class FakeWebsocketClient implements WebsocketClient {
  @override
  Stream<int> getCounterStream([int start = 0]) async* {
    int i = start;
    while (true) {
      await Future.delayed(const Duration(milliseconds: 500));
      yield i++;
    }
  }
}

/*abstract class WebsocketClient {
  Stream<int> getCounterStream();
}

class FakeWebsocketClient implements WebsocketClient {
  @override
  Stream<int> getCounterStream() async* {
    int i = 0;
    while (true) {
      await Future.delayed(const Duration(milliseconds: 500));
      yield i++;
    }
  }
}*/

final websocketClientProvider = Provider<WebsocketClient>(
  (ref) {
    return FakeWebsocketClient();
  },
);
final counterProvider = StreamProvider.family<int, int>(
  (ref, start) {
    final wsClient = ref.watch(websocketClientProvider);
    return wsClient.getCounterStream(start);
  },
);
//final counterProvider = StateProvider((ref) => 0);
void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter App',
      home: HomePage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
          surface: const Color(0xff003909),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Go to Counter Page'),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: ((context) => const CounterPage()),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CounterPage extends ConsumerWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<int> counter = ref.watch(counterProvider(5));
    /*ref.listen<int>(
      counterProvider,
      (previous, next) {
        if (next >= 5) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Warning'),
                content:
                    Text('Counter dangerously high. Consider resetting it.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  )
                ],
              );
            },
          );
        }
      },
    );*/
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Counter",
        ),
        /*actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(counterProvider);
            },
            icon: Icon(
              Icons.refresh,
            ),
          ),
        ],*/
      ),
      body: Center(
        child: Text(
          counter
              .when(
                data: (int value) => value,
                error: (Object e, _) => e,
                loading: () => 5,
              )
              .toString(),
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
      /* floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.add,
        ),
        onPressed: () {
          final x = ref.read(counterProvider.notifier).state++;
        },
      ),*/
    );
  }
}
