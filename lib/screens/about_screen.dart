// RF004 – Sobre
import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../widgets/app_drawer.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre'),
      ),
      drawer: const AppDrawer(),
      backgroundColor: AppTheme.backgroundLight,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Logo do App ───────────────────────────────────────
          Center(
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(55),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_dining,
                color: Colors.white,
                size: 56,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Oca do Açaí',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          const Center(
            child: Text(
              'Cardápio Digital',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),

          const SizedBox(height: 28),

          // ── Objetivo do Aplicativo ─────────────────────────────
          const _SectionCard(
            icon: Icons.info_outline,
            title: 'Objetivo do Aplicativo',
            child: Text(
              'Este aplicativo foi desenvolvido para digitalizar o cardápio da Oca do Açaí, '
              'permitindo que os clientes visualizem os produtos disponíveis e realizem '
              'pedidos de forma prática e intuitiva, diretamente pelo celular.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ),

          const SizedBox(height: 16),

          // ── Informações do Estabelecimento ────────────────────
          const _SectionCard(
            icon: Icons.store_outlined,
            title: 'Estabelecimento',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(label: 'Nome:', value: 'Oca do Açaí'),
                _InfoRow(label: 'Segmento:', value: 'Lanchonete / Casa de Açaí'),
                _InfoRow(
                  label: 'Produtos:',
                  value:
                      'Açaí, Tapiocas, Lanches, Hamburguer, Sucos, Marmitas Fitness e mais',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Equipe de Desenvolvimento ─────────────────────────
          const _SectionCard(
            icon: Icons.group_outlined,
            title: 'Equipe de Desenvolvimento',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                _InfoRow(label: 'Integrante 1:', value: 'Jair Henrique De Castro Leão'),
                _InfoRow(label: 'Integrante 2:', value: 'Miguel Lemos Nacarato'),
                _InfoRow(label: 'Repositório:', value: 'https://github.com/JairBahia/oca_do_acai.git'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Informações Acadêmicas ────────────────────────────
          const _SectionCard(
            icon: Icons.school_outlined,
            title: 'Informações Acadêmicas',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(
                    label: 'Disciplina:',
                    value: 'Prática Extensionista VIII'),
                _InfoRow(label: 'Professor:', value: 'Prof. Dr. Rodrigo Plotze'),
                _InfoRow(
                  label: 'Instituição:',
                  value: 'UNAERP',
                ),
                _InfoRow(label: 'Versão:', value: '1.0.0'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Tecnologias ───────────────────────────────────────
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.secondaryColor),
              ),
              child: const Text(
                'Desenvolvido com Flutter & Dart',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor, size: 22),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const Divider(),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
