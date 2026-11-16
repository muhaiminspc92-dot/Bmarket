
import 'package:flutter/material.dart';

void main() {
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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bmarket',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Cari produk di Bmarket',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Kategori Produk',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              CategoryItem(icon: Icons.phone_android, name: 'Elektronik'),
              CategoryItem(icon: Icons.checkroom, name: 'Fashion'),
              CategoryItem(icon: Icons.home, name: 'Rumah Tangga'),
              CategoryItem(icon: Icons.face, name: 'Kecantikan'),
              CategoryItem(icon: Icons.fastfood, name: 'Makanan'),
              CategoryItem(icon: Icons.more_horiz, name: 'Lainnya'),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Produk Pilihan',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Card(
            child: ListTile(
              leading: Icon(Icons.shopping_bag, size: 40),
              title: Text('Produk Bmarket'),
              subtitle: Text('Temukan berbagai produk menarik'),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final IconData icon;
  final String name;

  const CategoryItem({
    super.key,
    required this.icon,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            child: Icon(icon),
          ),
          const SizedBox(height: 6),
          Text(name, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
