import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../app_theme.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  static const String adminEmail = 'admin@ocadoacai.com'; 

  Stream<QuerySnapshot> _pedidosStream() {
    return FirebaseFirestore.instance
        .collection('pedidos')
        .orderBy('criadoEm', descending: true)
        .snapshots();
  }

  Future<void> _sair(BuildContext context) async {
    final authService = GetIt.instance<AuthService>();
    await authService.signOut();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel Admin — Pedidos'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () => _sair(context),
          ),
        ],
      ),
      backgroundColor: AppTheme.backgroundLight,
      body: StreamBuilder<QuerySnapshot>(
        stream: _pedidosStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.primaryColor),
                  SizedBox(height: 16),
                  Text('Carregando pedidos...'),
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
                      'Erro ao carregar pedidos.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum pedido recebido ainda.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              return _PedidoCard(pedidoId: doc.id, data: data);
            },
          );
        },
      ),
    );
  }
}

class _PedidoCard extends StatefulWidget {
  final String pedidoId;
  final Map<String, dynamic> data;

  const _PedidoCard({required this.pedidoId, required this.data});

  @override
  State<_PedidoCard> createState() => _PedidoCardState();
}

class _PedidoCardState extends State<_PedidoCard> {
  late String _status;
  bool _atualizando = false;


  static const List<String> _statusOpcoes = [
    'recebido',
    'em preparo',
    'pronto',
    'finalizado',
  ];

  @override
  void initState() {
    super.initState();
    _status = widget.data['status'] as String? ?? 'recebido';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'em preparo':
        return Colors.orange;
      case 'pronto':
        return AppTheme.successColor;
      case 'finalizado':
        return Colors.blueGrey; 
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'em preparo':
        return Icons.restaurant;
      case 'pronto':
        return Icons.check_circle;
      case 'finalizado':
        return Icons.task_alt; 
      default:
        return Icons.inbox;
    }
  }

  Future<void> _alterarStatus(String novoStatus) async {
    setState(() => _atualizando = true);

    try {
      await FirebaseFirestore.instance
          .collection('pedidos')
          .doc(widget.pedidoId)
          .update({'status': novoStatus});

      setState(() => _status = novoStatus);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('Status atualizado para "$novoStatus"'),
            ],
          ),
          backgroundColor: novoStatus == 'finalizado'
              ? Colors.blueGrey
              : AppTheme.successColor,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao atualizar status. Tente novamente.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _atualizando = false);
    }
  }

  void _mostrarDialogStatus() {
    // Se já finalizado, não permite mais alteração
    if (_status == 'finalizado') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.lock, color: Colors.white),
              SizedBox(width: 8),
              Text('Pedido finalizado não pode ser alterado.'),
            ],
          ),
          backgroundColor: Colors.blueGrey,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.edit, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Alterar Status'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _statusOpcoes.map((opcao) {
            final selecionado = opcao == _status;
            return ListTile(
              leading: Icon(
                _statusIcon(opcao),
                color: _statusColor(opcao),
              ),
              title: Text(
                opcao.toUpperCase(),
                style: TextStyle(
                  fontWeight:
                      selecionado ? FontWeight.bold : FontWeight.normal,
                  color: _statusColor(opcao),
                ),
              ),
              subtitle: opcao == 'finalizado'
                  ? const Text(
                      'Pedido entregue — não poderá ser alterado',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    )
                  : null,
              trailing: selecionado
                  ? const Icon(Icons.check, color: AppTheme.successColor)
                  : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              tileColor: selecionado
                  ? _statusColor(opcao).withValues(alpha: 0.08)
                  : null,
              onTap: () {
                Navigator.pop(ctx);
                if (opcao != _status) _alterarStatus(opcao);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  String _formatarData(Timestamp? ts) {
    if (ts == null) return '—';
    final dt = ts.toDate();
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}  '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final itens =
        List<Map<String, dynamic>>.from(widget.data['itens'] ?? []);
    final total = (widget.data['total'] as num?)?.toDouble() ?? 0.0;
    final email = widget.data['userEmail'] as String? ?? '—';
    final criadoEm = widget.data['criadoEm'] as Timestamp?;
    final finalizado = _status == 'finalizado';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      // Card levemente acinzentado quando finalizado
      color: finalizado ? Colors.grey.shade100 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cabeçalho ──────────────────────────────────────
            Row(
              children: [
                Icon(
                  Icons.receipt_outlined,
                  color: finalizado ? Colors.grey : AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Pedido #${widget.pedidoId.substring(0, 8).toUpperCase()}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: finalizado
                          ? Colors.grey
                          : AppTheme.primaryColor,
                    ),
                  ),
                ),
                // Badge clicável (bloqueado se finalizado)
                GestureDetector(
                  onTap: _mostrarDialogStatus,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          _statusColor(_status).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: _statusColor(_status)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_atualizando)
                          const SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: AppTheme.primaryColor,
                            ),
                          )
                        else
                          Text(
                            _status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _statusColor(_status),
                            ),
                          ),
                        const SizedBox(width: 4),
                        Icon(
                          finalizado ? Icons.lock : Icons.edit,
                          size: 11,
                          color: _statusColor(_status),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ── E-mail e data ──────────────────────────────────
            Row(
              children: [
                const Icon(Icons.person_outline,
                    size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    email,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.access_time,
                    size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  _formatarData(criadoEm),
                  style: const TextStyle(
                      fontSize: 13, color: Colors.grey),
                ),
              ],
            ),

            const Divider(height: 20),

            // ── Itens ──────────────────────────────────────────
            ...itens.map((item) {
              final nome = item['nome'] as String? ?? '—';
              final qtd = item['quantidade'] as int? ?? 1;
              final subtotal =
                  (item['subtotal'] as num?)?.toDouble() ?? 0.0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: finalizado
                            ? Colors.grey.withValues(alpha: 0.25)
                            : AppTheme.secondaryColor
                                .withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          '$qtd',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: finalizado
                                ? Colors.grey
                                : AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(nome,
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                finalizado ? Colors.grey : Colors.black,
                          )),
                    ),
                    Text(
                      'R\$ ${subtotal.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: finalizado ? Colors.grey : Colors.black,
                      ),
                    ),
                  ],
                ),
              );
            }),

            const Divider(height: 20),

            // ── Total ──────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total do Pedido',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: finalizado ? Colors.grey : Colors.black,
                  ),
                ),
                Text(
                  'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: finalizado
                        ? Colors.grey
                        : AppTheme.primaryColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Botão alterar status ───────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed:
                    (_atualizando || finalizado) ? null : _mostrarDialogStatus,
                icon: Icon(
                  finalizado ? Icons.lock : Icons.edit,
                  size: 16,
                ),
                label: Text(
                  _atualizando
                      ? 'Atualizando...'
                      : finalizado
                          ? 'Pedido Finalizado'
                          : 'Alterar Status do Pedido',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      finalizado ? Colors.grey : AppTheme.primaryColor,
                  side: BorderSide(
                      color: finalizado
                          ? Colors.grey
                          : AppTheme.primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}