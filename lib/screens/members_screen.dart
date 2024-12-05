import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  _MembersScreenState createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _usersList = [];
  List<Map<String, dynamic>> _filteredUsersList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  void _fetchUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await _firestore.collection('users').get();
      setState(() {
        _usersList = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'name': doc['name'],
            'email': doc['email'],
          };
        }).toList();
        _filteredUsersList = List.from(_usersList); // Initialize filtered list
      });
    } catch (e) {
      print('Error fetching users: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addUser() async {
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and email cannot be empty.')),
      );
      return;
    }

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: 'defaultpassword123',
      );

      await _firestore.collection('users').add({
        'name': name,
        'email': email,
        'uid': userCredential.user?.uid,
      });

      _nameController.clear();
      _emailController.clear();
      _fetchUsers(); // Refresh user list
    } catch (e) {
      print('Error adding user: $e');
    }
  }

  void _resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email sent to $email')),
      );
    } catch (e) {
      print('Error resetting password: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _filterUsers(String query) {
    setState(() {
      _filteredUsersList = _usersList
          .where((user) =>
              user['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showUserProfile(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(user['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Email: ${user['email']}'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _resetPassword(user['email']),
              child: const Text('Reset Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Field
            TextField(
              controller: _searchController,
              onChanged: _filterUsers,
              decoration: const InputDecoration(
                labelText: 'Search Members',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Add User Form
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addUser,
              child: const Text('Add Member'),
            ),
            const SizedBox(height: 16),

            // Member List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredUsersList.isEmpty
                      ? const Center(child: Text('No members found.'))
                      : ListView.builder(
                          itemCount: _filteredUsersList.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsersList[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text(user['name'][0]),
                                ),
                                title: Text(user['name']),
                                subtitle: Text(user['email']),
                                onTap: () => _showUserProfile(user),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
