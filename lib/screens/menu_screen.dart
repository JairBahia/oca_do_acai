// RF005 – Visualizar Cardápio | RF006 – Adicionar Item ao Pedido
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../app_theme.dart';
import '../data/menu_data.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../widgets/app_drawer.dart';
import 'cart_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CartService _cartService = GetIt.instance<CartService>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: MenuData.categories.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // RF006: adiciona item ao carrinho e exibe feedback
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
          // Ícone do carrinho
          ListenableBuilder(
            listenable: _cartService,
            builder: (context, _) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CartScreen()),
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
        // TabBar de categorias dentro do AppBar
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          indicatorColor: AppTheme.secondaryColor,
          indicatorWeight: 3,
          tabs: MenuData.categories
              .map((cat) => Tab(text: cat))
              .toList(),
        ),
      ),
      drawer: const AppDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: MenuData.categories
            .map((cat) => _CategoryTab(
                  category: cat,
                  onAddToCart: _addToCart,
                ))
            .toList(),
      ),
    );
  }
}

// ─── Aba de uma categoria ─────────────────────────────────────────────────────
class _CategoryTab extends StatelessWidget {
  final String category;
  final void Function(Product) onAddToCart;

  const _CategoryTab({
    required this.category,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final products = MenuData.byCategory(category);

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

// ─── Card de produto ──────────────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;

  const _ProductCard({
    required this.product,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem do produto
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _ProductImage(imagePath: product.imagePath),
            ),
            const SizedBox(width: 12),

            // Informações (nome, descrição, preço)
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
                      color: Colors.grey,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Preço
                      Text(
                        'R\$ ${product.price.toStringAsFixed(2).replaceAll('.', ',')}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      // Botão adicionar
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

// ─── Imagem do produto ──────────────────────────────────────────
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
