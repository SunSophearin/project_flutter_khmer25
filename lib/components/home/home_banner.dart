import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_flutter_khmer25/providers/banner_provider.dart';
import 'package:project_flutter_khmer25/models/banner_model.dart';

/// slide ផលិតផលពាណិជ្ជកម្ម
class HomeBanner extends StatefulWidget {
  const HomeBanner({super.key});

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  int _bannerIndex = 0;

  @override
  Widget build(BuildContext context) {
    final bannerProv = context.watch<BannerProvider>();
    final List<BannerModel> banners = bannerProv.banners;

    if (banners.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(child: Text('No banners')),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 160,
          width: double.infinity,

          child: PageView.builder(
            itemCount: banners.length,
            onPageChanged: (index) {
              setState(() {
                _bannerIndex = index;
              });
            },

            itemBuilder: (context, index) {
              final banner = banners[index];

              return ClipRRect(
                borderRadius: BorderRadius.circular(16),

                child: SizedBox.expand(
                  child: Image.network(
                    banner.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    alignment: Alignment.center,
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(banners.length, (index) {
            final bool isActive = index == _bannerIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 16 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ),
      ],
    );
  }
}
