import 'package:get/get.dart';
import 'package:meu_app/models/product_item.dart';
import 'package:meu_app/services/database.dart';

class MyHomePageController extends GetxController {
  void onInit() {
    //initState não existe aqui
    print('Iniciando MyHomePageController');
    // _addInitialProducts();
    _loadProducts();
  }

  Future<void> _clearDatabase() async {
    try {
      final dbHelper = DatabaseHelper();
      await dbHelper.clearDatabase();
      print('Banco de dados limpo!');
    } catch (e) {
      print('Erro ao limpar o banco de dados: $e');
    }
  }

  void _addInitialProducts() async {
    List<ProductItem> initialProducts = [
      ProductItem(
        name: 'Hamburguer',
        imageUrl: 'https://via.placeholder.com/50',
        location: 'Rua das Flores, 123',
        price: 12.99,
        type: 'Comida',
      ),
      ProductItem(
        name: 'Pizza',
        imageUrl: 'https://via.placeholder.com/50',
        location: 'Avenida Brasil, 456',
        price: 24.99,
        type: 'Comida',
      ),
      ProductItem(
        name: 'Sushi',
        imageUrl: 'https://via.placeholder.com/50',
        location: 'Praça da Liberdade, 789',
        price: 29.99,
        type: 'Comida',
      ),
      ProductItem(
        name: 'Cidade Junina',
        imageUrl: 'https://via.placeholder.com/50',
        location: 'Mossoró Rio Branco, 789',
        price: 9.99,
        type: 'Evento',
      ),
      ProductItem(
        name: 'Calourada Computação',
        imageUrl: 'https://via.placeholder.com/50',
        location: 'Ufersa, 789',
        price: 0.00,
        type: 'Evento',
      ),
      ProductItem(
        name: 'Monitor Gamer',
        imageUrl: 'https://via.placeholder.com/50',
        location: 'Americanas, 789',
        price: 500.00,
        type: 'Produtos',
      ),
    ];

    // Adiciona cada produto no banco de dados
    for (var product in initialProducts) {
      await _addProduct(product);
    }

    // Recarrega os produtos após a inserção
    _loadProducts();
  }

  Future<void> _addProduct(ProductItem product) async {
    try {
      final dbHelper = DatabaseHelper();
      await dbHelper
          .insertProduct(product); // Insere o produto no banco de dados
    } catch (e) {
      print('Erro ao adicionar produto: $e');
    }
  }

  Future<void> _loadProducts() async {
    try {
      final dbHelper = DatabaseHelper();
      List<ProductItem> products = await dbHelper.getProducts();
    } catch (e) {
      print('Erro ao carregar produtos: $e');
    }
  }

  var selectedCity = 'Selecione uma cidade'.obs;
  var dadosUsuario = {
    'city': 'Mossoró',
    'userName': 'Bruno',
    'postCount': 5,
    'reviewCount': 15,
    'userLevel': '2',
  }.obs;
  var selectedIndex = 0.obs;

  void updateSelectedCity(String newCity) {
    _clearDatabase(); //LEMBRAR DE TIRAR ISSO

    selectedCity.value = newCity;
    dadosUsuario['city'] = newCity;
  }

  void showCitySelectionAlert() {
    Get.defaultDialog(
      title: 'Seleção de Cidade',
      middleText:
          'Por favor, selecione uma cidade no menu esquerdo para continuar.',
      textConfirm: 'OK',
      onConfirm: () => Get.back(),
    );
  }
}
