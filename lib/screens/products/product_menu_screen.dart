import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../services/product_service.dart';

class ProductMenuScreen extends StatefulWidget {
  const ProductMenuScreen({super.key});

  @override
  State<ProductMenuScreen> createState() => _ProductMenuScreenState();
}

class _ProductMenuScreenState extends State<ProductMenuScreen> {
    List<Product> get products => ProductService.instance.products;

  String getCategoryName(ProductCategory category) {
    switch (category) {
      case ProductCategory.bbq:
        return 'BBQ';
      case ProductCategory.drinks:
        return 'Drinks';
      case ProductCategory.sides:
        return 'Sides';
      case ProductCategory.rice:
        return 'Rice';
    }
  }

  void addProduct() {
    showDialog(
      context: context,
      builder: (context) {
        return const _ProductDialog();
      },
    ).then((product) {
      if (product != null && product is Product) {
        setState(() {
          products.add(product);
        });
      }
    });
  }

  void editProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) {
        return _ProductDialog(product: product);
      },
    ).then((updatedProduct) {
      if (updatedProduct != null && updatedProduct is Product) {
        setState(() {
          product.name = updatedProduct.name;
          product.price = updatedProduct.price;
          product.category = updatedProduct.category;
          product.isAvailable = updatedProduct.isAvailable;
        });
      }
    });
  }

  void deleteProduct(Product product) {
    setState(() {
      products.remove(product);
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('${product.name} deleted')));
  }

  Widget buildProductCard(Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(
            product.category == ProductCategory.bbq
                ? Icons.outdoor_grill
                : Icons.restaurant,
          ),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${getCategoryName(product.category)} • ₱${product.price.toStringAsFixed(2)}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: product.isAvailable,
              onChanged: (value) {
                setState(() {
                  product.isAvailable = value;
                });
              },
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  editProduct(product);
                } else if (value == 'delete') {
                  deleteProduct(product);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCategorySection(ProductCategory category) {
    final categoryProducts = products
        .where((product) => product.category == category)
        .toList();

    if (categoryProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getCategoryName(category),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...categoryProducts.map(buildProductCard),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildCategorySection(ProductCategory.bbq),
          buildCategorySection(ProductCategory.rice),
          buildCategorySection(ProductCategory.sides),
          buildCategorySection(ProductCategory.drinks),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addProduct,
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    );
  }
}

class _ProductDialog extends StatefulWidget {
  final Product? product;

  const _ProductDialog({this.product});

  @override
  State<_ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<_ProductDialog> {
  late final TextEditingController nameController;
  late final TextEditingController priceController;

  late ProductCategory selectedCategory;
  late bool isAvailable;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.product?.name ?? '');

    priceController = TextEditingController(
      text: widget.product?.price.toString() ?? '',
    );

    selectedCategory = widget.product?.category ?? ProductCategory.bbq;

    isAvailable = widget.product?.isAvailable ?? true;
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    super.dispose();
  }

  void saveProduct() {
    final name = nameController.text.trim();
    final price = double.tryParse(priceController.text.trim());

    if (name.isEmpty || price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid name and price')),
      );
      return;
    }

    final product = Product(
      id:
          widget.product?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      price: price,
      category: selectedCategory,
      isAvailable: isAvailable,
    );

    Navigator.pop(context, product);
  }

  String getCategoryName(ProductCategory category) {
    switch (category) {
      case ProductCategory.bbq:
        return 'BBQ';
      case ProductCategory.drinks:
        return 'Drinks';
      case ProductCategory.sides:
        return 'Sides';
      case ProductCategory.rice:
        return 'Rice';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Product' : 'Add Product'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Price',
                prefixText: '₱ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ProductCategory>(
              initialValue: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: ProductCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(getCategoryName(category)),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Available'),
              value: isAvailable,
              onChanged: (value) {
                setState(() {
                  isAvailable = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: saveProduct,
          child: Text(isEditing ? 'Save Changes' : 'Add Product'),
        ),
      ],
    );
  }
}
