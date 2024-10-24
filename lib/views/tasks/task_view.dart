import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_management_app/extensions/space_exs.dart';
import 'package:task_management_app/main.dart';
import 'package:task_management_app/models/task.dart';
import 'package:task_management_app/utils/app_colors.dart';
import 'package:task_management_app/utils/app_str.dart';
import 'package:task_management_app/utils/constants.dart';
import 'package:task_management_app/views/tasks/widget/task_view_app_bar.dart';


class TaskView extends StatefulWidget {
  const TaskView({
    super.key,
    required this.taskControllerForTitle,
    required this.taskControllerForSubtitle,
    required this.task,
  });

  final TextEditingController? taskControllerForTitle;
  final TextEditingController? taskControllerForSubtitle;
  final Task? task;
  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  var title;
  var description;

  dynamic isTaskAlreadyExist(){
    if (widget.taskControllerForTitle?.text == null && widget.taskControllerForSubtitle?.text == null){
      return true;
    }else{
      return false;
    }
  }

  dynamic isTaskAlreadyExistUpdateOtherWiseCreate() {
    if (widget.taskControllerForTitle?.text.isNotEmpty == true &&
        widget.taskControllerForSubtitle?.text.isNotEmpty == true) {
      try {
        // Güncelleme yap
        String title = widget.taskControllerForTitle?.text ?? '';
        String description = widget.taskControllerForSubtitle?.text ?? '';
        widget.task!.title = title; // Güncellenen title
        widget.task!.description = description; // Güncellenen description

        // API'de güncelle
        BaseWidget.of(context).dataStore.updateTask(task: widget.task!);
        Get.back(result: true);
      } catch (e) {
        updateTaskWarning(context);
      }
    } else {
      // Eğer title veya subtitle yoksa yeni task oluşturma
      if (title.isNotEmpty && description.isNotEmpty) {
        var task = Task.create(title: title, description: description);
        BaseWidget.of(context).dataStore.addTask(task: task);
        Get.back();
      } else {
        emptyWarning(context);
      }
    }
  }


  dynamic deleteTask() {
    // API'den görevi sil
    BaseWidget.of(context).dataStore.deleteTask( id: widget.task!.id);
    // Görev silindikten sonra geri dön
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus!.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const TaskViewAppBar(),
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              children: [

                _buildTopSideTexts(textTheme),
                SizedBox(
                  width: double.infinity,
                  height: 500,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: Text(
                          AppStr.titleOfTitleTextField,
                          style: textTheme.headlineMedium,
                        ),
                      ),

                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: ListTile(
                          title: TextFormField(
                            controller: widget.taskControllerForTitle,
                            maxLines: 6,
                            cursorHeight: 60,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            onFieldSubmitted: (value) {
                              title = value;
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            onChanged: (value) {
                              title = value;
                            },
                          ),
                        ),
                      ),

                      10.h,

                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: ListTile(
                          title: TextFormField(
                            controller: widget.taskControllerForSubtitle,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.bookmark_border, color: Colors.grey),
                              border: InputBorder.none,
                              counter: Container(),
                              hintText: AppStr.addNote,
                            ),
                            onFieldSubmitted: (value) {
                              description = value;
                            },
                            onChanged: (value) {
                              description = value;
                            },
                          ),
                        ),
                      ),

                      35.h,

                      _buildBottomSideButtons()
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSideButtons() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: isTaskAlreadyExist()
        ? MainAxisAlignment.center
        : MainAxisAlignment.spaceEvenly,
        children: [
          isTaskAlreadyExist()
          ?Container()
          :

          MaterialButton(
            onPressed: (){
              deleteTask();
              Get.back();
            },
            minWidth: 150,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            height: 55,
            child: Row(
              children: [
                const Icon(Icons.close, color: AppColors.primaryColor,),
                5.w,
                const Text(AppStr.deleteTask,style: TextStyle(color: AppColors.primaryColor),),
              ],
            ),
          ),

          MaterialButton(
            onPressed: (){
              isTaskAlreadyExistUpdateOtherWiseCreate();
            },
            minWidth: 150,
            color: AppColors.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            height: 55,
            child: Text(
              isTaskAlreadyExist()
              ? AppStr.addNewTask
              : AppStr.updateTaskString,
              style: const TextStyle(
                color: Colors.white,
              ),),
          )
        ],
      ),
    );
  }

  SizedBox _buildTopSideTexts(TextTheme textTheme) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 50,
            child: Divider(
              thickness: 2,
            ),
          ),
          RichText(
            text: TextSpan(
              text: isTaskAlreadyExist()
                  ? AppStr.addNewTask
                  : AppStr.updateCurrentTask,
              style: textTheme.titleLarge,
              children: const [
                TextSpan(
                    text: AppStr.taskString,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ))
              ],
            ),
          ),
        ],
      ),
    );
  }

}






