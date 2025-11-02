import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/categoria.dart';
import '../../services/categoria_service.dart';
import '../../widgets/loading_widget.dart';

class CategoriaFormScreen extends StatefulWidget {
  final Categoria? categoria;

  const CategoriaFormScreen({super.key, this.categoria});

  @override
  State<CategoriaFormScreen> createState() => _CategoriaFormScreenState();
}

class _CategoriaFormScreenState extends State<CategoriaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _iconoController = TextEditingController();
  final _colorController = TextEditingController();

  bool _isLoading = false;
  bool _activo = true;

  // Predefined colors
  final List<Color> _predefinedColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
    Colors.amber,
    Colors.cyan,
  ];

  // Predefined icons
  final List<IconData> _predefinedIcons = [
    Icons.category,
    Icons.laptop,
    Icons.checkroom,
    Icons.home,
    Icons.fitness_center,
    Icons.book,
    Icons.smartphone,
    Icons.car_rental,
    Icons.restaurant,
    Icons.local_grocery_store,
  ];

  Color _selectedColor = Colors.blue;
  IconData _selectedIcon = Icons.category;

  @override
  void initState() {
    super.initState();
    if (widget.categoria != null) {
      _loadCategoriaData();
    }
  }

  void _loadCategoriaData() {
    final categoria = widget.categoria!;
    _nombreController.text = categoria.nombre;
    _descripcionController.text = categoria.descripcion ?? '';
    _iconoController.text = categoria.icono ?? '';
    _colorController.text = categoria.color ?? '#007bff';
    _activo = categoria.activo;

    if (categoria.color != null) {
      try {
        _selectedColor = Color(int.parse(categoria.color!.replaceFirst('#', '0xff')));
      } catch (e) {
        _selectedColor = Colors.blue;
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _iconoController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _saveCategoria() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final categoria = Categoria(
        id: widget.categoria?.id ?? 0,
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim().isEmpty 
            ? null 
            : _descripcionController.text.trim(),
        icono: _iconoController.text.trim().isEmpty 
            ? null 
            : _iconoController.text.trim(),
        color: _colorController.text.trim(),
        activo: _activo,
        totalProductos: widget.categoria?.totalProductos ?? 0,
        fechaCreacion: widget.categoria?.fechaCreacion ?? '',
        fechaActualizacion: widget.categoria?.fechaActualizacion ?? '',
      );

      if (widget.categoria == null) {
        await CategoriaService.createCategoria(categoria);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Categoría creada exitosamente')),
          );
        }
      } else {
        await CategoriaService.updateCategoria(categoria);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Categoría actualizada exitosamente')),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
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
        title: Text(widget.categoria == null ? 'Nueva Categoría' : 'Editar Categoría'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _saveCategoria,
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
              // Nombre field
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre *',
                  hintText: 'Ingresa el nombre de la categoría',
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

              // Descripción field
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Descripción de la categoría (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Icono field
              TextFormField(
                controller: _iconoController,
                decoration: const InputDecoration(
                  labelText: 'Icono',
                  hintText: 'Clase de icono (ej: fas fa-laptop)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Color picker
              _buildColorPicker(),
              const SizedBox(height: 16),

              // Estado activo
              SwitchListTile(
                title: const Text('Activo'),
                subtitle: const Text('La categoría estará disponible para usar'),
                value: _activo,
                onChanged: (value) {
                  setState(() {
                    _activo = value;
                  });
                },
              ),
              const SizedBox(height: 32),

              // Save button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveCategoria,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  widget.categoria == null ? 'Crear Categoría' : 'Actualizar Categoría',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _predefinedColors.map((color) {
            final isSelected = _selectedColor == color;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = color;
                  _colorController.text = '#${color.value.toRadixString(16).substring(2)}';
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.grey,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _colorController,
          decoration: const InputDecoration(
            labelText: 'Código de color',
            hintText: '#007bff',
            border: OutlineInputBorder(),
            prefixText: '#',
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F]')),
            LengthLimitingTextInputFormatter(6),
          ],
          onChanged: (value) {
            if (value.length == 6) {
              try {
                final color = Color(int.parse('0xff$value'));
                setState(() {
                  _selectedColor = color;
                });
              } catch (e) {
                // Invalid color code
              }
            }
          },
        ),
      ],
    );
  }
}
