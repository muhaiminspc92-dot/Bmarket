import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

final supabase = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

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
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const AuthGate(),
    );
  }
}

// ========================================
// AUTH GATE
// ========================================

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session =
            snapshot.data?.session ?? supabase.auth.currentSession;

        if (session == null) {
          return const LoginPage();
        }

        return const ProductPage();
      },
    );
  }
}

// ========================================
// LOGIN DAN REGISTER
// ========================================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isRegister = false;
  bool loading = false;
  bool obscurePassword = true;

  Future<void> authenticate() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showMessage('Email dan password wajib diisi');
      return;
    }

    if (!email.contains('@')) {
      showMessage('Format email tidak valid');
      return;
    }

    if (password.length < 6) {
      showMessage('Password minimal 6 karakter');
      return;
    }

    setState(() => loading = true);

    try {
      if (isRegister) {
        final response = await supabase.auth.signUp(
          email: email,
          password: password,
        );

        if (response.session == null) {
          showMessage(
            'Pendaftaran berhasil. Periksa email untuk verifikasi, lalu login.',
          );
        } else {
          showMessage('Pendaftaran berhasil');
        }
      } else {
        await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        showMessage('Login berhasil');
      }
    } on AuthException catch (e) {
      showMessage(e.message);
    } catch (e) {
      showMessage('Terjadi kesalahan: $e');
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              const Icon(
                Icons.shopping_bag,
                size: 85,
                color: Colors.green,
              ),
              const SizedBox(height: 12),
              const Text(
                'Bmarket',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isRegister
                    ? 'Buat akun Bmarket'
                    : 'Selamat datang kembali!',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 35),

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: loading ? null : authenticate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: loading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(
                          isRegister ? 'DAFTAR' : 'LOGIN',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 15),

              TextButton(
                onPressed: loading
                    ? null
                    : () {
                        setState(() {
                          isRegister = !isRegister;
                        });
                      },
                child: Text(
                  isRegister
                      ? 'Sudah punya akun? Login'
                      : 'Belum punya akun? Daftar sekarang',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========================================
// HALAMAN PRODUK
// ========================================

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final searchController = TextEditingController();

  late Future<List<Map<String, dynamic>>> productsFuture;

  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    productsFuture = loadProducts();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> loadProducts() async {
    final result = await supabase
        .from('products')
        .select(
          'id, seller_id, name, description, category, price, stock, image_url, is_active, created_at, updated_at',
        )
        .eq('is_active', true)
        .order('id', ascending: false);

    return List<Map<String, dynamic>>.from(result);
  }

  Future<void> refreshProducts() async {
    final newFuture = loadProducts();

    setState(() {
      productsFuture = newFuture;
    });

    await newFuture;
  }

  String formatRupiah(dynamic value) {
    final number = int.tryParse(value.toString()) ?? 0;

    return 'Rp ${number.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    )}';
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: const Text(
          'Bmarket',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: refreshProducts,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: () {
                    searchController.clear();
                    setState(() => searchQuery = '');
                  },
                  icon: const Icon(Icons.close),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),

          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 50,
                            color: Colors.red,
                          ),
                          Text('${snapshot.error}'),
                          ElevatedButton(
                            onPressed: refreshProducts,
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final products = snapshot.data ?? [];

                final filtered = products.where((product) {
                  final name = (product['name'] ?? '')
                      .toString()
                      .toLowerCase();

                  final category = (product['category'] ?? '')
                      .toString()
                      .toLowerCase();

                  return name.contains(searchQuery) ||
                      category.contains(searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('Belum ada produk tersedia'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: refreshProducts,
                  child: GridView.builder(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.68,
                    ),
                    itemBuilder: (context, index) {
                      final product = filtered[index];
                      final imageUrl =
                          product['image_url']?.toString() ?? '';

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailPage(
                                product: product,
                              ),
                            ),
                          ).then((_) => refreshProducts());
                        },
                        child: Card(
                          clipBehavior: Clip.antiAlias,
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
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(
                                            Icons.image_not_supported,
                                            size: 50,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.shopping_bag,
                                          size: 50,
                                        ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['name'].toString(),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      formatRupiah(product['price']),
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Stok: ${product['stock']}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    const Text(
                                      'Lihat detail →',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================
// DETAIL PRODUK DAN CHECKOUT
// ========================================

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailPage> createState() =>
      _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  bool purchasing = false;

  String formatRupiah(dynamic value) {
    final number = int.tryParse(value.toString()) ?? 0;

    return 'Rp ${number.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    )}';
  }

  Future<void> buyNow() async {
    if (supabase.auth.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }

    final productId = int.tryParse(
      widget.product['id'].toString(),
    );

    if (productId == null) {
      return;
    }

    if ((widget.product['stock'] as num? ?? 0) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stok produk habis')),
      );
      return;
    }

    setState(() => purchasing = true);

    try {
      final result = await supabase.rpc(
        'bmarket_checkout',
        params: {
          'p_items': [
            {
              'product_id': productId,
              'quantity': 1,
            }
          ],
        },
      );

      if (!mounted) return;

      final orderId = result.toString();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pesanan berhasil dibuat! ID: $orderId',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } on PostgrestException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Checkout gagal: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kesalahan: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => purchasing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final imageUrl = product['image_url']?.toString() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 300,
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image_not_supported, size: 90),
                    )
                  : const Icon(Icons.shopping_bag, size: 90),
            ),

            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name']?.toString() ?? '',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    formatRupiah(product['price']),
                    style: const TextStyle(
                      fontSize: 25,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Divider(height: 30),

                  const Text(
                    'Kategori',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(product['category']?.toString() ?? '-'),

                  const SizedBox(height: 20),

                  const Text(
                    'Stok Produk',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('${product['stock'] ?? 0} tersedia'),

                  const SizedBox(height: 20),

                  const Text(
                    'Deskripsi Produk',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    product['description']?.toString() ??
                        'Belum ada deskripsi produk.',
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: purchasing ? null : buyNow,
                      icon: purchasing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.shopping_cart),
                      label: Text(
                        purchasing
                            ? 'Memproses...'
                            : 'Beli Sekarang',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
