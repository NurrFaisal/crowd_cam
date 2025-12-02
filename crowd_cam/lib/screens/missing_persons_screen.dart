import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/missing_person.dart';

class MissingPersonsScreen extends StatefulWidget {
  const MissingPersonsScreen({Key? key}) : super(key: key);

  @override
  State<MissingPersonsScreen> createState() => _MissingPersonsScreenState();
}

class _MissingPersonsScreenState extends State<MissingPersonsScreen> {
  List<MissingPerson> _missingPersons = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMissingPersons();
    });
  }

  Future<void> _loadMissingPersons() async {
    final apiService = context.read<ApiService>();
    final persons = await apiService.fetchMissingPersons();
    setState(() {
      _missingPersons = persons;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApiService>(
      builder: (context, apiService, child) {
        if (apiService.isLoading && _missingPersons.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (_missingPersons.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_search,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No missing persons reported',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadMissingPersons,
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _missingPersons.length,
            itemBuilder: (context, index) {
              final person = _missingPersons[index];
              return _buildPersonCard(person);
            },
          ),
        );
      },
    );
  }

  Widget _buildPersonCard(MissingPerson person) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: person.photoUrl.isNotEmpty
              ? NetworkImage(person.photoUrl)
              : null,
          child: person.photoUrl.isEmpty
              ? const Icon(Icons.person, size: 30)
              : null,
        ),
        title: Text(
          person.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Age: ${person.age}'),
            const SizedBox(height: 2),
            Text(
              'Last seen: ${_formatDate(person.lastSeenDate)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 2),
            Text(
              person.lastSeenLocation,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: person.isActive ? Colors.red[100] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                person.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  color: person.isActive ? Colors.red[800] : Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        onTap: () => _showPersonDetails(person),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showPersonDetails(MissingPerson person) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Photo
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                  image: person.photoUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(person.photoUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: person.photoUrl.isEmpty
                    ? const Center(
                        child: Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.grey,
                        ),
                      )
                    : null,
              ),
              
              // Details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Age: ${person.age}'),
                    const SizedBox(height: 8),
                    Text('Last seen: ${_formatDate(person.lastSeenDate)}'),
                    const SizedBox(height: 8),
                    Text('Location: ${person.lastSeenLocation}'),
                    const SizedBox(height: 12),
                    Text(
                      'Description:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(person.description),
                    const SizedBox(height: 12),
                    Text(
                      'Contact: ${person.contactInfo}',
                      style: TextStyle(color: Colors.blue[700]),
                    ),
                  ],
                ),
              ),
              
              // Actions
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}