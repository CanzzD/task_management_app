import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_management_app/main.dart';
import 'package:task_management_app/models/task.dart';
import '../../../utils/app_colors.dart';
import 'package:http/http.dart' as http;

import '../../tasks/task_view.dart';

class TaskWidget extends StatefulWidget {
  const TaskWidget({Key? key, required this.task}) : super(key: key);
  final Task task;

  @override
  _TaskWidgetState createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  TextEditingController textEditingControllerForTitle = TextEditingController();
  TextEditingController textEditingControllerForSubTitle = TextEditingController();

  @override
  void initState() {
    super.initState();
    textEditingControllerForTitle.text = widget.task.title;
    textEditingControllerForSubTitle.text = widget.task.description;
  }

  @override
  void dispose() {
    textEditingControllerForTitle.dispose();
    textEditingControllerForSubTitle.dispose();
    super.dispose();
  }

  Future<void> updateTaskStatus(Task task) async {
    try {
      final response = await http.put(
        Uri.parse('https://671215e34eca2acdb5f706e5.mockapi.io/api/v1/tasks/${task.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': task.title,
          'description': task.description,
          'status': task.status,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("API'de statü güncellenemedi.");
      }
    } catch (e) {
      throw Exception("Statü güncellenirken hata oluştu: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => TaskView(
          taskControllerForTitle: textEditingControllerForTitle,
          taskControllerForSubtitle: textEditingControllerForSubTitle,
          task: widget.task,
        ));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: widget.task.status ? const Color.fromARGB(154, 119, 144, 229) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(.2), offset: const Offset(0, 4), blurRadius: 10),
          ],
        ),
        child: ListTile(
          leading: GestureDetector(
            onTap: () async {
              setState(() {
                widget.task.status = !widget.task.status; // Statüyü değiştir
              });

              // API'ye güncelleme isteği gönder
              try {
                await updateTaskStatus(widget.task);
              } catch (e) {
                print("Statü güncellenirken hata oluştu: $e");
              }
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 600),
              decoration: BoxDecoration(
                color: widget.task.status ? AppColors.primaryColor : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey, width: .8),
              ),
              child: Icon(
                widget.task.status ? Icons.check : null,
                color: Colors.white,
              ),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(bottom: 5, top: 3),
            child: Text(
              textEditingControllerForTitle.text,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                decoration: widget.task.status ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                textEditingControllerForSubTitle.text,
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                  decoration: widget.task.status ? TextDecoration.lineThrough : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
