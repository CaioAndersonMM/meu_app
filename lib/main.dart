import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meu_app/controllers/produto_controller.dart';
import 'package:meu_app/controllers/comida_controller.dart';
import 'package:meu_app/controllers/evento_controller.dart';
import 'package:meu_app/models/product_item.dart';
import 'package:meu_app/pages/desejosPage.dart';
import 'package:meu_app/pages/interessesPage.dart';
import 'package:meu_app/pages/user_profile.dart';
import 'package:meu_app/widgets/caixa_pesquisa.dart';
import 'package:meu_app/widgets/header_products.dart';
import 'package:meu_app/widgets/menu_cidades.dart';
import 'package:meu_app/widgets/type_item.dart';
import 'package:meu_app/widgets/product_widget.dart';
import 'pages/comidasPage.dart';
import 'pages/produtosPage.dart';
import 'pages/eventosPage.dart';
import 'controllers/my_home_page_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Get.put(MyHomePageController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      initialRoute: '/home',
      getPages: [
        GetPage(name: '/home', page: () => MyHomePage()),
        GetPage(name: '/userProfile', page: () => const UserProfilePage()),
        GetPage(name: '/desejo', page: () => DesejosPage()),
        GetPage(name: '/interesses', page: () => InteressesPage()),
      ],
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  final MyHomePageController controller = Get.put(MyHomePageController());
  final ProdutosController controllerProduto = Get.put(ProdutosController());
  final ComidasController controllerComida = Get.put(ComidasController());
  final EventosController controllerEvento = Get.put(EventosController());

  Future<void> showProductForm(String imageUrl) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    String selectedType = 'Produto'; // Valor padrão

    await showDialog<void>(
      context: Get.context!,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(
                        // Ajusta o padding inferior quando o teclado é mostrado
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        // Define um tamanho mínimo para evitar quebra
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height * 0.7,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            const Text(
                              'Adicionar Produto',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            // Preview da imagem capturada
                            if (imageUrl.isNotEmpty)
                              Container(
                                height: 150,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: FileImage(File(imageUrl)),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: 'Nome do Produto',
                              ),
                            ),
                            TextField(
                              controller: locationController,
                              decoration: const InputDecoration(
                                labelText: 'Estabelecimento',
                              ),
                            ),
                            TextField(
                              controller: priceController,
                              decoration: const InputDecoration(
                                labelText: 'Preço',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            TextField(
                              controller: descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Descrição',
                              ),
                            ),
                            DropdownButton<String>(
                              value: selectedType,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedType = newValue ?? 'Comida';
                                });
                              },
                              items: <String>[
                                'Comida',
                                'Produto',
                                'Evento'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    double price =
                                        double.tryParse(priceController.text) ??
                                            0.0;

                                    ProductItem product = ProductItem(
                                      name: nameController.text,
                                      imageUrl: imageUrl,
                                      location: locationController.text,
                                      price: price,
                                      type: selectedType,
                                    );

                                    if (selectedType == 'Comida') {
                                      controllerComida.addProduct(product);
                                    } else if (selectedType == 'Produto') {
                                      controllerProduto.addProduct(product);
                                    } else if (selectedType == 'Evento') {
                                      controllerEvento.addEvent(product);
                                    }

                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Adicionar'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String appPath = appDir.path;
      final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final String newFilePath = '$appPath/$fileName.png';

      // Salva a imagem no diretório do app
      final File savedImage = await File(pickedFile.path).copy(newFilePath);

      // Armazena a URL do arquivo salvo no controlador (ou use onde precisar)
      controller.imagePath.value = savedImage.path;

      // Aqui você pode navegar para a página de criação de produto, por exemplo
      Get.snackbar('Foto Capturada', 'A imagem foi salva com sucesso!');

      // Chama o método para mostrar o formulário de adição do produto
      await showProductForm(savedImage.path);
    } else {
      Get.snackbar('Erro', 'Nenhuma imagem foi capturada.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Promoapp',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(0, 12, 36, 1),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Get.toNamed('/userProfile', arguments: controller.dadosUsuario);
            },
          ),
        ],
      ),
      drawer: MenuCidades(
        onCitySelected: (newCity) {
          controller.updateSelectedCity(newCity);
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            Obx(() => Text(
                  'Cidade Selecionada: ${controller.selectedCity}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )),
            const SizedBox(height: 20),
            Wrap(
              spacing: 20.0,
              runSpacing: 10.0,
              children: <Widget>[
                TypeItem(name: 'Comidas', destinationPage: ComidasPage()),
                const TypeItem(
                    name: 'Produtos', destinationPage: ProdutosPage()),
                const TypeItem(name: 'Eventos', destinationPage: EventosPage()),
              ],
            ),
            const SizedBox(height: 25),
            caixaPesquisa('Pesquisar produtos, lojas, promoções...'),
            const SizedBox(height: 5),
            headerProducts(),
            Expanded(
              child: Obx(() {
                if (controller.filteredProducts.isEmpty) {
                  return const Center(
                      child: Text('Nenhum produto disponível',
                          style: TextStyle(color: Colors.white)));
                }

                return SingleChildScrollView(
                  child: Wrap(
                    runSpacing: 10.0,
                    children: controller.filteredProducts.map((product) {
                      return ProductWidget(product: product);
                    }).toList(),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      backgroundColor: const Color.fromRGBO(0, 12, 36, 1),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Início',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outline),
                label: 'Publicar',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_basket),
                label: 'Desejos',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.star),
                label: 'Interesses',
              ),
            ],
            currentIndex: controller.selectedIndex.value,
            selectedItemColor: const Color.fromARGB(
                255, 3, 26, 102), // Cor dos itens selecionados
            unselectedItemColor: const Color.fromARGB(255, 70, 142, 167),
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 3, 26, 102),
            ),
            unselectedLabelStyle: const TextStyle(
              color: Color.fromARGB(255, 70, 142, 167),
            ),
            onTap: (index) async {
              if (controller.selectedCity.value == 'Selecione uma cidade') {
                controller.showCitySelectionAlert();
              } else {
                controller.selectedIndex.value = index;
                switch (index) {
                  case 0:
                    Get.toNamed('/home'); // Navega para a tela inicial
                    break;
                  case 1:
                    await _pickImageFromCamera(); // Abre a câmera
                    break;
                  case 2:
                    Get.toNamed('/desejo'); // Navega para a tela de desejos
                    break;
                  case 3:
                    Get.toNamed(
                        '/interesses'); // Navega para a tela de interesses
                    break;
                }
              }
            },
          )),
    );
  }
}
