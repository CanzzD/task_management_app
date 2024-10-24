import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:animate_do/animate_do.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:task_management_app/extensions/space_exs.dart';
import 'package:task_management_app/main.dart';
import 'package:task_management_app/models/task.dart';
import 'package:task_management_app/utils/app_colors.dart';
import 'package:task_management_app/utils/app_str.dart';
import 'package:task_management_app/utils/constants.dart';
import 'home/componets/fab.dart';
import 'home/widget/task_widget.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool showIncompleteOnly = false;
  bool hasInternet = false;

  @override
  void initState() {
    super.initState();
    checkInternetConnection(); // İnternet bağlantısını kontrol et
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchTasksFromApi(); // İnternet durumuna göre görevleri çek
    });
  }

  Future<void> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    bool wasOffline = !hasInternet;  // Önceki internet durumu
    setState(() {
      hasInternet = connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi;
    });

    // İnternet bağlantısı yeni geldiyse senkronize et
    if (hasInternet && wasOffline) {
      await syncOfflineTasks();
    }
  }

  Future<void> syncOfflineTasks() async {
    final base = BaseWidget.of(context);
    final hiveBox = base.dataStore.hiveBox;
    // Hive'dan geçici ID ile kaydedilen görevleri bul
    final offlineTasks = hiveBox.values.where((task) => task.id.startsWith('#')).toList();

    for (var task in offlineTasks) {
      try {
        // Görevi API'ye gönder
        final response = await http.post(
          Uri.parse('https://671215e34eca2acdb5f706e5.mockapi.io/api/v1/tasks'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'title': task.title,
            'description': task.description,
            'status': task.status.toString(),
          }),
        );

        if (response.statusCode == 201) {
          // API başarılıysa, API'den dönen ID'yi al
          final jsonResponse = jsonDecode(response.body);
          final apiTaskId = jsonResponse['id'];

          // Geçici ID'li görevi Hive'dan sil ve API'den gelen ID ile tekrar kaydet
          await hiveBox.delete(task.id);  // Geçici ID'li görevi sil
          final updatedTask = Task(
            id: apiTaskId,  // API'den gelen ID'yi kullan
            title: task.title,
            description: task.description,
            status: task.status,
          );
          await hiveBox.put(apiTaskId, updatedTask);  // Gerçek ID ile Hive'a kaydet
          print('Görev senkronize edildi: ${updatedTask.id}');
        }
      } catch (e) {
        print('Görev senkronizasyon hatası: $e');
      }
    }
  }




  Future<void> fetchTasksFromApi() async {
    final base = BaseWidget.of(context);
    final hiveBox = base.dataStore.hiveBox;
    if (hasInternet) {
      try {
        // API'den görevleri çek
        List<Task> apiTasks = await base.dataStore.getAllTasks();

        // Hive'da geçici ID ile eklenmiş görevleri güncelle
        for (var task in apiTasks) {
          if (hiveBox.containsKey(task.id)) {
            // Zaten var olan görevi güncelle
            await hiveBox.put(task.id, task);
          } else {
            // Hive'da olmayan görevleri ekle
            await hiveBox.put(task.id, task);
          }
        }

        setState(() {});  // Görevler geldikten sonra ekranı güncelle
      } catch (e) {
        print("API hatası: $e");
      }
    } else {
      print("İnternet yok");
      setState(() {}); // Ekranı güncelle
    }
  }



  dynamic valueOfIndicator(List<Task> task) {
    if (task.isNotEmpty) {
      return task.length;
    } else {
      return 3;
    }
  }

  int checkDoneTask(List<Task> tasks) {
    int i = 0;
    for (Task doneTask in tasks) {
      if (doneTask.status) {
        i++;
      }
    }
    return i;
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    final base = BaseWidget.of(context);

    return ValueListenableBuilder(
        valueListenable: base.dataStore.listenToTask(),
        builder: (ctx, Box<Task> box, Widget? child) {
          var tasks = box.values.toList();
          tasks = tasks.toSet().toList();
          if (showIncompleteOnly) {
            tasks = tasks.where((task) => !task.status).toList();
          }
          return Scaffold(
              backgroundColor: Colors.white,
              floatingActionButton: const Fab(),
              body: Stack(
                children: [
                  _buildHomeBody(textTheme, base, tasks),
                  _buildCheckbox(),
                ],
              )
          );
        });
  }


  Widget _buildHomeBody(
      TextTheme textTheme, BaseWidget base, List<Task> tasks) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          //App Bar
          Container(
            margin: const EdgeInsets.only(top: 60),
            width: double.infinity,
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    value: checkDoneTask(tasks) / valueOfIndicator(tasks),
                    backgroundColor: Colors.grey,
                    valueColor: AlwaysStoppedAnimation(AppColors.primaryColor),
                  ),
                ),
                25.w,
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStr.mainTitle,
                      style: textTheme.displayLarge,
                    ),
                    Text(
                      "${tasks.length} Görev İçinden ${checkDoneTask(tasks)} Tamamlandı",
                      style: textTheme.titleMedium,
                    )
                  ],
                )
              ],
            ),
          ),

          SizedBox(
            width: double.infinity,
            height: 470,
            child: tasks.isNotEmpty
                ? ListView.builder(
                itemCount: tasks.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  var task = tasks[index];
                  return Dismissible(
                      direction: DismissDirection.horizontal,
                      background: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.delete_outline,
                            color: Colors.grey,
                          ),
                          8.w,
                          const Text(
                            AppStr.deletedTask,
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      onDismissed: (direction) {
                        base.dataStore.deleteTask(id: task.id);
                      },
                      key: Key(task.id),
                      child: TaskWidget(task: tasks[index]));
                })
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// Lottie
                FadeIn(
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: Lottie.asset(
                      lottieURL,
                      animate: tasks.isNotEmpty ? false : true,
                    ),
                  ),
                ),

                /// Bottom Texts
                FadeInUp(
                  from: 30,
                  child: const Text(AppStr.doneAllTask),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox() {
    return Align(
      alignment:  Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 30.0,bottom: 28),
        child: Transform.scale(
          scale: 3.8,
          child:
          Checkbox(
            value: showIncompleteOnly,
            onChanged: (bool? value) {
              setState(() {
                showIncompleteOnly = value ?? false;
              });
            },
          ),
        ),
      ),
    );
  }
}