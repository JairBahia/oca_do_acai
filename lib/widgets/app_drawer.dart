import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../screens/about_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/menu_screen.dart';
import '../services/cart_service.dart';
import 'package:get_it/get_it.dart';
import '../screens/login_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final cartService = GetIt.instance<CartService>();

    return Drawer(
      child: Column(
        children: [
          // ── Cabeçalho ─────────────────────────
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo / imagem do estabelecimento
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.local_dining,
                          color: Colors.white,
                          size: 36,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Oca do Açaí',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Cardápio Digital',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // ── Itens de Navegação ──────────────────────────────────
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _DrawerItem(
                  icon: Icons.restaurant_menu,
                  label: 'Cardápio',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MenuScreen()),
                      (route) => false,
                    );
                  },
                ),
                // Carrinho de quantidade
                ListenableBuilder(
                  listenable: cartService,
                  builder: (context, _) {
                    return ListTile(
                      leading: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(Icons.shopping_cart,
                              color: AppTheme.primaryColor),
                          if (cartService.totalQuantity > 0)
                            Positioned(
                              right: -6,
                              top: -6,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: AppTheme.secondaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${cartService.totalQuantity}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: const Text('Meu Carrinho'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CartScreen()),
                        );
                      },
                    );
                  },
                ),
                const Divider(),
                _DrawerItem(
                  icon: Icons.info_outline,
                  label: 'Sobre',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AboutScreen()),
                    );
                  },
                ),
              ],
            ),
          ),

                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Sair',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false, 
                      );
                    },
                  ),
                  
          // ── Rodapé ─────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'v1.0.0',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget auxiliar para itens do Drawer
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(label),
      onTap: onTap,
    );
  }
}
