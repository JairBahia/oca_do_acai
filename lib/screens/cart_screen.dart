// RF007 – Visualizar Carrinho | RF008 – Remover Item | RF009 – Finalizar Pedido
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../app_theme.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';
import '../widgets/app_drawer.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartService = GetIt.instance<CartService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Carrinho'),
      ),
      drawer: const AppDrawer(),
      // ListenableBuilder reconstrói a tela sempre que o carrinho mudar (ChangeNotifier)
      body: ListenableBuilder(
        listenable: cartService,
        builder: (context, _) {
          if (cartService.isEmpty) {
            return const _EmptyCartWidget();
          }
          return _FilledCartWidget(cartService: cartService);
        },
      ),
    );
  }
}

// ─── Carrinho vazio ───────────────────────────────────────────────────────────
class _EmptyCartWidget extends StatelessWidget {
  const _EmptyCartWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined,
                size: 96, color: Colors.grey[300]),
            const SizedBox(height: 20),
            const Text(
              'Seu carrinho está vazio',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Adicione itens do cardápio\npara fazer seu pedido.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.restaurant_menu),
              label: const Text('Ver Cardápio'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Carrinho com itens ───────────────────────────────────────────────────────
class _FilledCartWidget extends StatelessWidget {
  final CartService cartService;
  const _FilledCartWidget({required this.cartService});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Lista de itens (RF007)
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            itemCount: cartService.items.length,
            itemBuilder: (context, index) {
              final item = cartService.items[index];
              return _CartItemCard(item: item, cartService: cartService);
            },
          ),
        ),

        // Resumo e botão Finalizar (RF009)
        _OrderSummary(cartService: cartService),
      ],
    );
  }
}

// ─── Card de item no carrinho ────────────────────────────────────────────────
class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final CartService cartService;

  const _CartItemCard({required this.item, required this.cartService});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Nome e preço individual
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'R\$ ${item.product.price.toStringAsFixed(2).replaceAll('.', ',')} / unidade',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Controle de quantidade + remoção (RF008)
            Row(
              children: [
                // Botão diminuir
                _CircleIconButton(
                  icon: Icons.remove,
                  onPressed: () => cartService
                      .decreaseQuantity(item.product.id),
                ),
                // Quantidade
                Container(
                  width: 32,
                  alignment: Alignment.center,
                  child: Text(
                    '${item.quantity}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Botão aumentar
                _CircleIconButton(
                  icon: Icons.add,
                  onPressed: () =>
                      cartService.addItem(item.product),
                  color: AppTheme.primaryColor,
                ),

                const SizedBox(width: 4),

                // Botão remover completamente
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppTheme.errorColor),
                  onPressed: () =>
                      cartService.removeItem(item.product.id),
                  tooltip: 'Remover item',
                ),
              ],
            ),

            // Subtotal do item
            SizedBox(
              width: 72,
              child: Text(
                'R\$ ${item.subtotal.toStringAsFixed(2).replaceAll('.', ',')}',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Rodapé: Resumo + Finalizar ──────────────────────────────────────────────
class _OrderSummary extends StatelessWidget {
  final CartService cartService;
  const _OrderSummary({required this.cartService});

  void _finalizarPedido(BuildContext context) {
    // RF009: verifica se há itens, exibe resumo e pede confirmação
    if (cartService.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione pelo menos um item ao carrinho.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // Resumo do pedido no AlertDialog
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar Pedido'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Itens do pedido:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Lista resumida dos itens
            ...cartService.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        '${item.quantity}x ',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor),
                      ),
                      Expanded(
                        child: Text(
                          item.product.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      Text(
                        'R\$ ${item.subtotal.toStringAsFixed(2).replaceAll('.', ',')}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                )),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'R\$ ${cartService.totalPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // fecha o dialog
              _confirmarPedido(context);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _confirmarPedido(BuildContext context) {
    cartService.clear(); // limpa o carrinho

    // Mensagem de sucesso após confirmação (RF009)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Pedido realizado com sucesso! 🎉'),
          ],
        ),
        backgroundColor: AppTheme.successColor,
        duration: Duration(seconds: 3),
      ),
    );

    // Volta para a tela anterior (cardápio)
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Quantidade de itens e total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${cartService.totalQuantity} item(s)',
                style:
                    const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const Text(
                'Total do pedido:',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'R\$ ${cartService.totalPrice.toStringAsFixed(2).replaceAll('.', ',')}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Botão Finalizar Pedido
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _finalizarPedido(context),
              icon: const Icon(Icons.check),
              label: const Text('Finalizar Pedido'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Botão circular para +/- ─────────────────────────────────────────────────
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  const _CircleIconButton({
    required this.icon,
    required this.onPressed,
    this.color = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
