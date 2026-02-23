import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:campus_notes/screens/splash_screen.dart';
import 'package:campus_notes/theme/app_theme.dart';
import 'package:campus_notes/blocs/auth_bloc.dart';
import 'package:campus_notes/blocs/notes_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
        BlocProvider<NotesBloc>(create: (context) => NotesBloc()),
      ],
      child: MaterialApp(
        title: 'Campus Notes',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
