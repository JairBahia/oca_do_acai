import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../app_theme.dart';
import '../services/cart_service.dart';
import '../services/firestore_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = GetIt.instance<CartService>();
  final FirestoreService _firestoreService = GetIt.instance<FirestoreService>();
  bool _isLoading = false;

  Future<void> _finalizarPedido() async {
    if (_cartService.items.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // 1. Transforma os itens do carrinho em um formato que o Firebase entende
      final itensMap = _cartService.items.values.map((cartItem) {
        return {
          'produtoId': cartItem.product.id,
          'nome': cartItem.product.name,
          'quantidade': cartItem.quantity,
          'precoUnitario': cartItem.product.price,
          'subtotal': cartItem.product.price * cartItem.quantity,
        };
      }).toList();

      // 2. Dispara a gravação para o Firestore
      await _firestoreService.salvarPedido(
        itens: itensMap,
        total: _cartService.totalAmount,
      );

      // 3. Esvazia o carrinho após o sucesso
      _cartService.clear();

      if (!mounted) return;
      
      // 4. Mostra o comprovante
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.successColor),
              SizedBox(width: 8),
              Text('Pedido Confirmado!'),
            ],
          ),
          content: const Text('Seu pedido foi enviado para a lanchonete com sucesso. Logo ele estará pronto!'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o dialog
                Navigator.of(context).pop(); // Volta pro cardápio principal
              },
              child: const Text('Voltar ao Cardápio'),
            ),
          ],
        ),
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao enviar pedido. Verifique sua conexão e tente novamente.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Carrinho'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              if (_cartService.items.isEmpty) return;
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Esvaziar carrinho?'),
                  content: const Text('Tem certeza que deseja remover todos os itens?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        _cartService.clear();
                        Navigator.pop(ctx);
                      },
                      child: const Text('Esvaziar', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: ListenableBuilder(
        listenable: _cartService,
        builder: (context, _) {
          if (_cartService.items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.remove_shopping_cart, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Seu carrinho está vazio', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _cartService.items.length,
                  itemBuilder: (context, index) {
                    final cartItem = _cartService.items.values.toList()[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppTheme.secondaryColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  cartItem.product.imagePath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.fastfood, color: AppTheme.primaryColor),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(cartItem.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(
                                    'R\$ ${cartItem.product.price.toStringAsFixed(2).replaceAll('.', ',')}',
                                    style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                  onPressed: () => _cartService.removeItem(cartItem.product.id),
                                ),
                                Text('${cartItem.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, color: AppTheme.successColor),
                                  onPressed: () => _cartService.addItem(cartItem.product),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))
                  ],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total do Pedido', style: TextStyle(fontSize: 16, color: Colors.grey)),
                          Text(
                            'R\$ ${_cartService.totalAmount.toStringAsFixed(2).replaceAll('.', ',')}',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _finalizarPedido,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppTheme.successColor,
                          ),
                          child: _isLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Finalizar Pedido', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}