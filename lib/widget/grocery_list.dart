import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_app/data/categories.dart';
import 'package:shopping_app/models/grocery_item.dart';
import 'package:shopping_app/widget/newitem.dart';
import 'package:http/http.dart' as http;

class Grocerylist extends StatefulWidget {
  const Grocerylist({super.key});

  @override
  State<Grocerylist> createState() => _GrocerylistState();
}

class _GrocerylistState extends State<Grocerylist> {
  List<GroceryItem> _gorceryitem = [];
  var _isloading= true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loaditems();
  }

  void _loaditems() async {
    final url = Uri.https(
        'shoppingapp-6c618-default-rtdb.firebaseio.com', 'shopping-list.json');
    
    // internet connection is missing or link is invalid  then use try catch keyword

    try{
      final response = await http.get(url);
      if(response.statusCode>= 400){
      setState(() {
        error= 'Unable to fetch data, Please try again later/';
      });
    }
    if(response.body== 'null'){
      setState(() {
        _isloading= false;
      });
      return ;
    }

    final Map<String, dynamic> listdata = json.decode(response.body);

    final List<GroceryItem> loadeditems = [];
    for (final item in listdata.entries) {  
      final category = categories.entries
          .firstWhere(
              (element) => element.value.title == item.value['category'])
          .value;

      loadeditems.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category));
    }
    setState(() {
      _gorceryitem = loadeditems;
      _isloading= false;
    });
    } catch(err){
      setState(() {
        error= 'Something wen wrong, Please try again later/';
      });
    }


    
  }

  void _addItem() async {
    final newitem= await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const Newitem(),
      ),
    );

    if(newitem== null){
      return;
    }
    setState(() {
      _gorceryitem.add(newitem);
    });


  }

  void dismissed(GroceryItem item) async{
    final indx= _gorceryitem.indexOf(item);
    setState(() {
      _gorceryitem.remove(item);
    });

    final url = Uri.https(
        'shoppingapp-6c618-default-rtdb.firebaseio.com', 'shopping-list/${item.id}.json');
      final response = await http.delete(url);

      if(response.statusCode>=400){
        setState(() {
          _gorceryitem.insert(indx, item);
        });
      }

  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('No items added yet!'),
    );

    if(_isloading){
      content = const Center(child: CircularProgressIndicator());
    }


    if (_gorceryitem.isNotEmpty ) {
      content = ListView.builder(
          itemCount: _gorceryitem.length,
          itemBuilder: (ctx, index) => Dismissible(
                onDismissed: (direction) {
                  dismissed(_gorceryitem[index]);
                },
                key: ValueKey(_gorceryitem[index].id),
                child: ListTile(
                  title: Text(_gorceryitem[index].name),
                  leading: Container(
                    width: 24,
                    height: 24,
                    color: _gorceryitem[index].category.color,
                  ),
                  trailing: Text(_gorceryitem[index].quantity.toString()),
                ),
              ));
    }

    if(error!= null){
      content = Center(child: Text(error!),);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),
      body: content,
    );
  }
}
