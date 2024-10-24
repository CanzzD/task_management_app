import 'package:get/get.dart';
import 'package:task_management_app/data/hybrid_data_store.dart';
import 'package:task_management_app/models/task.dart';

class TaskController extends GetxController {
  final HybridDataStore dataStore = HybridDataStore();
  var tasks = <Task>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    try {
      // API'den görevleri çek
      await fetchTasksFromApi();
    } catch (e) {
      print("API hatası: $e");
      // İnternet yoksa Hive'dan verileri al
      await fetchTasksFromHive();
    }
  }

  Future<void> fetchTasksFromApi() async {
    // API'den veri almayı burada gerçekleştirin
    List<Task> apiTasks = await dataStore.getAllTasks();

    // API'den alınan görevleri güncelle
    tasks.assignAll(apiTasks);

    // Eğer gerekliyse, API'den alınan görevleri Hive'a kaydetmeyi düşünebilirsiniz
  }

  Future<void> fetchTasksFromHive() async {
    // Hive'dan görevleri al
    List<Task> hiveTasks = await dataStore.getTasksFromHive();

    // Hive'dan alınan görevleri güncelle
    tasks.assignAll(hiveTasks);
  }
}
