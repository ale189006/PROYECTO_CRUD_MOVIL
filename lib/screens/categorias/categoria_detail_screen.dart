import 'package:flutter/material.dart';
import '../../models/categoria.dart';
import '../../models/producto.dart';
import '../../services/producto_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/custom_card.dart';
import '../productos/productos_screen.dart';

class CategoriaDetailScreen extends StatefulWidget {
  final Categoria categoria;

  const CategoriaDetailScreen({super.key, required this.categoria});

  @override
  State<CategoriaDetailScreen> createState() => _CategoriaDetailScreenState();
}

class _CategoriaDetailScreenState extends State<CategoriaDetailScreen> {
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
      final productos = await ProductoService.getProductos(categoriaId: widget.categoria.id);
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

  void _navigateToProducts() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductosScreen(categoria: widget.categoria),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoria.nombre),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _loadProductos,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Category info card
          _buildCategoryInfoCard(),
          
          // Products section
          Expanded(
            child: _isLoading
                ? const LoadingWidget(message: 'Cargando productos...')
                : _errorMessage != null
                    ? _buildErrorWidget()
                    : _productos.isEmpty
                        ? _buildEmptyWidget()
                        : _buildProductosList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToProducts,
        icon: const Icon(Icons.inventory_2),
        label: const Text('Ver Productos'),
      ),
    );
  }

  Widget _buildCategoryInfoCard() {
    return CustomCard(
      margin: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: widget.categoria.color != null 
                      ? Color(int.parse(widget.categoria.color!.replaceFirst('#', '0xff')))
                      : Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconData(widget.categoria.icono),
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.categoria.nombre,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.categoria.descripcion != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.categoria.descripcion!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoItem(
                icon: Icons.inventory_2,
                label: 'Productos',
                value: '${widget.categoria.totalProductos}',
              ),
              const SizedBox(width: 24),
              _buildInfoItem(
                icon: Icons.calendar_today,
                label: 'Creada',
                value: _formatDate(widget.categoria.fechaCreacion),
              ),
              const SizedBox(width: 24),
              _buildInfoItem(
                icon: widget.categoria.activo ? Icons.check_circle : Icons.cancel,
                label: 'Estado',
                value: widget.categoria.activo ? 'Activa' : 'Inactiva',
                valueColor: widget.categoria.activo ? Colors.green : Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
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
            'Esta categoría no tiene productos asociados',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Productos (${_productos.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _navigateToProducts,
                child: const Text('Ver todos'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            itemCount: _productos.take(5).length, // Show only first 5
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
              );
            },
          ),
        ),
        if (_productos.length > 5)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Y ${_productos.length - 5} productos más...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
      ],
    );
  }

  IconData _getIconData(String? icon) {
    if (icon == null) return Icons.category;
    
    switch (icon.toLowerCase()) {
      case 'fas fa-laptop':
        return Icons.laptop;
      case 'fas fa-tshirt':
        return Icons.checkroom;
      case 'fas fa-home':
        return Icons.home;
      case 'fas fa-dumbbell':
        return Icons.fitness_center;
      case 'fas fa-book':
        return Icons.book;
      default:
        return Icons.category;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
