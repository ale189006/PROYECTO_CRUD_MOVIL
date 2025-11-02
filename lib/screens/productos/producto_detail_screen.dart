import 'package:flutter/material.dart';
import '../../models/producto.dart';
import '../../widgets/custom_card.dart';

class ProductoDetailScreen extends StatelessWidget {
  final Producto producto;

  const ProductoDetailScreen({super.key, required this.producto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(producto.nombre),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            _buildProductImage(),
            const SizedBox(height: 16),

            // Product info
            _buildProductInfo(),
            const SizedBox(height: 16),

            // Category info
            if (producto.categoria != null) ...[
              _buildCategoryInfo(),
              const SizedBox(height: 16),
            ],

            // Additional details
            _buildAdditionalDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return CustomCard(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: producto.imagenUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      producto.imagenUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Imagen no disponible',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sin imagen',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfo() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            producto.nombre,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (producto.descripcion != null) ...[
            Text(
              producto.descripcion!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.attach_money,
                  label: 'Precio',
                  value: '\$${producto.precio.toStringAsFixed(2)}',
                  valueColor: Colors.green,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.inventory_2,
                  label: 'Stock',
                  value: '${producto.stock}',
                  valueColor: producto.stock > 0 ? Colors.blue : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: producto.activo ? Icons.check_circle : Icons.cancel,
                  label: 'Estado',
                  value: producto.activo ? 'Activo' : 'Inactivo',
                  valueColor: producto.activo ? Colors.green : Colors.red,
                ),
              ),
              if (producto.sku != null)
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.qr_code,
                    label: 'SKU',
                    value: producto.sku!,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryInfo() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categoría',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: producto.categoria!.color != null 
                      ? Color(int.parse(producto.categoria!.color!.replaceFirst('#', '0xff')))
                      : Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIconData(producto.categoria!.icono),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                producto.categoria!.nombre,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalDetails() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detalles Adicionales',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            icon: Icons.calendar_today,
            label: 'Fecha de Creación',
            value: _formatDate(producto.fechaCreacion),
          ),
          const SizedBox(height: 8),
          if (producto.imagenUrl != null)
            _buildInfoItem(
              icon: Icons.link,
              label: 'URL de Imagen',
              value: producto.imagenUrl!,
              isUrl: true,
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
    bool isUrl = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: valueColor,
                ),
                maxLines: isUrl ? 2 : 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
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
