import 'package:flutter/cupertino.dart';
import 'package:ftoast/ftoast.dart';
import 'package:task_management_app/utils/app_str.dart';

String lottieURL = 'assets/lottie/1.json';

dynamic updateTaskWarning(BuildContext context){
  return FToast.toast(
    context,
    msg: AppStr.oppsMsg,
    subMsg: "Taskı update etmeden önce editlemeniz gerekmektedir",
    corner: 20.0,
    duration: 2000,
    padding: const EdgeInsets.all(20),
  );
}

dynamic emptyWarning(BuildContext context){
  return FToast.toast(
    context,
    msg: AppStr.oppsMsg,
    subMsg: "Görev Başlığı ve Açıklama Alanları Doldurulmalıdır",
    corner: 20.0,
    duration: 2000,
    padding: const EdgeInsets.all(20),
  );
}
