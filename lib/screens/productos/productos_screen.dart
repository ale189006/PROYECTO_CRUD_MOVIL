import 'package:flutter/material.dart';
import '../../models/categoria.dart';
import '../../models/producto.dart';
import '../../services/producto_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/custom_card.dart';
import 'producto_form_screen.dart';
import 'producto_detail_screen.dart';

class ProductosScreen extends StatefulWidget {
  final Categoria? categoria;

  const ProductosScreen({super.key, this.categoria});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  List<Producto> _productos = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProductos();
  }

  Future<void> _loadProductos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final productos = await ProductoService.getProductos(
        categoriaId: widget.categoria?.id,
      );
      setState(() {
        _productos = productos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteProducto(Producto producto) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que quieres eliminar el producto "${producto.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ProductoService.deleteProducto(producto.id);
        _loadProductos();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Producto eliminado exitosamente')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar producto: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _navigateToForm({Producto? producto}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ProductoFormScreen(
          producto: producto,
          categoria: widget.categoria,
        ),
      ),
    );

    if (result == true) {
      _loadProductos();
    }
  }

  void _navigateToDetail(Producto producto) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductoDetailScreen(producto: producto),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoria != null 
            ? 'Productos - ${widget.categoria!.nombre}'
            : 'Productos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _loadProductos,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Cargando productos...')
          : _errorMessage != null
              ? _buildErrorWidget()
              : _productos.isEmpty
                  ? _buildEmptyWidget()
                  : _buildProductosList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        tooltip: 'Agregar producto',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar productos',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadProductos,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay productos',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            widget.categoria != null
                ? 'No hay productos en esta categoría'
                : 'Agrega tu primer producto tocando el botón +',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductosList() {
    return RefreshIndicator(
      onRefresh: _loadProductos,
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _productos.length,
        itemBuilder: (context, index) {
          final producto = _productos[index];
          return ProductCard(
            title: producto.nombre,
            description: producto.descripcion,
            price: producto.precio,
            stock: producto.stock,
            imageUrl: producto.imagenUrl,
            categoryName: producto.categoria?.nombre,
            categoryColor: producto.categoria?.color != null 
                ? Color(int.parse(producto.categoria!.color!.replaceFirst('#', '0xff')))
                : null,
            onTap: () => _navigateToDetail(producto),
            onEdit: () => _navigateToForm(producto: producto),
            onDelete: () => _deleteProducto(producto),
          );
        },
      ),
    );
  }
}
