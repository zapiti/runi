import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'core/theme/app_theme.dart';

import 'data/repositories/mock_workout_repository.dart';
import 'data/repositories/workout_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/repositories/mock_user_repository.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/signup_screen.dart';

import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';

import 'features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'features/onboarding/presentation/screens/onboarding_flow.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // For demo purposes, we'll skip actual initialization of external services

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<UserRepository>(
          create: (context) => MockUserRepository(),
        ),
        RepositoryProvider<WorkoutRepository>(
          create: (context) => MockWorkoutRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              userRepository: context.read<UserRepository>(),
            )..add(CheckAuthStatus()),
          ),
          BlocProvider<OnboardingBloc>(
            create: (context) => OnboardingBloc(
              userRepository: context.read<UserRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Runi Fitness',
          theme: ThemeData(
            primaryColor: AppTheme.primaryColor,
            scaffoldBackgroundColor: AppTheme.backgroundColor,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppTheme.primaryColor,
              primary: AppTheme.primaryColor,
              background: AppTheme.backgroundColor,
              surface: AppTheme.surfaceColor,
            ),
            fontFamily: 'Montserrat',
            textTheme: const TextTheme(
              headlineLarge: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
              headlineMedium: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
              titleLarge: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor,
              ),
              titleMedium: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                color: AppTheme.textColor,
              ),
              bodyLarge: TextStyle(
                fontSize: 16.0,
                color: AppTheme.subtitleColor,
              ),
              bodyMedium: TextStyle(
                fontSize: 14.0,
                color: AppTheme.subtitleColor,
              ),
            ),
            useMaterial3: true,
          ),
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthInitial || state is AuthLoading) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (state is Authenticated) {
                if (!state.hasCompletedOnboarding) {
                  return const OnboardingFlow();
                }
                return const DashboardScreen();
              }

              return const LoginScreen();
            },
          ),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignUpScreen(),
            '/dashboard': (context) => const DashboardScreen(),
            '/onboarding': (context) => const OnboardingFlow(),
          },
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
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
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
