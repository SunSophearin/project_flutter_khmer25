import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:project_flutter_khmer25/components/home/home_list_product_horizontal_card.dart';
import 'package:project_flutter_khmer25/models/product_model.dart';
import 'package:project_flutter_khmer25/providers/product_provider.dart';

// ✅ add these (must exist in your project)
import 'package:project_flutter_khmer25/providers/auth_provider.dart';
import 'package:project_flutter_khmer25/providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int qty = 1;
  bool _inited = false;
  bool _adding = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inited) {
      _inited = true;
      context.read<ProductProvider>().fetchProductDetail(widget.productId);
    }
  }

  Future<void> _handleAddToCart(Product p) async {
    final auth = context.read<AuthProvider>();
    final cartProv = context.read<CartProvider>();

    if (!auth.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("សូម Login មុន ដើម្បីបន្ថែមចូលកន្ត្រក 🙏"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_adding) return;

    setState(() => _adding = true);

    try {
      final ok = await cartProv.addToCart(
        productId: p.id,
        qty: qty,
        accessToken: auth.access,
      );

      if (!mounted) return;

      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("បានបន្ថែម ${p.name} x$qty ចូលកន្ត្រក ✅"),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cartProv.error ?? "បន្ថែមមិនបាន ❌"),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("បន្ថែមមិនបាន ❌\n$e"),
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ProductProvider>();
    final p = prov.detailProduct;

    if (prov.isLoadingDetail) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (prov.detailError != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(prov.detailError!)),
      );
    }

    if (p == null) {
      return const Scaffold(body: Center(child: Text("No product")));
    }

    final hasDiscount = p.discountPercent > 0;
    final finalPrice = p.finalPrice;
    final oldPrice = p.price;
    final total = finalPrice * qty;

    final relatedProducts = p.relatedProducts.take(10).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: Colors.black,
        titleSpacing: 0,
        title: Text(
          p.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border)),
          const SizedBox(width: 4),
        ],
      ),

      // ✅ Sticky bottom bar
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 18,
                offset: const Offset(0, -4),
                color: Colors.black.withOpacity(0.06),
              ),
            ],
          ),
          child: Row(
            children: [
              _QtySelector(
                qty: qty,
                onMinus: () => setState(() => qty = qty > 1 ? qty - 1 : 1),
                onPlus: () => setState(() => qty = qty + 1),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: (_adding || !p.isInStock)
                      ? null
                      : () => _handleAddToCart(p),
                  child: _adding
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          p.isInStock
                              ? "បន្ថែមចូលកន្ត្រក • ${_fmt(total)}៛"
                              : "អស់ស្តុក",
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 130),
        children: [
          // ================= IMAGE =================
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 1.05,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'product_${p.id}',
                    child: Image.network(
                      p.image ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(Icons.image_not_supported),
                        ),
                      ),
                    ),
                  ),
                  if (hasDiscount)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: _DiscountPill(percent: p.discountPercent),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ================= TITLE + UNIT =================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  p.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              if (p.unit != null && p.unit!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    p.unit!,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // ================= PRICE =================
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${_fmt(finalPrice)}៛",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              if (hasDiscount)
                Text(
                  "${_fmt(oldPrice)}៛",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    decoration: TextDecoration.lineThrough,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          // ================= DESCRIPTION =================
          const _SectionTitle(title: "ពិពណ៌នា"),
          const SizedBox(height: 8),
          Text(
            (p.description?.isNotEmpty == true)
                ? p.description!
                : "មិនទាន់មានពិពណ៌នា។",
            style: TextStyle(
              color: Colors.grey.shade800,
              height: 1.55,
              fontSize: 14.5,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: const [
              Expanded(
                child: _InfoTile(
                  icon: Icons.local_shipping_outlined,
                  title: "ដឹកជញ្ជូន",
                  subtitle: "ក្នុងថ្ងៃ / 1–2ថ្ងៃ",
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _InfoTile(
                  icon: Icons.verified_outlined,
                  title: "ទំនុកចិត្ត",
                  subtitle: "ផលិតផលគុណភាព",
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ================= RELATED =================
          const _SectionTitle(title: "ផលិតផលពាក់ព័ន្ធ"),
          const SizedBox(height: 10),
          if (relatedProducts.isEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                "មិនទាន់មានផលិតផលពាក់ព័ន្ធក្នុងប្រភេទដូចគ្នា។",
                style: TextStyle(color: Colors.grey.shade700),
              ),
            )
          else
            ProductHorizontalList(products: relatedProducts),
        ],
      ),
    );
  }
}

// ===================== WIDGETS =====================

class _DiscountPill extends StatelessWidget {
  final int percent;
  const _DiscountPill({required this.percent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        "-$percent%",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtySelector extends StatelessWidget {
  final int qty;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _QtySelector({
    required this.qty,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onMinus,
            icon: const Icon(Icons.remove),
            visualDensity: VisualDensity.compact,
          ),
          Text(
            "$qty",
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          IconButton(
            onPressed: onPlus,
            icon: const Icon(Icons.add),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

String _fmt(double v) => v < 1 ? v.toStringAsFixed(2) : v.toStringAsFixed(0);
