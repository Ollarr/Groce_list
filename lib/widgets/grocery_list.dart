// // ignore_for_file: unused_element

// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:grocelist/data/categories.dart';
// // import 'package:grocelist/data/dummy_items.dart';
// import 'package:grocelist/models/grocery_item.dart';
// import 'package:grocelist/widgets/add_new_item.dart';

// import 'package:http/http.dart' as http;

// class GroceryList extends StatefulWidget {
//   const GroceryList({
//     super.key,
//   });

//   @override
//   State<GroceryList> createState() => _GroceryListState();
// }

// class _GroceryListState extends State<GroceryList> {
//   List<GroceryItem> newGroceryItems = [];

//   var isLoading = true;
//   String? fetchError;

//   @override
//   void initState() {
//     super.initState();
//     fetchGroceryItems();
//   }

//   void fetchGroceryItems() async {
//     final url = Uri.https(
//         "grocelist-31cb2-default-rtdb.firebaseio.com", "shopping-list.json");
//     try {
//       final response = await http.get(url);

//       if (response.statusCode >= 400) {
//         setState(() {
//           fetchError = "Failed to fetch data, Please try again later";
//         });
//       }
//       if (response.body == "null") {
//         setState(() {
//           isLoading = false;
//         });
//         return;
//       }
//       final Map<String, dynamic> groceryListData = json.decode(response.body);
//       // This is created temporarily here so that it can replace newGroceryItems later.
//       final List<GroceryItem> groceryListItem = [];
//       for (final item in groceryListData.entries) {
//         // This is done to search for the category that matches the grocery item
//         // firstWhere method works almost like where method, only that it returns the first element that pass the test
//         final category = categories.entries
//             .firstWhere(
//                 (catItem) => catItem.value.title == item.value["category"])
//             .value;

//         groceryListItem.add(GroceryItem(
//           id: item.key,
//           name: item.value["name"],
//           quantity: item.value['quantity'],
//           category: category,
//         ));
//       }
//       setState(() {
//         newGroceryItems = groceryListItem;
//         isLoading = false;
//       });
//       // print(groceryListItem);
//     } catch (err) {
//       setState(() {
//         fetchError = "Somewthing went wrong! Please try again later.";
//       });
//     }
//   }

//   void addItem() async {
//     // final newItem = await Navigator.of(context).push(
//     //   MaterialPageRoute(
//     //     builder: (ctx) => const NewItem(),
//     //   ),
//     // );
//     final newItem = await Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (ctx) => const NewItem(),
//       ),
//     );

//     // fetchGroceryItems();

//     if (newItem == null) {
//       return;
//     }

//     setState(() {
//       newGroceryItems.add(newItem);
//     });
//     // setState(() {
//     //   newGroceryItems.add(newItem);
//     // });
//   }

//   void removeItem(GroceryItem item) async {
//     final index = newGroceryItems.indexOf(item);

//     setState(() {
//       newGroceryItems.remove(item);
//     });

//     final url = Uri.https("grocelist-31cb2-default-rtdb.firebaseio.com",
//         "shopping-list/${item.id}.json");

//     final response = await http.delete(url);
//     if (response.statusCode >= 400) {
//       setState(() {
//         newGroceryItems.insert(index, item);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     Widget content = const Center(
//       child: Text("No items aded yet"),
//     );
//     if (isLoading) {
//       content = const Center(
//         child: CircularProgressIndicator(),
//       );
//     }
//     if (newGroceryItems.isNotEmpty) {
//       content = ListView.builder(
//           itemCount: newGroceryItems.length,
//           itemBuilder: (ctx, index) => Dismissible(
//                 key: ValueKey(newGroceryItems[index].id),
//                 onDismissed: (direction) {
//                   removeItem(newGroceryItems[index]);
//                   // setState(() {
//                   //   newGroceryItems.remove(newGroceryItems[index]);
//                   // });
//                 },
//                 child: ListTile(
//                   title: Text(newGroceryItems[index].name),
//                   leading: Container(
//                     width: 24,
//                     height: 24,
//                     color: newGroceryItems[index].category.color,
//                   ),
//                   trailing: Text(newGroceryItems[index].quantity.toString()),
//                 ),
//               ));
//     }
//     if (fetchError != null) {
//       content = Center(
//         child: Text(fetchError!),
//       );
//     }

//     return Scaffold(
//         appBar: AppBar(
//           title: const Text("Grocery list"),
//           actions: [
//             IconButton(onPressed: addItem, icon: const Icon(Icons.add))
//           ],
//         ),
//         body: content);
//   }
// }

// ignore_for_file: unused_element
// Using FutureBuilder widget to improve code; it helps when working with Future-related data

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:grocelist/data/categories.dart';
// import 'package:grocelist/data/dummy_items.dart';
import 'package:grocelist/models/grocery_item.dart';
import 'package:grocelist/widgets/add_new_item.dart';

import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({
    super.key,
  });

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> newGroceryItems = [];

  // var isLoading = true;
  late Future<List<GroceryItem>> fetchedGroceryItems;
  String? fetchError;

  @override
  void initState() {
    super.initState();
    // fetchGroceryItems();
    fetchedGroceryItems = fetchGroceryItems();
  }

  Future<List<GroceryItem>> fetchGroceryItems() async {
    final url = Uri.https(
        "grocelist-31cb2-default-rtdb.firebaseio.com", "shopping-list.json");
    // try {
    final response = await http.get(url);

    if (response.statusCode >= 400) {
      throw Exception("Failed to fetch grocery items, try again later.");
      // setState(() {
      //   fetchError = "Failed to fetch data, Please try again later";
      // });
    }
    if (response.body == "null") {
      // setState(() {
      //   isLoading = false;
      // });
      return [];
    }
    final Map<String, dynamic> groceryListData = json.decode(response.body);
    // This is created temporarily here so that it can replace newGroceryItems later.
    final List<GroceryItem> groceryListItem = [];
    for (final item in groceryListData.entries) {
      // This is done to search for the category that matches the grocery item
      // firstWhere method works almost like where method, only that it returns the first element that pass the test
      final category = categories.entries
          .firstWhere(
              (catItem) => catItem.value.title == item.value["category"])
          .value;

      groceryListItem.add(GroceryItem(
        id: item.key,
        name: item.value["name"],
        quantity: item.value['quantity'],
        category: category,
      ));
    }
    return fetchedGroceryItems;
    // setState(() {
    //   newGroceryItems = groceryListItem;
    //   isLoading = false;
    // });
    // print(groceryListItem);
    // }
    // catch (err) {
    //   setState(() {
    //     fetchError = "Somewthing went wrong! Please try again later.";
    //   });
    // }
  }

  void addItem() async {
    // final newItem = await Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (ctx) => const NewItem(),
    //   ),
    // );
    final newItem = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );

    // fetchGroceryItems();

    if (newItem == null) {
      return;
    }

    setState(() {
      newGroceryItems.add(newItem);
    });
    // setState(() {
    //   newGroceryItems.add(newItem);
    // });
  }

  void removeItem(GroceryItem item) async {
    final index = newGroceryItems.indexOf(item);

    setState(() {
      newGroceryItems.remove(item);
    });

    final url = Uri.https("grocelist-31cb2-default-rtdb.firebaseio.com",
        "shopping-list/${item.id}.json");

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      setState(() {
        newGroceryItems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Widget content = const Center(
    //   child: Text("No items aded yet"),
    // );
    // if (isLoading) {
    //   content = const Center(
    //     child: CircularProgressIndicator(),
    //   );
    // }
    // if (newGroceryItems.isNotEmpty) {
    //   content = ListView.builder(
    //       itemCount: newGroceryItems.length,
    //       itemBuilder: (ctx, index) => Dismissible(
    //             key: ValueKey(newGroceryItems[index].id),
    //             onDismissed: (direction) {
    //               removeItem(newGroceryItems[index]);
    //               // setState(() {
    //               //   newGroceryItems.remove(newGroceryItems[index]);
    //               // });
    //             },
    //             child: ListTile(
    //               title: Text(newGroceryItems[index].name),
    //               leading: Container(
    //                 width: 24,
    //                 height: 24,
    //                 color: newGroceryItems[index].category.color,
    //               ),
    //               trailing: Text(newGroceryItems[index].quantity.toString()),
    //             ),
    //           ));
    // }
    // if (fetchError != null) {
    //   content = Center(
    //     child: Text(fetchError!),
    //   );
    // }

    return Scaffold(
        appBar: AppBar(
          title: const Text("Grocery list"),
          actions: [
            IconButton(onPressed: addItem, icon: const Icon(Icons.add))
          ],
        ),
        // body: content);
        body: FutureBuilder(
            future: fetchedGroceryItems,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }
              if (snapshot.data!.isEmpty) {
                return const Center(
                  child: Text("No items aded yet"),
                );
              }
              return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (ctx, index) => Dismissible(
                        key: ValueKey(snapshot.data![index].id),
                        onDismissed: (direction) {
                          removeItem(snapshot.data![index]);
                          // setState(() {
                          //   newGroceryItems.remove(newGroceryItems[index]);
                          // });
                        },
                        child: ListTile(
                          title: Text(snapshot.data![index].name),
                          leading: Container(
                            width: 24,
                            height: 24,
                            color: snapshot.data![index].category.color,
                          ),
                          trailing:
                              Text(snapshot.data![index].quantity.toString()),
                        ),
                      ));
            }));
  }
}
