import 'dart:async';

class TestRepository {
  /// Simula uma chamada HTTPS com delay de 500ms.
  /// Retorna dados fictícios para popular os componentes.
  Future<Map<String, dynamic>> test() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return {
      'title': 'Smartphone Ultra Pro',
      'subtitle': 'O melhor desempenho do mercado com a nova tecnologia 5G.',
      'imageUrl': 'https://picsum.photos/800/400?random=1',
      'buttonText': 'COMPRAR AGORA',
      'price': 'R\$ 4.599,00',
      'items': [
        {
          'title': 'Câmera 108MP',
          'description': 'Fotos incríveis em qualquer luz.',
          'imageUrl': 'https://picsum.photos/100/100?random=2',
        },
        {
          'title': 'Bateria 5000mAh',
          'description': 'Dura o dia todo com uso intenso.',
          'imageUrl': 'https://picsum.photos/100/100?random=3',
        },
        {
          'title': 'Tela AMOLED 120Hz',
          'description': 'Fluidez total para jogos e vídeos.',
          'imageUrl': 'https://picsum.photos/100/100?random=4',
        },
      ],
    };
  }
}
