# task_management_app

A new Flutter project with Hive and API.

## Uygulama Ekranları 

<div class="row">
<img src="https://github.com/CanzzD/task_management_app/blob/f22903a0c8e06a84cde7cdabc78bb44037031840/home_view.png" height="400"/>
<img src="https://github.com/CanzzD/task_management_app/blob/f2598093ea9f668dfe4443efe6a0b75447aa22d8/new_task.png" height="400"/>
<img src="https://github.com/CanzzD/task_management_app/blob/f2598093ea9f668dfe4443efe6a0b75447aa22d8/update_task.png" height="400"/>

Uygulama, açılış ekranı, yeni görev ekleme ekranı ve görev güncelleme ekranı olmak üzere 3 adet ekrana sahiptir.<br/>
Açılış ekranında sağ altta bulunan buton yeni görev ekleme ekranına geçiş yapar.<br/>
Açılış ekranında sol altta bulunan checkbox ekrandaki görevlerin durumuna göre filtreleme yapar.<br/>

## State Management

Uygulamada state management için hem GetX hem de Stateful Widget(setState()) lar kullanılmıştır.<br/>
GetX kullanımı için bir "task_controller" oluşturulmuştur.<br/>

## API Entegrasyonu

Api entegrasyonu, uygulamada Hive yerel depolama kütüphanesi kullanıldığından hem Hive hem de Api için çalışan hybrid bir kodlama ile yapılmıştır.<br/>
Verilerin json dönüşümleri yapılarak ekranlarda kullanılmıştır.<br/>
"final String apiUrl = 'https://671215e34eca2acdb5f706e5.mockapi.io/api/v1/tasks';"
##GET
final response = await http.get(Uri.parse(apiUrl));<br/>
##GET
final response = await http.post(Uri.parse(apiUrl));<br/>
##GET
final response = await http.put(Uri.parse(apiUrl));<br/>
##GET
final response = await http.delete(Uri.parse(apiUrl));<br/>


