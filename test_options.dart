import 'dart:convert';
import 'dart:io';

void main() async {
  final request = await HttpClient().openUrl('OPTIONS', Uri.parse('https://api.chefstarz.com/v1/recipes/recipes/'));
  request.headers.add('Accept', 'application/json');
  request.headers.add('Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzc0NTQzMTkyLCJpYXQiOjE3NzE5NTExOTIsImp0aSI6IjRiZmZiNDRlNWViYTRmZjBhNjdlM2NmOWI1NmIxMmU0IiwidXNlcl9pZCI6IjUifQ.L_Rmg09XvIuTIsyzNEijcs9rNsWF6DJGeugdVh9nxek');
  final response = await request.close();
  final responseBody = await response.transform(utf8.decoder).join();
  print(responseBody);
}
