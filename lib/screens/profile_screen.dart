import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String profileImage =
        "https://scontent.fpnh18-5.fna.fbcdn.net/v/t39.30808-1/571159858_1351653233279054_7040561753652183468_n.jpg?stp=dst-jpg_s200x200_tt6&_nc_cat=103&_nc_cb=99be929b-ad57045b&ccb=1-7&_nc_sid=1d2534&_nc_eui2=AeF4s48BCcTPo3ZW8by1k3idcBXqgPXJhctwFeqA9cmFy5pKdbMCbsC9T-9BRAwNx5umrqUgRw5ZvTOKh5xV_Eye&_nc_ohc=vygSlqX4C7AQ7kNvwGDeBfG&_nc_oc=AdnbfyFjeV1sH8b0KVJjoVoLQDddbX0pruAD3LSaHOdo-Uwlg11fTwRSJxUWjuycmgg&_nc_zt=24&_nc_ht=scontent.fpnh18-5.fna&_nc_gid=_sfiuBUS8pOzPsj8Tfqp1Q&oh=00_Afl3lEVItMCi_vENYEMsn3V10OUunwPHiSfaVqjob0wYyQ&oe=693AD6FC";
    const String userName = "Jane (Phon Sokunkanha)";
    const String userLocation = "Phnom Penh, Cambodia";

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ផ្ទាំងគ្រប់គ្រងអ្នកប្រើប្រាស់',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🟦 Profile Image
            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: const NetworkImage(profileImage),
            ),

            const SizedBox(height: 12),

            // 🟦 User Name
            const Text(
              userName,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 6),

            // 🟦 Location
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.location_on, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  userLocation,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
