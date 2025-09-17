import 'package:adminui/models/User.dart';
import 'package:adminui/repository/UserRepository.dart';
import 'package:flutter/material.dart';

class UserIdPromptPage extends StatefulWidget {
  const UserIdPromptPage({Key? key}) : super(key: key);
   
  @override
  _UserIdPromptPageState createState() => _UserIdPromptPageState();
}

class _UserIdPromptPageState extends State<UserIdPromptPage> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _showDetailsFields = false;
  final UserRepository _repository = UserRepository();


  @override
  void dispose() {
  _userIdController.dispose();
  _emailController.dispose();
  _nameController.dispose();
  _phoneController.dispose();
  super.dispose();
  }

  void _submitUserId() {
    print('Submitting User ID: ${_userIdController.text}');
    User user =  User();
    user.Userid = _userIdController.text.trim();
    user.Email  = _emailController.text.trim();
    user.Name = _nameController.text.trim();
    user.phonenum  = _phoneController.text.trim();
    _repository.changeuser(user) ;

  }

  Future<void> _getUserDetails() async {
    final userId = _userIdController.text.trim();
    if (userId.isNotEmpty) {
      User user = await _repository.getUser(userId);
      print(user.Email);
      
      setState(() {
        _showDetailsFields = true;
        if (user.Email != null) {
          _emailController.text = user.Email!;
          _nameController.text = user.Name ?? '';
          _phoneController.text = user.phonenum ?? '';
        }
      });
      // TODO: Fetch user details if needed
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a User ID')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter User Details to Modify'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _userIdController,
                decoration: const InputDecoration(
                  labelText: 'User ID',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _getUserDetails,
                child: const Text('GET'),
              ),
              if (_showDetailsFields) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitUserId,
                  child: const Text('Submit'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}