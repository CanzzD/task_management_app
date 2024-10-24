import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:task_management_app/data/hybrid_data_store.dart';
import 'package:task_management_app/models/task.dart';
import 'package:task_management_app/views/home_view.dart';


Future<void> main() async {

  await Hive.initFlutter();
  Hive.registerAdapter<Task>(TaskAdapter());


  Box box = await Hive.openBox<Task>(HybridDataStore.boxName);

  runApp(BaseWidget(child: const MyApp()));
}

class BaseWidget extends InheritedWidget{
  BaseWidget({Key? key, required this.child}) : super(key: key, child: child);

  final HybridDataStore dataStore = HybridDataStore();
  final Widget child;

  static BaseWidget of(BuildContext context){
    final base = context.dependOnInheritedWidgetOfExactType<BaseWidget>();
    if (base != null){
      return base;
    }else{
      throw StateError('Could not find ancestor widget of type BaseWidget');
    }
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Task Management App With Hive',
      theme: ThemeData(
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
          titleMedium: TextStyle(
            color: Colors.grey,
            fontSize: 13,
            fontWeight: FontWeight.w300,
          ),
          displayMedium: TextStyle(
            color: Colors.white,
            fontSize: 21,
          ),
          displaySmall: TextStyle(
            color: Colors.amberAccent,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          headlineMedium: TextStyle(
            color: Colors.grey,
            fontSize: 17,
          ),
          headlineSmall: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
          titleSmall: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500
          ),
          titleLarge: TextStyle(
              color: Colors.black,
              fontSize: 40,
              fontWeight: FontWeight.w300
          ),
        ),
      ),
      home: HomeView()
    );
  }
}