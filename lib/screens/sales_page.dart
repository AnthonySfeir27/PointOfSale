import 'dart:io';

import 'package:flutter/material.dart';

class SalesPage extends StatefulWidget {
  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  // Example list of categories. You can replace this with your own list.
  final List<String> _categories = ['All', 'Food', 'Drinks', 'Merchandise'];
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Set the initial value of the dropdown to the first category
    _selectedCategory = _categories.first;
  }

  @override
  Widget build(BuildContext context) {
    // Dummy variables for GridView, replace with your actual implementation
    final SliverGridDelegate gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2);
    final VoidCallback? onPressed = () {};

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes the default back button
        title: Row(
          children: [
            // Menu button on the left
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                // TODO: Implement your menu action here (e.g., open a drawer)
                print("Menu button pressed");
              },
            ),
            // Spacer to push the dropdown to the right
            const SizedBox(width: 16),
            // Dropdown for categories
            DropdownButton<String>(
              value: _selectedCategory,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                  // TODO: Add logic to switch the list used in the GridView
                  print("Selected category: $newValue");
                });
              },
              items: _categories.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      body: Row(
        // Kermel l categories changing we basically just switch the list used in the grid
        children: [
          Expanded(
            flex: 2, // Give more space to the grid
            child: GridView(gridDelegate: gridDelegate), // This is where the items are displayed in a grid
          ),
          Expanded(
            flex: 1, // Give less space to the ticket
            child: Column( // This is where the ticket info is shown
              children: [
                Text(
                  "Ticket",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Column( // This is where the items in the ticket are displayed
                    children: [],
                  ),
                ),
                TextButton(onPressed: onPressed, child: Text("Charge")), // This is the button to charge the ticket
              ],
            ),
          ),
        ],
      ),
    );
  }
}
