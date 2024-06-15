import 'dart:core';
import 'package:flutter/material.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _names = [
    'Alice', 'Bob', 'Charlie', 'David', 'Eva', 'Frank', 'Grace', 'Hannah', 'Ivy', 'Jack', 'Kara'
  ];

  final List<String> _images = [
    'https://randomuser.me/api/portraits/men/1.jpg',
    'https://randomuser.me/api/portraits/women/1.jpg',
    'https://randomuser.me/api/portraits/men/2.jpg',
    'https://randomuser.me/api/portraits/women/2.jpg',
    'https://randomuser.me/api/portraits/men/3.jpg',
    'https://randomuser.me/api/portraits/women/3.jpg',
    'https://randomuser.me/api/portraits/men/4.jpg',
    'https://randomuser.me/api/portraits/women/4.jpg',
    'https://randomuser.me/api/portraits/men/5.jpg',
    'https://randomuser.me/api/portraits/women/5.jpg',
    'https://randomuser.me/api/portraits/men/6.jpg',
  ];

  final List<String> _cities = [
    'Mumbai', 'Pune', 'Bangalore', 'Jaipur', 'New York', 'Delhi', 'Noida', 'Dehradun', 'Surat'
  ];

  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _displayedUsers = [];
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  int _currentMax = 20;

  @override
  void initState() {
    super.initState();
    _generateUsers();
    _displayedUsers = _allUsers.take(_currentMax).toList();
    _scrollController.addListener(_scrollListener);
  }

  void _generateUsers() {
    final random = Random();
    _allUsers = List.generate(
      43,
      (index) {
        final name = _names[random.nextInt(_names.length)];
        final image = _images[random.nextInt(_images.length)];
        final city = _cities[random.nextInt(_cities.length)];
        return {
          "name": name,
          "phone": "90330062${index.toString().padLeft(2, '0')}",
          "city": city,
          "image": image,
          "rupee": random.nextInt(100),
        };
      },
    );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreData();
    }
  }

  void _loadMoreData() {
    if (_currentMax < _allUsers.length) {
      setState(() {
        _currentMax += 20;
        _displayedUsers = _allUsers.take(_currentMax).toList();
      });
    }
  }

  void _filterList(String query) {
    final filteredList = _allUsers.where((user) {
      final nameLower = user['name']!.toLowerCase();
      final phoneLower = user['phone']!.toLowerCase();
      final cityLower = user['city']!.toLowerCase();
      final searchLower = query.toLowerCase();

      return nameLower.contains(searchLower) ||
          phoneLower.contains(searchLower) ||
          cityLower.contains(searchLower);
    }).toList();

    setState(() {
      _currentMax = 20;
      _displayedUsers = filteredList.take(_currentMax).toList();
    });
  }

  Future<void> _showEditRupeeDialog(int index) async {
    final user = _displayedUsers[index];
    final TextEditingController rupeeController = TextEditingController(
      text: user['rupee'].toString(),
    );

    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Rupee for ${user['name']}'),
        content: TextField(
          controller: rupeeController,
          decoration: const InputDecoration(labelText: 'Rupee'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final updatedRupee =
                  int.tryParse(rupeeController.text) ?? user['rupee'];
              Navigator.of(context).pop(updatedRupee);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        final userIndex =
            _allUsers.indexWhere((u) => u['phone'] == user['phone']);
        if (userIndex != -1) {
          _allUsers[userIndex]['rupee'] = result;
          _displayedUsers[index]['rupee'] = result;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 194, 219, 196),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 194, 219, 196),
        title: const Text('User List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search',
                        ),
                        onChanged: _filterList,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _filterList('');
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _displayedUsers.length + 1,
              itemBuilder: (context, index) {
                if (index == _displayedUsers.length) {
                  return _currentMax < _allUsers.length
                      ? const Center(child: CircularProgressIndicator())
                      : Container();
                }
                final user = _displayedUsers[index];
                final rupee = user['rupee'];
                final rupeeStatus = rupee > 50 ? 'High' : 'Low';

                return ListTile(
                  leading: Image.network(user['image']),
                  title: Text(user['name']),
                  subtitle: Text('${user['phone']} - ${user['city']}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('₹$rupee'),
                      Text(
                        rupeeStatus,
                        style: TextStyle(
                          color: rupee > 50 ? Color.fromARGB(255, 16, 104, 19) : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  onTap: () => _showEditRupeeDialog(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

