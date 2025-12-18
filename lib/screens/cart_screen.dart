import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:project_flutter_khmer25/providers/auth_provider.dart';
import 'package:project_flutter_khmer25/providers/cart_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _inited = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inited) return;
    _inited = true;

    final auth = context.read<AuthProvider>();
    if (auth.isLoggedIn) {
      Future.microtask(() {
        context.read<CartProvider>().fetchCart(accessToken: auth.access);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cartProv = context.watch<CartProvider>();

    if (!auth.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text("កន្ត្រក")),
        body: const Center(
          child: Text("សូម Login មុន ដើម្បីមើលកន្ត្រក 🙏"),
        ),
      );
    }

    final cart = cartProv.cart;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("កន្ត្រក"),
        actions: [
          IconButton(
            onPressed: () => cartProv.fetchCart(accessToken: auth.access),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: cartProv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartProv.error != null
              ? _ErrorBox(
                  message: cartProv.error!,
                  onRetry: () => cartProv.fetchCart(accessToken: auth.access),
                )
              : (cart == null || cart.items.isEmpty)
                  ? const _EmptyCart()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
                      children: [
                        ...cart.items.map((it) => _CartItemCard(
                              itemId: it.id,
                              name: it.product.name,
                              image: it.product.image,
                              priceText: it.product.priceText,
                              qty: it.qty,
                              onMinus: () async {
                                final newQty = it.qty - 1;
                                await cartProv.updateQty(
                                  cartItemId: it.id,
                                  qty: newQty,
                                  accessToken: auth.access,
                                );
                              },
                              onPlus: () async {
                                final newQty = it.qty + 1;
                                await cartProv.updateQty(
                                  cartItemId: it.id,
                                  qty: newQty,
                                  accessToken: auth.access,
                                );
                              },
                              onRemove: () async {
                                await cartProv.removeItem(
                                  cartItemId: it.id,
                                  accessToken: auth.access,
                                );
                              },
                            )),
                      ],
                    ),

      // ✅ Total bar
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
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "សរុប (${cart?.totalQty ?? 0} items)",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${_fmt(cartProv.totalPrice)}៛",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: (cart == null || cart.items.isEmpty)
                      ? null
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("ទៅ Checkout (បន្ទាប់) ✅"),
                            ),
                          );
                        },
                  child: const Text(
                    "Checkout",
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final int itemId;
  final String name;
  final String? image;
  final String priceText;
  final int qty;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.itemId,
    required this.name,
    required this.image,
    required this.priceText,
    required this.qty,
    required this.onMinus,
    required this.onPlus,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        color: Colors.white,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 62,
              height: 62,
              child: Image.network(
                image ?? "",
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade100,
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  priceText,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    _QtyButton(icon: Icons.remove, onTap: onMinus),
                    const SizedBox(width: 8),
                    Text(
                      "$qty",
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _QtyButton(icon: Icons.add, onTap: onPlus),
                    const Spacer(),
                    IconButton(
                      onPressed: onRemove,
                      icon: const Icon(Icons.delete_outline),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            const Text(
              "កន្ត្រកទទេ 😅",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              "សូមជ្រើសរើសផលិតផល បន្ថែមចូលកន្ត្រក",
              style: TextStyle(color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBox({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text("សាកម្តងទៀត"),
            ),
          ],
        ),
      ),
    );
  }
}

String _fmt(double v) => v < 1 ? v.toStringAsFixed(2) : v.toStringAsFixed(0);
