import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wizmi/data/static_products.dart';
import 'package:wizmi/theme.dart';

class Product extends StatefulWidget {
  const Product({super.key});

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> with SingleTickerProviderStateMixin {
  String? _brandId;
  String? _brandName;
  String _searchQuery = '';
  bool _shimmerDone = false;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _shimmerDone = true);
        _fadeController.forward();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          _brandId = args['brandId'];
          _brandName = args['brandName'];
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _addToCart(PartModel part) async {
    final user = FirebaseAuth.instance.currentUser;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (user == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please log in to add items to cart'), backgroundColor: AppTheme.error),
      );
      return;
    }

    try {
      final cartRef = FirebaseFirestore.instance.collection('cart').doc(user.uid);
      final cartDoc = await cartRef.get();

      if (!cartDoc.exists) {
        await cartRef.set({'items': [], 'total': 0, 'updatedAt': FieldValue.serverTimestamp()});
      }

      final cartData = cartDoc.data();
      final items = List<Map<String, dynamic>>.from(cartData?['items'] ?? []);
      final existingIndex = items.indexWhere((item) => item['partId'] == part.id);

      if (existingIndex != -1) {
        items[existingIndex]['quantity'] = (items[existingIndex]['quantity'] as int? ?? 0) + 1;
      } else {
        items.add({
          'partId': part.id,
          'name': part.name,
          'price': part.price,
          'imageUrl': '',
          'brandId': part.brandId,
          'quantity': 1,
          'addedAt': DateTime.now().toIso8601String(),
        });
      }

      await cartRef.update({'items': items, 'updatedAt': FieldValue.serverTimestamp()});

      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text('${part.name} added to cart',
                    style: GoogleFonts.poppins(fontSize: 13)),
              ),
            ],
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(12),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'View Cart',
            textColor: Colors.white,
            onPressed: () => navigator.pushNamed('cart'),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to add to cart', style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(12),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final allParts = SparePartsData.partsByBrand[_brandId] ?? [];
    final filtered = _searchQuery.isEmpty
        ? allParts
        : allParts.where((p) => p.name.toLowerCase().contains(_searchQuery)).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => Navigator.pushNamed(context, 'cart'),
                tooltip: 'Cart',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryDark, AppTheme.primary, AppTheme.primaryLight],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 48, 72, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _brandName ?? 'Spare Parts',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Genuine parts at the best prices',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        body: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: _shimmerDone
                  ? _buildProductGrid(filtered)
                  : _buildShimmer(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
        style: GoogleFonts.poppins(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search parts...',
          hintStyle: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textSecondary),
          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: AppTheme.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildProductGrid(List<PartModel> parts) {
    if (parts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.inventory_2_outlined,
                    size: 56, color: AppTheme.primary.withValues(alpha: 0.4)),
              ),
              const SizedBox(height: 20),
              Text('No parts found',
                  style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(height: 6),
              Text(
                _searchQuery.isNotEmpty ? 'Try a different search term' : 'No parts available for this brand',
                style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.70,
        ),
        itemCount: parts.length,
        itemBuilder: (context, index) {
          final part = parts[index];
          return _PartCard(part: part, onAddToCart: () => _addToCart(part));
        },
      ),
    );
  }

  Widget _buildShimmer() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.70,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: const Color(0xFFE5E7EB),
        highlightColor: const Color(0xFFF9FAFB),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

class _PartCard extends StatefulWidget {
  final PartModel part;
  final VoidCallback onAddToCart;

  const _PartCard({required this.part, required this.onAddToCart});

  @override
  State<_PartCard> createState() => _PartCardState();
}

class _PartCardState extends State<_PartCard> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  IconData get _categoryIcon {
    switch (widget.part.category.toLowerCase()) {
      case 'engine': return Icons.settings_outlined;
      case 'brakes': return Icons.disc_full_rounded;
      case 'electrical': return Icons.bolt_rounded;
      case 'cooling': return Icons.thermostat_rounded;
      case 'fuel': return Icons.local_gas_station_rounded;
      case 'ac': return Icons.ac_unit_rounded;
      case 'suspension': return Icons.car_repair_rounded;
      case 'drivetrain': return Icons.rotate_right_rounded;
      case 'steering': return Icons.turn_right_rounded;
      default: return Icons.build_outlined;
    }
  }

  Color get _categoryColor {
    switch (widget.part.category.toLowerCase()) {
      case 'engine': return AppTheme.primary;
      case 'brakes': return AppTheme.error;
      case 'electrical': return const Color(0xFFF59E0B);
      case 'cooling': return const Color(0xFF0EA5E9);
      case 'fuel': return const Color(0xFF10B981);
      case 'ac': return const Color(0xFF06B6D4);
      case 'suspension': return const Color(0xFF8B5CF6);
      case 'drivetrain': return const Color(0xFFEF4444);
      default: return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleController,
      child: GestureDetector(
        onTapDown: (_) => _scaleController.reverse(),
        onTapUp: (_) => _scaleController.forward(),
        onTapCancel: () => _scaleController.forward(),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Category icon section (replaces image — no image for static parts)
              Container(
                height: 110,
                decoration: BoxDecoration(
                  color: _categoryColor.withValues(alpha: 0.08),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_categoryIcon, size: 44, color: _categoryColor),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _categoryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.part.category,
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: _categoryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Info section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.part.name,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.part.description,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'EGP ${widget.part.price}',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary,
                            ),
                          ),
                          GestureDetector(
                            onTap: widget.onAddToCart,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppTheme.primaryDark, AppTheme.primaryLight],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primary.withValues(alpha: 0.35),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.add_shopping_cart_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
