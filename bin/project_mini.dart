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
      await SearchExpenses();
      //
      //
    } else if (choice == "4") {
      await add(userId);
    } 
    else if (choice == "5") {
      //
      //
      //function Delete an expense
      await delete();
    }
  } while (choice != "6");
}

Future<void> add(int userId) async{
  //function Add new expense
      print("===== Add new item =====");
      stdout.write("Item: ");
      String? items = stdin.readLineSync()?.trim();
      stdout.write("Paid: ");
      String? paid = stdin.readLineSync()?.trim();

      // --- Input Validation ---
      if (items == null || items.isEmpty || paid == null || paid.isEmpty) {
        print("Item and Paid amount cannot be empty. Please try again.");
        return;
      }

      // Optional: Check if 'paid' is a valid number
      if (double.tryParse(paid) == null) {
        print("Invalid amount. Please enter a valid number for Paid.");
        return;
      }

      try {
        // --- Prepare and Send HTTP Request ---
        final url = Uri.parse(
          'http://localhost:3000/expenses/add',
        ); // Standard REST API endpoint for creating a resource
        final body = {
          'items': items,
          'paid': paid,
          'userId': userId.toString(), // Pass the logged-in user's ID
        };

        final response = await http.post(url, body: body);
        // --- Handle Response ---
        if (response.statusCode == 201 || response.statusCode == 200) {
          // 201 Created is the most appropriate success code
          print("Inserted!");
        } else {
          print("Failed to add expense. Error: ${response.body}");
        }
      } catch (e) {
        print("An error occurred while connecting to the server: $e");
      }
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
          " ${exp['id']}. ${exp['items']}:  ${exp['paid' ]}฿ : ${exp['date']}");
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
        print(" ${exp['id']}. ${exp['items']}:  ${exp['paid' ]}฿ : ${exp['date']}");
        total += (exp['paid'] as num).toInt();
      }
      print("Total expense: ${total}฿ ");
    }
  } else {
    print("Error fetching today's expenses: ${response.body}");
  }
}


Future<void> delete() async{
  print("===== Delete an item =====");
  stdout.write("Item id: ");
  String? itemid = stdin.readLineSync()?.trim();
  if(itemid == null || itemid.isEmpty){print("This item doesn't exist"); return;}
  final body = {
    "expenseId": itemid
    
  };
  final url = Uri.parse('http://localhost:3000/expense/delete');
  final response = await http.delete(url, body: body);
  final result = response.body;
  if(response.statusCode == 200){
    print(result);
    return;
  }else{
    print("Expense not found");
  }
}

Future<void> SearchExpenses() async {
  stdout.write("item to seach: ");
  String? keyword = stdin.readLineSync()?.trim();
  if (keyword == null || keyword.isEmpty) {
    print('input keyword no success');
    return;
  }

  final body = {"search": keyword};
  final url = Uri.parse('http://localhost:3000/expenses/search');
  final response = await http.post(url, body: body);
  if (response.statusCode != 200) {
    print('Failed to search');
    return;
  }
  final jsonResult = json.decode(response.body) as List; //***** use json.decode when the response is a JSON array*****
  if (jsonResult.isEmpty) {
    print('No item: ${keyword}');
  } else {
    print('Search result:');
    for (var item in jsonResult) {
      final dt = DateTime.parse(item['date']);
      final dtLocal = dt.toLocal();
      print('${item['id']}. ${item['items' ]} : ${item['paid' ]}฿ : ${dtLocal.toString()}');
    }
  }

}

