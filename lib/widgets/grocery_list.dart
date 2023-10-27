import 'package:flutter/material.dart';
// import 'package:grocelist/data/dummy_items.dart';
import 'package:grocelist/models/grocery_item.dart';
import 'package:grocelist/widgets/add_new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({
    super.key,
  });

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  @override
  Widget build(BuildContext context) {
    final List<GroceryItem> newGroceryItems = [];
    Widget content = const Center(
      child: Text("No items aded yet"),
    );

    if (newGroceryItems.isNotEmpty) {
      content = ListView.builder(
          itemCount: newGroceryItems.length,
          itemBuilder: (ctx, index) => Dismissible(
                key: ValueKey(newGroceryItems[index].id),
                onDismissed: (direction) {
                  setState(() {
                    newGroceryItems.remove(newGroceryItems[index]);
                  });
                },
                child: ListTile(
                  title: Text(newGroceryItems[index].name),
                  leading: Container(
                    width: 24,
                    height: 24,
                    color: newGroceryItems[index].category.color,
                  ),
                  trailing: Text(newGroceryItems[index].quantity.toString()),
                ),
              ));
    }
    void addItem() async {
      final newItem = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => const NewItem(),
        ),
      );
      if (newItem == null) {
        return;
      }
      setState(() {
        newGroceryItems.add(newItem);
      });
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("Grocery list"),
          actions: [
            IconButton(onPressed: addItem, icon: const Icon(Icons.add))
          ],
        ),
        body: content);
  }
}
