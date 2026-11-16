
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (SupabaseConfig.supabaseUrl.isNotEmpty &&
      SupabaseConfig.supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  }

  runApp(const BmarketApp());
}

class BmarketApp extends StatelessWidget {
  const BmarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bmarket',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class Product {
  final String name;
  final String category;
  final int price;
  final IconData icon;
  final String description;

  const Product({
    required this.name,
    required this.category,
    required this.price,
    required this.icon,
    required this.description,
  });
}

String rupiah(int value) {
  return 'Rp${value.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => '.',
  )}';
}

const products = [
  Product(
    name: 'Smartphone Android',
    category: 'Elektronik',
    price: 1500000,
    icon: Icons.phone_android,
    description: 'Smartphone Android untuk kebutuhan sehari-hari.',
  ),
  Product(
    name: 'Headphone Bluetooth',
    category: 'Elektronik',
    price: 150000,
    icon: Icons.headphones,
    description: 'Headphone wireless dengan desain modern.',
  ),
  Product(
    name: 'Kaos Pria Premium',
    category: 'Fashion',
    price: 85000,
    icon: Icons.checkroom,
    description: 'Kaos nyaman untuk aktivitas sehari-hari.',
  ),
  Product(
    name: 'Tas Fashion',
    category: 'Fashion',
    price: 125000,
    icon: Icons.shopping_bag,
    description: 'Tas dengan desain simpel dan elegan.',
  ),
  Product(
    name: 'Peralatan Rumah',
    category: 'Rumah Tangga',
    price: 75000,
    icon: Icons.chair,
    description: 'Peralatan rumah tangga praktis.',
  ),
  Product(
    name: 'Skincare',
    category: 'Kecantikan',
    price: 55000,
    icon: Icons.face,
    description: 'Produk perawatan kecantikan.',
  ),
  Product(
    name: 'Paket Makanan',
    category: 'Makanan',
    price: 35000,
    icon: Icons.fastfood,
    description: 'Pilihan makanan untuk kebutuhan harian.',
  ),
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchController =
      TextEditingController();

  final List<Product> cart = [];

  String selectedCategory = 'Semua';

  List<Product> get filteredProducts {
    return products.where((product) {
      final categoryMatch = selectedCategory == 'Semua' ||
          product.category == selectedCategory;

      final searchMatch = product.name.toLowerCase().contains(
            searchController.text.toLowerCase(),
          );

      return categoryMatch && searchMatch;
    }).toList();
  }

  void addToCart(Product product) {
    setState(() {
      cart.add(product);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} ditambahkan ke keranjang'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CartPage(
          cart: cart,
          onRemove: (product) {
            setState(() {
              cart.remove(product);
            });
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      'Semua',
      'Elektronik',
      'Fashion',
      'Rumah Tangga',
      'Kecantikan',
      'Makanan',
      'Lainnya',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bmarket',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: openCart,
            icon: Badge(
              label: Text('${cart.length}'),
              isLabelVisible: cart.isNotEmpty,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur akun segera diaktifkan.'),
                ),
              );
            },
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Cari produk di Bmarket',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  searchController.clear();
                  setState(() {});
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang di Bmarket!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Belanja mudah, praktis dan nyaman.',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Kategori Produk',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((category) {
              return ChoiceChip(
                label: Text(category),
                selected: selectedCategory == category,
                onSelected: (_) {
                  setState(() {
                    selectedCategory = category;
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          Text(
            selectedCategory == 'Semua'
                ? 'Produk Pilihan'
                : 'Kategori: $selectedCategory',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          if (filteredProducts.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Produk tidak ditemukan.'),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredProducts.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.78,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final product = filteredProducts[index];

                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailPage(
                          product: product,
                          onAdd: () => addToCart(product),
                        ),
                      ),
                    );
                  },
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Center(
                              child: Icon(
                                product.icon,
                                size: 65,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            rupiah(product.price),
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Lihat detail',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class ProductDetailPage extends StatelessWidget {
  final Product product;
  final VoidCallback onAdd;

  const ProductDetailPage({
    super.key,
    required this.product,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Produk')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(
                child: Icon(
                  product.icon,
                  size: 130,
                  color: Colors.blue,
                ),
              ),
            ),
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              rupiah(product.price),
              style: const TextStyle(
                fontSize: 22,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(product.description),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                onAdd();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Tambah ke Keranjang'),
            ),
          ],
        ),
      ),
    );
  }
}

class CartPage extends StatefulWidget {
  final List<Product> cart;
  final ValueChanged<Product> onRemove;

  const CartPage({
    super.key,
    required this.cart,
    required this.onRemove,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    final total = widget.cart.fold<int>(
      0,
      (sum, product) => sum + product.price,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang Belanja')),
      body: widget.cart.isEmpty
          ? const Center(
              child: Text('Keranjang masih kosong.'),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...widget.cart.map((product) {
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        product.icon,
                        color: Colors.blue,
                        size: 35,
                      ),
                      title: Text(product.name),
                      subtitle: Text(rupiah(product.price)),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          widget.onRemove(product);
                          setState(() {});
                        },
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),
                Text(
                  'Total: ${rupiah(total)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Checkout akan diaktifkan pada tahap berikutnya.',
                        ),
                      ),
                    );
                  },
                  child: const Text('Lanjut Checkout'),
                ),
              ],
            ),
    );
  }
}
