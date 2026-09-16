import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(
  ChangeNotifierProvider(
    create: (_) => CartProvider(),
    child: const ElectroMartApp(),
  ),
);

// 1. MODEL
class Product {
  final String id, name, subtitle, imageAsset;
  final double price;
  Product({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.price,
    required this.imageAsset,
  });
}

class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, required this.quantity});
}

// 2. STATE MANAGER (CART PROVIDER)
class CartProvider extends ChangeNotifier {
  final List<Product> products = [
    Product(
      id: '1',
      name: 'Laptop ASUS VivoBook',
      subtitle: '14" | Core i5 | 8GB | 512GB',
      price: 8499000,
      imageAsset: 'assets/laptop.jpg',
    ),
    Product(
      id: '2',
      name: 'Samsung Galaxy A55',
      subtitle: '6.5" | 8GB | 256GB',
      price: 5999000,
      imageAsset: 'assets/samsung.jpg',
    ),
    Product(
      id: '3',
      name: 'Sony WH-CH720N',
      subtitle: 'Headphone Noise Cancelling',
      price: 2199000,
      imageAsset: 'assets/sony.jpg',
    ),
    Product(
      id: '4',
      name: 'Smart TV Samsung 43"',
      subtitle: '4K UHD | Smart Hub',
      price: 4500000,
      imageAsset: 'assets/smarttv.jpg',
    ),
  ];
  final List<CartItem> cartItems = [];

  int get totalCartCount => cartItems.fold(0, (s, i) => s + i.quantity);
  double get subtotal =>
      cartItems.fold(0.0, (s, i) => s + (i.product.price * i.quantity));
  double get totalPembayaran => cartItems.isNotEmpty ? subtotal + 30000 : 0;

  void addToCart(Product p) {
    int i = cartItems.indexWhere((x) => x.product.id == p.id);
    if (i != -1)
      cartItems[i].quantity++;
    else
      cartItems.add(CartItem(product: p, quantity: 1));
    notifyListeners();
  }

  void updateQuantity(int i, int change) {
    cartItems[i].quantity += change;
    if (cartItems[i].quantity <= 0) cartItems.removeAt(i);
    notifyListeners();
  }

  void removeItem(int i) {
    cartItems.removeAt(i);
    notifyListeners();
  }
}

// 3. UI APPLICATION
class ElectroMartApp extends StatelessWidget {
  const ElectroMartApp({super.key});
  static const green = Color(0xFF00AA5B),
      darkGreen = Color(0xFF008744),
      lightGreen = Color(0xFFE8F8F0);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ElectroMart',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: green,
        colorScheme: ColorScheme.fromSeed(seedColor: green),
      ),
      home: const MainNav(),
    );
  }
}

class MainNav extends StatefulWidget {
  const MainNav({super.key});
  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _idx = 0;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final filtered = cart.products
        .where(
          (p) => '${p.name} ${p.subtitle}'.toLowerCase().contains(
            _query.toLowerCase(),
          ),
        )
        .toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Center(
                    child: Text(
                      'ElectroMart',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  if (_idx == 0)
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => setState(() => _idx = 1),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(Icons.shopping_cart_outlined, size: 28),
                            if (cart.totalCartCount > 0)
                              Positioned(
                                right: -4,
                                top: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: ElectroMartApp.green,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${cart.totalCartCount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _idx,
                children: [
                  // TAB 1: PRODUK
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        TextField(
                          controller: _searchCtrl,
                          onChanged: (v) => setState(() => _query = v),
                          decoration: InputDecoration(
                            hintText: 'Cari produk elektronik...',
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                            suffixIcon: _query.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                      color: Colors.grey,
                                      size: 18,
                                    ),
                                    onPressed: () => setState(() {
                                      _searchCtrl.clear();
                                      _query = '';
                                    }),
                                  )
                                : null,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: ElectroMartApp.green,
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Produk Elektronik',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        filtered.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: Center(
                                  child: Text(
                                    'Produk tidak ditemukan',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              )
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filtered.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.8,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                    ),
                                itemBuilder: (_, i) =>
                                    _buildProductCard(context, filtered[i]),
                              ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  // TAB 2: KERANJANG
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, size: 20),
                              onPressed: () => setState(() => _idx = 0),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Keranjang Belanja',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        cart.cartItems.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 32),
                                child: Center(
                                  child: Text(
                                    'Keranjang Anda kosong',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: cart.cartItems.length,
                                itemBuilder: (_, i) =>
                                    _buildCartCard(context, cart, i),
                              ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: ElectroMartApp.green,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ringkasan Belanja',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _sumRow(
                                'Total Barang',
                                '${cart.totalCartCount} item',
                              ),
                              const SizedBox(height: 4),
                              _sumRow('Subtotal', _rupiah(cart.subtotal)),
                              const SizedBox(height: 4),
                              _sumRow(
                                'Ongkos Kirim',
                                cart.cartItems.isNotEmpty
                                    ? _rupiah(30000)
                                    : 'Rp 0',
                              ),
                              const Divider(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total Pembayaran',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    _rupiah(cart.totalPembayaran),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: ElectroMartApp.green,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton.icon(
                            onPressed: cart.cartItems.isNotEmpty ? () {} : null,
                            icon: const Icon(
                              Icons.receipt_long,
                              size: 16,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Lanjut ke Pembayaran',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF008848),
                              disabledBackgroundColor: Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx,
        backgroundColor: ElectroMartApp.darkGreen,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _idx = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Produk'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Keranjang',
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product p) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: ElectroMartApp.lightGreen,
        border: Border.all(color: ElectroMartApp.green.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              p.imageAsset,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 100,
                color: Colors.grey.shade200,
                child: const Center(
                  child: Text(
                    'GAMBAR ERROR',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            p.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            p.subtitle,
            style: const TextStyle(color: Colors.black54, fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            _rupiah(p.price),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: ElectroMartApp.green,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 30,
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<CartProvider>().addToCart(p);
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: ElectroMartApp.green,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${p.name} berhasil ditambahkan!',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.white,
                      behavior: SnackBarBehavior.floating,
                      elevation: 6,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
              },
              icon: const Icon(
                Icons.add_shopping_cart,
                size: 13,
                color: Colors.black87,
              ),
              label: const Text(
                'Tambah ke Keranjang',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                elevation: 1,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartCard(BuildContext context, CartProvider provider, int i) {
    final item = provider.cartItems[i];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              item.product.imageAsset,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 60,
                height: 60,
                color: Colors.grey.shade200,
                child: const Center(
                  child: Text(
                    'IMG',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  item.product.subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
                const SizedBox(height: 4),
                Text(
                  _rupiah(item.product.price),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: ElectroMartApp.green,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                height: 24,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => provider.updateQuantity(i, -1),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(Icons.remove, size: 12),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => provider.updateQuantity(i, 1),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(Icons.add, size: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () => provider.removeItem(i),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sumRow(String l, String v) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(l, style: const TextStyle(color: Colors.black87, fontSize: 12)),
      Text(
        v,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
      ),
    ],
  );

  String _rupiah(double n) {
    String s = n.toInt().toString(), r = '';
    for (int i = s.length - 1, c = 1; i >= 0; i--, c++) {
      r = s[i] + r;
      if (c % 3 == 0 && i != 0) r = '.$r';
    }
    return 'Rp $r';
  }
}
