
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool connected = false;

  if (SupabaseConfig.supabaseUrl.isNotEmpty &&
      SupabaseConfig.supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
    connected = true;
  }

  runApp(BmarketApp(connected: connected));
}

class BmarketApp extends StatelessWidget {
  final bool connected;

  const BmarketApp({super.key, required this.connected});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bmarket',
      theme: ThemeData(
        colorSchemeSeed: Colors.deepOrange,
        useMaterial3: true,
      ),
      home: HomePage(connected: connected),
    );
  }
}

class HomePage extends StatefulWidget {
  final bool connected;

  const HomePage({super.key, required this.connected});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final searchController = TextEditingController();

  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = [];
  bool loading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    if (!widget.connected) {
      setState(() {
        loading = false;
        errorMessage = 'Supabase belum dikonfigurasi.';
      });
      return;
    }

    try {
      final result = await Supabase.instance.client
          .from('products')
          .select('id,name,seller,description,price,image_url,stock')
          .order('id', ascending: false);

      setState(() {
        products = List<Map<String, dynamic>>.from(result);
        filteredProducts = products;
        loading = false;
        errorMessage = '';
      });
    } catch (e) {
      setState(() {
        loading = false;
        errorMessage = 'Gagal mengambil produk: $e';
      });
    }
  }

  void searchProducts(String value) {
    setState(() {
      filteredProducts = products.where((product) {
        final name = (product['name'] ?? '').toString().toLowerCase();
        final seller = (product['seller'] ?? '').toString().toLowerCase();
        final query = value.toLowerCase();

        return name.contains(query) || seller.contains(query);
      }).toList();
    });
  }

  String formatPrice(dynamic price) {
    final number = double.tryParse(price.toString()) ?? 0;
    return 'Rp ${number.toStringAsFixed(0)}';
  }

  void showProduct(Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product['name']?.toString() ?? 'Produk',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  formatPrice(product['price']),
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text('Penjual: ${product['seller'] ?? '-'}'),
                const SizedBox(height: 12),
                Text(product['description']?.toString() ??
                    'Belum ada deskripsi'),
                const SizedBox(height: 12),
                Text('Stok: ${product['stock'] ?? 0}'),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bmarket',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: loadProducts,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              onChanged: searchProducts,
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(errorMessage),
                        ),
                      )
                    : filteredProducts.isEmpty
                        ? const Center(
                            child: Text('Belum ada produk tersedia'),
                          )
                        : RefreshIndicator(
                            onRefresh: loadProducts,
                            child: GridView.builder(
                              padding: const EdgeInsets.all(10),
                              itemCount: filteredProducts.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemBuilder: (context, index) {
                                final product = filteredProducts[index];
                                final imageUrl =
                                    product['image_url']?.toString() ?? '';

                                return Card(
                                  clipBehavior: Clip.antiAlias,
                                  child: InkWell(
                                    onTap: () => showProduct(product),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: imageUrl.isNotEmpty
                                                ? Image.network(
                                                    imageUrl,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return const Icon(
                                                        Icons.image,
                                                        size: 55,
                                                      );
                                                    },
                                                  )
                                                : const Icon(
                                                    Icons.shopping_bag,
                                                    size: 55,
                                                  ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(9),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product['name']?.toString() ??
                                                    'Produk',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                formatPrice(product['price']),
                                                style: const TextStyle(
                                                  color: Colors.deepOrange,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                'Penjual: ${product['seller'] ?? '-'}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
