import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/categoria.dart';
import '../../models/producto.dart';
import '../../services/categoria_service.dart';
import '../../services/producto_service.dart';
import '../../widgets/loading_widget.dart';

class ProductoFormScreen extends StatefulWidget {
  final Producto? producto;
  final Categoria? categoria;

  const ProductoFormScreen({super.key, this.producto, this.categoria});

  @override
  State<ProductoFormScreen> createState() => _ProductoFormScreenState();
}

class _ProductoFormScreenState extends State<ProductoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  final _stockController = TextEditingController();
  final _imagenUrlController = TextEditingController();
  final _skuController = TextEditingController();

  List<Categoria> _categorias = [];
  Categoria? _selectedCategoria;
  bool _isLoading = false;
  bool _activo = true;

  @override
  void initState() {
    super.initState();
    _loadCategorias();
  }

  Future<void> _loadCategorias() async {
    try {
      final categorias = await CategoriaService.getCategorias();
      if (!mounted) return;

      setState(() {
        _categorias = categorias.where((c) => c.activo).toList();
      });

      // Ahora que las categorías están cargadas, cargamos los datos del producto (si aplica)
      if (widget.producto != null) {
        _loadProductoData();
      } else if (widget.categoria != null) {
        setState(() {
          _selectedCategoria = widget.categoria;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar categorías: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _loadProductoData() {
    final producto = widget.producto!;
    _nombreController.text = producto.nombre;
    _descripcionController.text = producto.descripcion ?? '';
    _precioController.text = producto.precio.toString();
    _stockController.text = producto.stock.toString();
    _imagenUrlController.text = producto.imagenUrl ?? '';
    _skuController.text = producto.sku ?? '';
    _activo = producto.activo;

    // ✅ Protección para evitar "Bad state: No element"
    if (_categorias.isNotEmpty) {
      _selectedCategoria = _categorias.firstWhere(
        (c) => c.id == producto.categoriaId,
        orElse: () => _categorias.first,
      );
    } else {
      _selectedCategoria = null;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    _imagenUrlController.dispose();
    _skuController.dispose();
    super.dispose();
  }

  Future<void> _saveProducto() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategoria == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una categoría'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final producto = Producto(
        id: widget.producto?.id ?? 0,
        categoriaId: _selectedCategoria!.id,
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim().isEmpty
            ? null
            : _descripcionController.text.trim(),
        precio: double.parse(_precioController.text),
        stock: int.parse(_stockController.text),
        imagenUrl: _imagenUrlController.text.trim().isEmpty
            ? null
            : _imagenUrlController.text.trim(),
        sku: _skuController.text.trim().isEmpty
            ? null
            : _skuController.text.trim(),
        activo: _activo,
        fechaCreacion: widget.producto?.fechaCreacion ?? '',
        categoria: CategoriaInfo(
          id: _selectedCategoria!.id,
          nombre: _selectedCategoria!.nombre,
          color: _selectedCategoria!.color,
          icono: _selectedCategoria!.icono,
        ),
      );

      if (widget.producto == null) {
        await ProductoService.createProducto(producto);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Producto creado exitosamente')),
          );
        }
      } else {
        await ProductoService.updateProducto(producto);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Producto actualizado exitosamente')),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.producto == null ? 'Nuevo Producto' : 'Editar Producto',
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _saveProducto,
              child: const Text(
                'Guardar',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Guardando...')
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre *',
                      hintText: 'Ingresa el nombre del producto',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre es obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Categoria>(
                    value: _selectedCategoria,
                    decoration: const InputDecoration(
                      labelText: 'Categoría *',
                      border: OutlineInputBorder(),
                    ),
                    items: _categorias.map((categoria) {
                      return DropdownMenuItem<Categoria>(
                        value: categoria,
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: categoria.color != null
                                    ? Color(
                                        int.parse(
                                          categoria.color!.replaceFirst(
                                            '#',
                                            '0xff',
                                          ),
                                        ),
                                      )
                                    : Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(categoria.nombre),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (Categoria? newValue) {
                      setState(() {
                        _selectedCategoria = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'La categoría es obligatoria';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descripcionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      hintText: 'Descripción del producto (opcional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _precioController,
                    decoration: const InputDecoration(
                      labelText: 'Precio *',
                      hintText: '0.00',
                      border: OutlineInputBorder(),
                      prefixText: '\$ ',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El precio es obligatorio';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Ingresa un precio válido';
                      }
                      if (double.parse(value) < 0) {
                        return 'El precio no puede ser negativo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _stockController,
                    decoration: const InputDecoration(
                      labelText: 'Stock *',
                      hintText: '0',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El stock es obligatorio';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Ingresa un stock válido';
                      }
                      if (int.parse(value) < 0) {
                        return 'El stock no puede ser negativo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _skuController,
                    decoration: const InputDecoration(
                      labelText: 'SKU',
                      hintText: 'Código único del producto (opcional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _imagenUrlController,
                    decoration: const InputDecoration(
                      labelText: 'URL de Imagen',
                      hintText: 'https://ejemplo.com/imagen.jpg (opcional)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Activo'),
                    subtitle: const Text(
                      'El producto estará disponible para venta',
                    ),
                    value: _activo,
                    onChanged: (value) {
                      setState(() {
                        _activo = value;
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveProducto,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      widget.producto == null
                          ? 'Crear Producto'
                          : 'Actualizar Producto',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
