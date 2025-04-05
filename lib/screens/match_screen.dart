import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class MatchScreen extends StatefulWidget {
  final UserService? userService;

  const MatchScreen({Key? key, this.userService}) : super(key: key);

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  final UserService _userService = MockUserService();
  late Future<List<User>> _potentialPartnersFuture;

  @override
  void initState() {
    super.initState();
    _potentialPartnersFuture =
        (widget.userService ?? _userService).getPotentialPartners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find a Partner')),
      body: FutureBuilder<List<User>>(
        future: _potentialPartnersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final potentialPartners = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: potentialPartners.length,
            itemBuilder: (context, index) {
              final partner = potentialPartners[index];
              return _buildPartnerCard(partner);
            },
          );
        },
      ),
    );
  }

  Widget _buildPartnerCard(User partner) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(partner.profileImageUrl),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partner.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      'Fitness Level: ${partner.fitnessLevel.toUpperCase()}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Interests', style: Theme.of(context).textTheme.titleMedium),
            Wrap(
              spacing: 8,
              children:
                  partner.interests
                      .map((interest) => Chip(label: Text(interest)))
                      .toList(),
            ),
            const SizedBox(height: 8),
            Text('Goals', style: Theme.of(context).textTheme.titleMedium),
            Wrap(
              spacing: 8,
              children:
                  partner.fitnessGoals
                      .map((goal) => Chip(label: Text(goal)))
                      .toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final result = await _userService.matchWithPartner(partner.id);
                if (!mounted) return;

                if (result) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Matched with ${partner.name}!')),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Match with Partner'),
            ),
          ],
        ),
      ),
    );
  }
}
