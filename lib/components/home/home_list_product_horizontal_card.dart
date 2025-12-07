import 'package:flutter/material.dart';
import 'package:project_flutter_khmer25/models/product_model.dart';

/*
 * List ផលិតផលរាង horizontal
 * ប្រើនៅ HomePage សម្រាប់ផលិតផលថ្មីៗ / បញ្ចុះតម្លៃ 
 */
class ProductHorizontalList extends StatefulWidget {
  final List<Product> products;

  const ProductHorizontalList({super.key, required this.products});

  @override
  State<ProductHorizontalList> createState() => _ProductHorizontalListState();
}

class _ProductHorizontalListState extends State<ProductHorizontalList> {
  @override
  Widget build(BuildContext context) {
    final products = widget.products;

    return SizedBox(
      height: 243,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final p = products[index];
          return SizedBox(
            width: 160,
            child: GestureDetector(
              onTap: () {
                // navigate to product detail
              },
              child: Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(p.imageUrl, fit: BoxFit.cover),
                          ),
                          if (p.discountPercent != null)
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '-${p.discountPercent!.toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.nameKm,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: const TextStyle(fontSize: 15),
                          ),

                          // Text(
                          //   p.nameKm,
                          //   maxLines: 2,
                          //   overflow: TextOverflow.ellipsis,
                          // ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\$${p.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  //  add to cart
                                },
                                iconSize: 18,
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(Icons.add_shopping_cart),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
