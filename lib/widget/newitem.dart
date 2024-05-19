import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_app/data/categories.dart';
import 'package:shopping_app/models/category.dart';
//import 'package:shopping_app/models/grocery_item.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_app/models/grocery_item.dart';
//import 'package:shopping_app/models/grocery_item.dart';

class Newitem extends StatefulWidget {
  const Newitem({super.key});
  @override
  State<Newitem> createState() {
    return _Newitem();
  }
}

class _Newitem extends State<Newitem> {
  final _formkey = GlobalKey<FormState>();
  var _enteredname = '';
  var _quantity = 1;
  var _selectedcategory = categories[Categories.vegetables]!;
  var _isending= false;

  void _saveitem() async {
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();
    setState(() {
      _isending= true;
    });
      final url = Uri.https('shoppingapp-6c618-default-rtdb.firebaseio.com',
          'shopping-list.json');
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'name': _enteredname,
            'quantity': _quantity,
            'category': _selectedcategory.title
          }));

      final Map<String, dynamic> res= json.decode(response.body);


      if (!context.mounted) {
        // If the data is not present on the screen
        return;
      }
      Navigator.of(context).pop(GroceryItem(id: res['name'], name: _enteredname, quantity: _quantity, category: _selectedcategory));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new item'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formkey,
            child: Column(
              children: [
                TextFormField(
                  maxLength: 50,
                  decoration: const InputDecoration(label: Text('Name')),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length <= 1 ||
                        value.trim().length > 50) {
                      return 'Characters must be between 1 and 50';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _enteredname = value!;
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          label: Text('Quantity'),
                        ),
                        keyboardType: TextInputType.number,
                        initialValue: _quantity.toString(),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null ||
                              int.tryParse(value)! <= 0) {
                            return 'Invalid number';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _quantity = int.parse(value!);
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: DropdownButtonFormField(
                        items: [
                          for (final category in categories.entries)
                            DropdownMenuItem(
                                value: category.value,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      color: category.value.color,
                                    ),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    Text(category.value.title),
                                  ],
                                ))
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedcategory = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: _isending? null : () {
                          _formkey.currentState!.reset();
                        },
                        child: const Text('Reset')),
                    ElevatedButton(
                      onPressed: _isending ?null:
                       _saveitem,
                      child: _isending? const Text('Saving...'):
                      const Text('Add Item'),
                    )
                  ],
                )
              ],
            ),
          )),
    );
  }
}
