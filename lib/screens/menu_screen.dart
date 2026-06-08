// RF005 – Visualizar Cardápio (Firestore) | RF006 – Adicionar Item ao Pedido
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../app_theme.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../services/firestore_service.dart';
import '../widgets/app_drawer.dart';
import 'cart_screen.dart';

const List<String> _kCategories = [
  'Açaí na Tigela',
  'Tapiocas',
  'Tapiocas Doces',
  'Lanches Quentes',
  'Hot Dog',
  'Hamburguer',
  'Marmitas Fitness',
  'Sucos Naturais',
  'Vitaminas e Frapês',
  'Sucos Especiais',
  'Sucos Detox',
];

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CartService _cartService = GetIt.instance<CartService>();
  final FirestoreService _firestoreService = GetIt.instance<FirestoreService>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _kCategories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addToCart(Product product) {
    _cartService.addItem(product);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${product.name} adicionado ao pedido!',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.successColor,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Ver carrinho',
          textColor: AppTheme.secondaryColor,
          onPressed: () {
            if (!mounted) return; // ← correção do erro
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CartScreen()));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oca do Açaí'),
        actions: [
          ListenableBuilder(
            listenable: _cartService,
            builder: (context, _) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    ),
                  ),
                  if (_cartService.totalQuantity > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppTheme.secondaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${_cartService.totalQuantity}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          indicatorColor: AppTheme.secondaryColor,
          indicatorWeight: 3,
          tabs: _kCategories.map((cat) => Tab(text: cat)).toList(),
        ),
      ),
      drawer: const AppDrawer(),
      body: StreamBuilder<List<Product>>(
        stream: _firestoreService.cardapioStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.primaryColor),
                  SizedBox(height: 16),
                  Text('Carregando cardápio...'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off,
                        size: 64, color: AppTheme.errorColor),
                    const SizedBox(height: 16),
                    const Text(
                      'Erro ao carregar o cardápio.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          }

          final allProducts = snapshot.data ?? [];
          if (allProducts.isEmpty) {
            return const Center(
              child: Text('Nenhum produto encontrado no cardápio.'),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: _kCategories.map((cat) {
              final products =
                  allProducts.where((p) => p.category == cat).toList();
              return _CategoryTab(
                category: cat,
                products: products,
                onAddToCart: _addToCart,
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  final String category;
  final List<Product> products;
  final void Function(Product) onAddToCart;

  const _CategoryTab({
    required this.category,
    required this.products,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Center(child: Text('Nenhum item disponível.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _ProductCard(
          product: product,
          onAddToCart: () => onAddToCart(product),
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;

  const _ProductCard({required this.product, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _ProductImage(imagePath: product.imagePath),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'R\$ ${product.price.toStringAsFixed(2).replaceAll('.', ',')}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: onAddToCart,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          textStyle: const TextStyle(fontSize: 12),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Adicionar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String imagePath;
  const _ProductImage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      color: AppTheme.secondaryColor.withValues(alpha: 0.2),
      child: Image.asset(
        imagePath,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.fastfood, color: AppTheme.primaryColor, size: 36),
        ),
      ),
    );
  }
}