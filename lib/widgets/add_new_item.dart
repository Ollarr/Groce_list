import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:grocelist/data/categories.dart';
import 'package:grocelist/models/category.dart';
import 'package:grocelist/models/grocery_item.dart';
import 'package:http/http.dart' as http;

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();

  var isSending = false;

  var enteredName = "";
  var enteredQuantity = 1;
  var selectedCategory = categories[Categories.dairy]!;

  void _reset() {
    _formKey.currentState!.reset();
  }

  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isSending = true;
      });
    }
    _formKey.currentState!.save();
    final url = Uri.https(
        "grocelist-31cb2-default-rtdb.firebaseio.com", "shopping-list.json");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode({
        "name": enteredName,
        "quantity": enteredQuantity,
        "category": selectedCategory.title,
      }),
    );
    final Map<String, dynamic> responseData = json.decode(response.body);

    if (!context.mounted) {
      return;
    }
    // Navigator.of(context).pop();

    Navigator.of(context).pop(GroceryItem(
        id: responseData['name'],
        name: enteredName,
        quantity: enteredQuantity,
        category: selectedCategory));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add new item"),
      ),
      body: Padding(
          padding: const EdgeInsets.all(12),
          child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // an alternative to TextField but with more...
                  TextFormField(
                    maxLength: 50,
                    decoration: const InputDecoration(label: Text("Name")),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length <= 1 ||
                          value.trim().length > 50) {
                        return "Name Must be between 1 and 50";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      enteredName = value!;
                    },
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextFormField(
                            decoration: const InputDecoration(
                              label: Text("Quantity"),
                            ),
                            initialValue: "1",
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  int.tryParse(value) == null ||
                                  int.tryParse(value)! <= 0) {
                                return "Must be a valid positive number.";
                              }
                              return null;
                            },
                            onSaved: (value) =>
                                enteredQuantity = int.parse(value!)),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: DropdownButtonFormField(
                            value: selectedCategory,
                            items: [
                              for (final category in categories.entries)
                                DropdownMenuItem(
                                    value: category.value,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 16,
                                          height: 16,
                                          color: category.value.color,
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Text(category.value.title)
                                      ],
                                    ))
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedCategory = value!;
                              });
                            }),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: isSending ? null : _reset,
                        child: const Text("Reset"),
                      ),
                      ElevatedButton(
                        onPressed: isSending ? null : _saveItem,
                        child: isSending
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(),
                              )
                            : const Text("Add item"),
                      )
                    ],
                  )
                ],
              ))),
    );
  }
}
