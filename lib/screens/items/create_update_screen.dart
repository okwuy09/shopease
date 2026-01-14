import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/items_provider.dart';
import '../../widgets/custom_widgets.dart';

class CreateUpdateScreen extends StatefulWidget {
  final ItemModel? item; // null for Create, not-null for Update

  const CreateUpdateScreen({super.key, this.item});

  @override
  State<CreateUpdateScreen> createState() => _CreateUpdateScreenState();
}

class _CreateUpdateScreenState extends State<CreateUpdateScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  late TextEditingController _priceController;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  
  String _selectedCategory = 'electronics';
  final List<String> _categories = [
    'electronics',
    'jewelery',
    "men's clothing",
    "women's clothing"
  ];

  bool get isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item?.title ?? '');
    _bodyController = TextEditingController(text: widget.item?.body ?? '');
    _priceController = TextEditingController(
      text: widget.item?.price?.toString() ?? ''
    );
    if (widget.item?.realCategory != null && _categories.contains(widget.item!.realCategory)) {
      _selectedCategory = widget.item!.realCategory!;
    }

    // Animation Init
    _animController = AnimationController(
       vsync: this,
       duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _priceController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final itemsProvider = Provider.of<ItemsProvider>(context, listen: false);
      
      final newItem = ItemModel(
        id: widget.item?.id, // Keep ID if editing
        title: _titleController.text,
        body: _bodyController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        image: widget.item?.image ?? 'https://i.pravatar.cc', // Default image
        realCategory: _selectedCategory,
      );

      bool success;
      if (isEditing) {
        success = await itemsProvider.updateItem(newItem);
      } else {
        success = await itemsProvider.addItem(newItem);
      }

      if (!mounted) return;

      if (success) {
        if (isEditing) {
          Navigator.pop(context); // Only pop if editing (pushed screen)
        } else {
          // Reset form if creating (tab screen)
          _titleController.clear();
          _bodyController.clear();
          _priceController.clear();
          _bodyController.clear();
          setState(() {
             _selectedCategory = 'electronics';
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Item updated!' : 'Item created!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(itemsProvider.error ?? 'An error occurred'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ItemsProvider>().isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Item' : 'Create Item',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: isEditing,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Stack(
        children: [
          // 1. Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: isDark 
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0D332D), Color(0xFF141414)],
                    stops: [0.0, 0.4],
                  )
                : const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFE0F2F1), Color(0xFFF5F5F5)],
                    stops: [0.0, 0.4],
                  ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                     // 2. Glassmorphic Form Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: isDark ? Colors.white10 : Colors.white),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                CustomTextField(
                                  controller: _titleController,
                                  label: 'Title',
                                  validator: (v) => v!.isEmpty ? 'Required' : null,
                                  prefixIcon: Icons.title_rounded,
                                ),
                                const SizedBox(height: 20),
                                
                                // Price and Category Row
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomTextField(
                                        controller: _priceController,
                                        label: 'Price',
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        validator: (v) {
                                          if (v == null || v.isEmpty) return 'Required';
                                          if (double.tryParse(v) == null) return 'Invalid';
                                          return null;
                                        },
                                        prefixIcon: Icons.attach_money,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value: _selectedCategory,
                                        isExpanded: true, 
                                        dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                        decoration: InputDecoration(
                                          labelText: 'Category',
                                          prefixIcon: const Icon(Icons.category),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide.none,
                                          ),
                                          filled: true,
                                          fillColor: isDark ? Colors.black26 : Colors.white.withOpacity(0.5),
                                        ),
                                        items: _categories.map((c) => DropdownMenuItem(
                                          value: c,
                                          child: Text(
                                            c.toUpperCase(), 
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark ? Colors.white : Colors.black87,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        )).toList(),
                                        onChanged: (val) {
                                          if (val != null) {
                                            setState(() {
                                              _selectedCategory = val;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                
                                CustomTextField(
                                  controller: _bodyController,
                                  label: 'Description',
                                  maxLines: 8,
                                  validator: (v) => v!.isEmpty ? 'Required' : null,
                                  prefixIcon: Icons.description_outlined,
                                ),
                                const SizedBox(height: 32),
                                
                                CustomButton(
                                  text: isEditing ? 'Update Item' : 'Create Item',
                                  onPressed: _handleSubmit,
                                  isLoading: isLoading,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
