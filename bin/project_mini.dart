// for http connection
import 'package:http/http.dart' as http;
// for stdin
import 'dart:io';

import 'dart:convert';

void main() async {
  await login();
  print('---bye---');
}

Future<void> login() async {
  print("===== Login =====");
  // Get username and password
  stdout.write("Username: ");
  String? username = stdin.readLineSync()?.trim();
  stdout.write("Password: ");
  String? password = stdin.readLineSync()?.trim();
  if (username == null || password == null) {
    print("Incomplete input");
    return;
  }

  final body = {"username": username, "password": password};
  final url = Uri.parse('http://localhost:3000/login');
  final response = await http.post(url, body: body);
  // note: if body is Map, it is encoded by "application/x-www-form-urlencoded" not JSON
  if (response.statusCode == 200) {
    // the response.body is String
    final data = jsonDecode(response.body);
    final userId = data['userId']; // <--- comes from backend
    print("Login OK!");
    await showmenu(userId);
  } else if (response.statusCode == 401 || response.statusCode == 500) {
    final result = response.body;
    print(result);
  } else {
    print("Unknown error");
  }
}

Future<void> showmenu(int userId) async {
  String? choice;
  do {
    print("======= Expense tracking app =======");
    print("1. All expense");
    print("2. Today's expense");
    print("3. Search expense");
    print("4. Add new expense");
    print("5. Delete an expense");
    print("6. Exit");
    stdout.write("Choose: ");
    choice = stdin.readLineSync();

    if (choice == "1") {
      await showAllExpenses(userId);
    } else if (choice == "2") {
      await showTodayExpenses(userId);
    } else if (choice == "3") {
      //function Search expense
      //
      //
    } else if (choice == "4") {
      //Add a new expense
      print("===== Add new item =====");
      stdout.write("Item: ");
      String? items = stdin.readLineSync()?.trim();
      stdout.write("Paid: ");
      String? paid = stdin.readLineSync()?.trim();
      //
      //function Add new expense
    } else if (choice == "5") {
      //
      //
      //function Delete an expense
    }
  } while (choice != "6");
}

Future<void> showAllExpenses(int userId) async {
  final url = Uri.parse('http://localhost:3000/expenses/$userId');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List expenses = jsonDecode(response.body);
    if (expenses.isEmpty) {
      print("No expenses found.");
    } else {
      int total = 0;
      print("=== All Expenses ===");
      for (var exp in expenses) {
        print(
          " ${exp['id']}., ${exp['items']},  ${exp['paid']}, ${exp['date']}",
        );
        total += (exp['paid'] as num).toInt();
      }
      print("Total expense: ${total}฿ ");
    }
  } else {
    print("Error fetching expenses: ${response.body}");
  }
}

Future<void> showTodayExpenses(int userId) async {
  final url = Uri.parse('http://localhost:3000/expenses/today/$userId');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List expenses = jsonDecode(response.body);
    if (expenses.isEmpty) {
      print("No expenses today.");
    } else {
      print("=== Today's Expenses ===");
      int total = 0;
      for (var exp in expenses) {
        print(" ${exp['id']}, ${exp['items']}, ${exp['paid']}, ${exp['date']}");
        total += (exp['paid'] as num).toInt();
      }
      print("Total expense: ${total}฿ ");
    }
  } else {
    print("Error fetching today's expenses: ${response.body}");
  }
}
