import 'package:flutter/material.dart';
import '../services/social_service.dart';
import '../services/auth_service.dart';
import 'public_profile_screen.dart';

class FollowersScreen extends StatefulWidget {
  final int userId;
  final String initialTab; // 'followers' or 'following'

  const FollowersScreen({super.key, required this.userId, this.initialTab = 'followers'});

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _followers = [];
  List<Map<String, dynamic>> _following = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTab == 'followers' ? 0 : 1);
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final followersData = await SocialService.getFollowers(widget.userId);
      final followingData = await SocialService.getFollowing(widget.userId);
      
      if (mounted) {
        setState(() {
          _followers = followersData;
          _following = followingData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat data.')));
      }
    }
  }

  void _navigateToProfile(int userId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PublicProfileScreen(userId: userId)),
    ).then((_) {
      // Refresh data when returning, in case follow status changed
      _fetchData();
    });
  }

  Widget _buildUserList(List<Map<String, dynamic>> users, String emptyMessage) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(emptyMessage, style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final bool isAdmin = user['role'] == 'ADMIN' || user['role'] == 'SUPERADMIN';
        final String profileImageUrl = user['profileImage'] != null && user['profileImage'].isNotEmpty
            ? 'http://208.76.40.81:3000/uploads/${user['profileImage']}'
            : '';

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey.shade300,
            backgroundImage: profileImageUrl.isNotEmpty ? NetworkImage(profileImageUrl) : null,
            child: profileImageUrl.isEmpty
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  user['name'] ?? 'User',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isAdmin) ...[
                const SizedBox(width: 4),
                const Icon(Icons.verified, color: Colors.blue, size: 16),
              ]
            ],
          ),
          subtitle: Text('@${user['username'] ?? ''}'),
          onTap: () => _navigateToProfile(user['id']),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Koneksi', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pengikut'),
            Tab(text: 'Mengikuti'),
          ],
          indicatorColor: Colors.orange,
          labelColor: Colors.orange,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUserList(_followers, 'Belum ada pengikut.'),
          _buildUserList(_following, 'Belum mengikuti siapa pun.'),
        ],
      ),
    );
  }
}
