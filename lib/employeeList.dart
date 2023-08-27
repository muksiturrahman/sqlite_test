import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'EmployeeDataModel.dart';

class EmployeeList extends StatefulWidget {
  const EmployeeList({super.key});

  @override
  State<EmployeeList> createState() => _EmployeeListState();
}

class _EmployeeListState extends State<EmployeeList> {
  List<dynamic> dataList = [];
  late Database _database;
  bool isDataInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeDatabase().then((_){
      postData();
      fetchData();
    });
  }

  Future<void> fetchData() async {
    try {
      if (!isDataInitialized) {
        dataList.clear();
        final databaseData = await _fetchDataFromDatabase();
        await initializeData();
        setState(() {
          dataList = List.from(databaseData);
          isDataInitialized = true;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }


  Future<void> postData() async {
    const url = '';
    Map<String, dynamic> data = {};

    try {
      final response = await http.post(
        Uri.parse(url),
        body: data,
      );

      if (response.statusCode == 200) {
        final employeeList = (jsonDecode(response.body) as List)
            .map((item) => EmployeeData.fromJson(item))
            .toList();
        await _clearOldData();
        await _storeDataInDatabase(employeeList);
        setState(() {
          dataList = employeeList;
        });
      } else {
        if (kDebugMode) {
          print('POST request failed with status: ${response.statusCode}');
        }
        if (kDebugMode) {
          print('Error message: ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      await initializeData();
    }
  }

  Future<void> _clearOldData() async {
    final db = _database;
    await db.delete('employees');
  }


  Future<void> _initializeDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'employee_database.db');

    _database = await openDatabase(path, version: 3,
        onCreate: (Database db, int version) async {
          await db.execute('''
        CREATE TABLE employees (
          name TEXT,
          designation TEXT,
          photo TEXT,
          email TEXT,
          mobile TEXT,
          department TEXT,
          skype TEXT,
          division TEXT 
        )
      ''');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if( oldVersion < 3){
            await db.execute('ALTER TABLE employees ADD COLUMN Division TEXT');
          }
        });
  }

  Future<void> _storeDataInDatabase(List<EmployeeData> employeeList) async {
    final db = _database;
    for (final employee in employeeList) {
      await db.insert('employees', employee.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<List<EmployeeData>> _fetchDataFromDatabase() async {
    final db = _database;
    final List<Map<String, dynamic>> maps = await db.query('employees');
    return List.generate(maps.length, (i) {
      return EmployeeData(name: maps[i]['name'],designation: maps[i]['designation']);
    });
  }


  Future<void> initializeData() async {
    await _initializeDatabase();

    final databaseData = await _fetchDataFromDatabase();
    setState(() {
      dataList = List.from(databaseData);
    });
  }

  Future<void> refreshData() async {
    await postData();
    initializeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView.builder(
            itemCount: dataList.length,
            itemBuilder: (context, index) {
              final EmployeeData employee = dataList[index];
              if (kDebugMode) {
                print('${dataList.length}');
              }
              return Column(
                children: [
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 5,
                                      color: Colors
                                          .white),
                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                      50),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors
                                          .grey
                                          .shade300,
                                      spreadRadius:
                                      0.0,
                                      blurRadius: 0,
                                      offset:
                                      const Offset(
                                        0,
                                        2,
                                      ),
                                    ),
                                  ]),
                              child: const CircleAvatar(
                                radius: 30,
                                child: Icon(Icons.person,size: 40,),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(
                                      context)
                                      .size
                                      .width /
                                      1.8,
                                  child: Text( employee.name ?? '',
                                    style: TextStyle(
                                        color: Colors
                                            .grey
                                            .shade600),
                                  ),
                                ),
                                Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                    children: [
                                      const Icon(
                                        Icons
                                            .description,
                                        color: Colors
                                            .grey,
                                        size: 18,
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      SizedBox(
                                        width: MediaQuery.of(
                                            context)
                                            .size
                                            .width /
                                            1.9,
                                        child: Text(employee.designation ?? '',style: TextStyle(
                                              color: Colors
                                                  .grey
                                                  .shade400,
                                              fontSize:
                                              12),
                                        ),
                                      ),
                                    ]),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                ],
              );
            }),
      ),
    );
  }
}
