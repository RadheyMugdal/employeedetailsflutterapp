import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Employee {
  final String name;
  final DateTime hireDate;
  final bool isActive;

  Employee({required this.name, required this.hireDate, required this.isActive});
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Employee List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EmployeeListScreen(),
    );
  }
}

class EmployeeListScreen extends StatefulWidget {
  @override
  _EmployeeListScreenState createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  late List<Employee> employees;

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    final response = await http.get(Uri.parse('https://task-sand-rho.vercel.app/'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        employees = data.map((item) {
          final hireDate = DateTime.parse(item['hireDate']);
          final isActive = item['isActive'];
          return Employee(
            name: item['name'],
            hireDate: hireDate,
            isActive: isActive,
          );
        }).toList();
      });
    } else {
      throw Exception('Failed to load employees');
    }
  }

  bool isMoreThanFiveYears(DateTime hireDate) {
    final difference = DateTime.now().difference(hireDate).inDays;
    return difference >= 1825; // 5 years = 1825 days
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee List'),
      ),
      body: ListView.builder(
        itemCount: employees.length,
        itemBuilder: (context, index) {
          final employee = employees[index];
          final bool moreThanFiveYears = isMoreThanFiveYears(employee.hireDate);
          return ListTile(
            title: Text(employee.name),
            subtitle: Text(employee.hireDate.toString()),
            tileColor: moreThanFiveYears && employee.isActive ? Colors.green : null,
          );
        },
      ),
    );
  }
}
