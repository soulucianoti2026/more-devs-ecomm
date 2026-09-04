import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/home/models/category_model.dart';
import 'package:more_devs_do_zero/features/home/widgets/category_card.dart';
import 'package:more_devs_do_zero/features/home/controllers/home_controller.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({
    super.key,
    required this.categories,
    required this.state,
  });

  final List<Category> categories;
  final CategoriesViewState state;

  @override
  Widget build(BuildContext context) {
    // Mudamos o switch para retornar a estrutura correta baseada no estado
    return switch (state) {
      CategoriesViewState.error => const SizedBox(
        height: 150,
        child: Center(child: Text('Problema ao resgatar categorias.')),
      ),
      _ => Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Alinha o título à esquerda da tela
        mainAxisSize: MainAxisSize.min,
        children: [
          // ---- TÍTULO "CATEGORIAS" ADICIONADO AQUI ----
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 12.0, bottom: 8.0),

            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Categorias',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700, // Estilo negrito destacado
                    color: Colors.black87,
                  ),
                ),
                SizedBox(width: 4), // Pequeno espaço entre o texto e o ícone
                Icon(
                  Icons.chevron_right, // Ícone do chevron virado para a direita
                  color: Colors.black, // Cor preta conforme solicitado
                  size: 20, // Tamanho proporcional ao texto
                ),
              ],
            ),
          ),

          // Sua lista original de círculos/cards encapsulada
          SizedBox(
            height:
                120, // Ajustado ligeiramente para acomodar o texto sem estourar o layout
            child: Skeletonizer(
              enabled: state == CategoriesViewState.loading,
              child: ListView.builder(
                itemCount: getCategoriesList().length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  Category category = getCategoriesList()[index];
                  return CategoryCard(category: category);
                },
              ),
            ),
          ),
        ],
      ),
    };
  }

  List<Category> getCategoriesList() {
    return state == CategoriesViewState.loading
        ? [
            Category(name: 'asdhasda', imageUrl: ''),
            Category(name: 'asdhasda', imageUrl: ''),
            Category(name: 'asdhasda', imageUrl: ''),
            Category(name: 'asdhasda', imageUrl: ''),
          ]
        : categories;
  }
}
