import 'package:flutter/material.dart';


/// Search bar ស្វែងរកផលិតផល
class HomeSearchbar extends StatefulWidget {
  const HomeSearchbar({super.key});

  @override
  State<HomeSearchbar> createState() => _HomeSearchbarState();
}

class _HomeSearchbarState extends State<HomeSearchbar> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'ស្វែងរកផលិតផល...',
        prefixIcon: const Icon(Icons.search),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (value) {
        // TODO: call API search
      },
    );
  }
}
