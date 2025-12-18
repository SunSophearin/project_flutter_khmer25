import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_flutter_khmer25/providers/auth_provider.dart';
import 'package:project_flutter_khmer25/screens/login_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    const String profileImage =
        "https://img.freepik.com/premium-vector/vector-flat-illustration-grayscale-avatar-user-profile-person-icon-profile-picture-business-profile-woman-suitable-social-media-profiles-icons-screensavers-as-templatex9_719432-1351.jpg";

    final String userName = auth.isLoggedIn
        ? (auth.me == null ? "Loading..." : (auth.me?["username"] ?? "User"))
        : "Guest";

    const String userLocation = "Phnom Penh, Cambodia";

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        children: [
          _headerCard(profileImage, userName, userLocation, auth.isLoggedIn),
          const SizedBox(height: 16),

          if (!auth.isLoggedIn) ...[
            _sectionTitle("Welcome"),
            const SizedBox(height: 10),
            Row(
              children: [
                // Expanded(
                //   child: _actionButton(
                //     context,
                //     icon: Icons.person_add_alt_1,
                //     title: "Register",
                //     subtitle: "Create account",
                //     onTap: () async {
                //       await Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //           builder: (_) => const RegisterScreen(),
                //         ),
                //       );
                //     },
                //   ),
                // ),
                const SizedBox(width: 12),
                Expanded(
                  child: _actionButton(
                    context,
                    icon: Icons.login,
                    title: "ចូលកម្មវិធី",
                    subtitle: "សូមចូលកម្មវិធីដើម្បីបន្ត",
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],

          if (auth.isLoggedIn) ...[
            _sectionTitle("Account"),
            const SizedBox(height: 10),
            _menuTile(
              icon: Icons.edit,
              title: "Edit profile",
              subtitle: "Update info",
              onTap: () {},
            ),
            _menuTile(
              icon: Icons.history,
              title: "My Orders",
              subtitle: "See your orders",
              onTap: () {},
            ),
            _menuTile(
              icon: Icons.location_city,
              title: "Addresses",
              subtitle: "Delivery addresses",
              onTap: () {},
            ),
            _menuTile(
              icon: Icons.settings,
              title: "Settings",
              subtitle: "App preferences",
              onTap: () {},
            ),
            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Logout"),
                      content: const Text("Are you sure you want to logout?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text("Logout"),
                        ),
                      ],
                    ),
                  );

                  if (ok != true) return;

                  await context.read<AuthProvider>().logout();
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("Logged out ✅")));
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- helpers (same as your code) ---
  static Widget _headerCard(
    String img,
    String name,
    String location,
    bool loggedIn,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2ECC71),
            const Color(0xFF2ECC71).withOpacity(.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 38, backgroundImage: NetworkImage(img)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  loggedIn ? "Status: Logged in ✅" : "Status: Not logged in ❌",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _sectionTitle(String title) => Row(
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
      ),
    ],
  );

  static Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF2ECC71).withOpacity(.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF2ECC71)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black38),
          ],
        ),
      ),
    );
  }

  static Widget _menuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.05),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: ListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF2ECC71).withOpacity(.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF2ECC71)),
            ),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: Text(
              subtitle,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.black38),
          ),
        ),
      ),
    );
  }
}
