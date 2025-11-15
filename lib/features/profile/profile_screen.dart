import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_fashion_app/features/profile/user_profile_provider.dart';
import 'package:new_fashion_app/features/auth/presentation/controllers/auth_state_provider.dart'; // For AuthState

import '../../core/providers.dart';
import '../auth/data/services/auth_service.dart'; // NEW: Import the new provider

// Define a common color for consistency (assuming this is used elsewhere)
const Color kPrimaryRecommendationColor = Color(0xFFD00A62);

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the auth state for sign-out logic (optional, but good practice)
    final authService = ref.read(authServiceProvider.notifier);
    final authStatus = ref.watch(authServiceProvider); // To react to logout

    // Watch the userProfileProvider to get the user's data
    final userProfileState = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display User Profile Section based on userProfileState
            _buildProfileSection(
              context,
              userProfileState: userProfileState, // Pass the entire state
            ),
            const SizedBox(height: 24),
            _buildSectionTitle("Account Settings"),
            const SizedBox(height: 16),
            // Pass the authService and context to _buildSettingsOptions
            _buildSettingsOptions(context, authService, authStatus),
          ],
        ),
      ),
    );
  }

  // --- Profile Section (Updated to accept UserProfileState) ---
  Widget _buildProfileSection(BuildContext context, {
    required UserProfileState userProfileState,
  }) {
    String username = 'Loading...';
    String email = 'Loading...';
    String? profilePictureUrl;
    Widget avatarWidget;

    if (userProfileState.isLoading) {
      avatarWidget = CircleAvatar(
        radius: 30,
        backgroundColor: Colors.grey[200],
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    } else if (userProfileState.error != null) {
      username = 'Error';
      email = userProfileState.error!;
      avatarWidget = CircleAvatar(
        radius: 30,
        backgroundColor: Colors.red[100],
        child: const Icon(Icons.error, color: Colors.red),
      );
    } else if (userProfileState.userData != null) {
      username = userProfileState.userData!['username'] ?? 'User Name';
      email = userProfileState.userData!['email'] ?? 'user@example.com';
      profilePictureUrl = userProfileState.userData!['profile_picture'];

      avatarWidget = CircleAvatar(
        radius: 30,
        backgroundImage: profilePictureUrl != null && profilePictureUrl.isNotEmpty
            ? NetworkImage(profilePictureUrl) as ImageProvider<Object>?
            : const AssetImage("assets/icons/default_avatar.png"), // Provide a default local asset
        backgroundColor: Colors.grey[200], // Background for default/loading state
      );
    } else {
      // Fallback for no data, no error, not loading (shouldn't happen often)
      avatarWidget = CircleAvatar(
        radius: 30,
        backgroundColor: Colors.grey[200],
        child: const Icon(Icons.person),
      );
    }


    return Row(
      children: [
        avatarWidget,
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              username,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF060A0F),
              ),
            ),
            Text(
              email,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF8C9096),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Color(0xFF060A0F),
      ),
    );
  }

  // --- Settings Options (remains largely the same, no changes needed for this section) ---
  Widget _buildSettingsOptions(
      BuildContext context,
      AuthService authService,
      AuthStatus authStatus,
      ) {
    final List<Map<String, dynamic>> settingsOptions = [
      {"title": "Notifications", "icon": Icons.notifications},
      {"title": "Customer Support", "icon": Icons.support_agent},
      {"title": "Password & Security", "icon": Icons.lock},
      {"title": "About", "icon": Icons.info},
      {"title": "Sign Out", "icon": Icons.logout, "isLogout": true},
    ];

    return Column(
      children: settingsOptions.map((option) {
        bool isLogout = option["isLogout"] == true;
        return Column(
          children: [
            ListTile(
              leading: Icon(
                option["icon"],
                color: isLogout ? Colors.red : Colors.black,
              ),
              title: Text(
                option["title"],
                style: TextStyle(
                  fontSize: 14,
                  color: isLogout ? Colors.red : Colors.black,
                ),
              ),
              trailing: isLogout ? null : const Icon(Icons.arrow_forward_ios, size: 16), // No arrow for logout
              onTap: () async {
                if (isLogout) {
                  final bool confirm = await showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: const Text("Sign Out"),
                        content: const Text("Are you sure you want to sign out?"),
                        actions: <Widget>[
                          TextButton(
                            child: const Text("Cancel"),
                            onPressed: () {
                              Navigator.of(dialogContext).pop(false);
                            },
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Sign Out"),
                            onPressed: () {
                              Navigator.of(dialogContext).pop(true);
                            },
                          ),
                        ],
                      );
                    },
                  ) ?? false;
                  if (confirm) {
                    await authService.signOut();
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tapped on ${option["title"]}')),
                  );
                }
              },
            ),
            Divider(color: Colors.grey[300]),
          ],
        );
      }).toList(),
    );
  }
}