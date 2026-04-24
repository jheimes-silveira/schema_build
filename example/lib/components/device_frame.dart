import 'package:flutter/material.dart';

/// Um frame de dispositivo (telefone) reutilizável para envolver previews.
class DeviceFrame extends StatelessWidget {
  final Widget child;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;

  const DeviceFrame({
    super.key,
    required this.child,
    this.bottomNavigationBar,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Tenta ocupar 95% da altura disponível, mantendo a proporção de um smartphone
        final phoneHeight = constraints.maxHeight * 0.95;
        final phoneWidth = phoneHeight * 0.48;

        return Center(
          child: Container(
            width: phoneWidth,
            height: phoneHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(36),
              border: Border.all(color: const Color(0xFF1A1A1A), width: 8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Column(
                children: [
                  // Barra de status simulada
                  const _StatusBar(),

                  // Área de conteúdo
                  Expanded(
                    child: Container(
                      color: backgroundColor ?? Colors.white,
                      child: child,
                    ),
                  ),

                  // Barra de navegação inferior (se houver)
                  ?bottomNavigationBar,
                  
                  // Indicador de "home" (barra inferior do iOS-style)
                  Container(
                    height: 12,
                    width: double.infinity,
                    color: backgroundColor ?? Colors.white,
                    alignment: Alignment.center,
                    child: Container(
                      width: 100,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      color: const Color(0xFFF8F8F8),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Text(
            '9:41',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          const Icon(Icons.signal_cellular_4_bar, size: 14, color: Colors.black87),
          const SizedBox(width: 4),
          const Icon(Icons.wifi, size: 14, color: Colors.black87),
          const SizedBox(width: 4),
          const Icon(Icons.battery_full, size: 14, color: Colors.black87),
        ],
      ),
    );
  }
}
