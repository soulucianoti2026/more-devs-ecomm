import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/home/controllers/products_by_category_controller.dart';
import 'package:more_devs_do_zero/features/home/widgets/product_card.dart';
import 'package:provider/provider.dart';
import 'package:more_devs_do_zero/features/home/pages/home_page.dart';
import 'package:more_devs_do_zero/shared/app_text_style.dart';
import 'package:more_devs_do_zero/shared/widgets/app_text_field.dart';

class ProductsByCategoryPage extends StatefulWidget {
  const ProductsByCategoryPage({super.key, required this.categoryName});

  @override
  State<ProductsByCategoryPage> createState() => _ProductsByCategoryPageState();

  static const String route = '/products-by-category';

  final String categoryName;
}

class _ProductsByCategoryPageState extends State<ProductsByCategoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsByCategoryController>().getProductsByCategory(
        widget.categoryName,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamed(context, HomePage.route);
          },
          icon: const Icon(Icons.arrow_back),
        ),

        centerTitle: true,
        title: Text(
          widget.categoryName,
          style: AppTextStyle.titleProductByCategory,
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
<<<<<<< Updated upstream
      body: Consumer<ProductsByCategoryController>(
        builder: (context, controller, child) {
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(hintText: 'Insira o nome do fabricante.'),
                      const SizedBox(height: 12),
                      AppTextField(hintText: 'Insira o nome do produto.'),
                      const SizedBox(height: 16),
                    ],
=======
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AppTextField(
              hintText: 'Buscar produtos',
              prefixIcon: const Icon(Icons.search),
              onChanged: (value) {
                context.read<ProductsByCategoryController>().searchProducts(
                  value,
                );
              },
            ),

            SizedBox(
              height: 12,
            ), // Adicionei um SizedBox para espaçamento entre os campos de pesquisa
            AppTextField(
              hintText: 'Pesquisar Marcas ou produtores.',
              onChanged: (value) {
                // Lógica de pesquisa aqui
              },
            ), //Apptextfield para pesquisar marcas ou produtores.
            const SizedBox(
              height: 12, //Espaçamento entre para o grid.
            ),

            // 3. O Skeletonizer e GridView encapsulados em um Expanded
            Expanded(
              child: Skeletonizer(
                enabled: isLoading,
                child: GridView.builder(
                  // Ajustado para zero porque o Padding externo da Column já cuida das laterais
                  padding: EdgeInsets.zero,
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 colunas
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio:
                        0.62, // proporção largura/altura da célula
>>>>>>> Stashed changes
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => ProductCard(
                      product: controller.categoryProducts[index],
                    ),
                    childCount: controller.categoryProducts.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.68,
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
