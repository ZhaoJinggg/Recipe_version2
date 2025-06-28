import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recipe_app/constants.dart';
import 'package:recipe_app/models/recipe.dart';
import 'package:recipe_app/services/firebase_service.dart';
import 'package:recipe_app/services/user_session_service.dart';

class UploadRecipeScreen extends StatefulWidget {
  final Recipe? recipeToEdit;

  const UploadRecipeScreen({super.key, this.recipeToEdit});

  @override
  State<UploadRecipeScreen> createState() => _UploadRecipeScreenState();
}

class _UploadRecipeScreenState extends State<UploadRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _servingsController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _fatController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();

  List<TextEditingController> _ingredientControllers = [
    TextEditingController()
  ];
  List<TextEditingController> _directionControllers = [TextEditingController()];
  List<TextEditingController> _nutritionControllers = [TextEditingController()];

  String _selectedCategory = 'Main Course';
  String _selectedDifficulty = 'Easy';
  File? _recipeImage;
  String? _existingImageUrl;
  bool _isLoading = false;

  final List<String> _categories = [
    'Appetizers',
    'Main Course',
    'Dessert',
    'Soups',
    'Salads',
    'Beverages'
  ];

  final List<String> _difficulties = ['Easy', 'Medium', 'Hard'];

  @override
  void initState() {
    super.initState();
    if (widget.recipeToEdit != null) {
      _populateFieldsForEditing();
    }
  }

  void _populateFieldsForEditing() {
    final recipe = widget.recipeToEdit!;
    _titleController.text = recipe.title;
    _descriptionController.text = recipe.description ?? '';
    _prepTimeController.text = recipe.prepTimeMinutes.toString();
    _servingsController.text = recipe.servings.toString();
    _caloriesController.text = recipe.calories.toString();
    _fatController.text = recipe.fat?.toString() ?? '';
    _proteinController.text = recipe.protein?.toString() ?? '';
    _carbsController.text = recipe.carbs?.toString() ?? '';
    _selectedCategory = recipe.category;
    _selectedDifficulty = recipe.difficultyLevel ?? 'Easy';
    _existingImageUrl = recipe.image;

    // Populate ingredients
    _ingredientControllers.clear();
    for (String ingredient in recipe.ingredients) {
      final controller = TextEditingController(text: ingredient);
      _ingredientControllers.add(controller);
    }
    if (_ingredientControllers.isEmpty) {
      _ingredientControllers.add(TextEditingController());
    }

    // Populate directions
    _directionControllers.clear();
    for (String direction in recipe.directions) {
      final controller = TextEditingController(text: direction);
      _directionControllers.add(controller);
    }
    if (_directionControllers.isEmpty) {
      _directionControllers.add(TextEditingController());
    }

    // Populate nutritions
    _nutritionControllers.clear();
    for (String nutrition in recipe.nutritions) {
      final controller = TextEditingController(text: nutrition);
      _nutritionControllers.add(controller);
    }
    if (_nutritionControllers.isEmpty) {
      _nutritionControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _prepTimeController.dispose();
    _servingsController.dispose();
    _caloriesController.dispose();
    _fatController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();

    for (var controller in _ingredientControllers) {
      controller.dispose();
    }
    for (var controller in _directionControllers) {
      controller.dispose();
    }
    for (var controller in _nutritionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _recipeImage = File(image.path);
          _existingImageUrl = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addIngredientField() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  void _removeIngredientField(int index) {
    if (_ingredientControllers.length > 1) {
      setState(() {
        _ingredientControllers[index].dispose();
        _ingredientControllers.removeAt(index);
      });
    }
  }

  void _addDirectionField() {
    setState(() {
      _directionControllers.add(TextEditingController());
    });
  }

  void _removeDirectionField(int index) {
    if (_directionControllers.length > 1) {
      setState(() {
        _directionControllers[index].dispose();
        _directionControllers.removeAt(index);
      });
    }
  }

  void _addNutritionField() {
    setState(() {
      _nutritionControllers.add(TextEditingController());
    });
  }

  void _removeNutritionField(int index) {
    if (_nutritionControllers.length > 1) {
      setState(() {
        _nutritionControllers[index].dispose();
        _nutritionControllers.removeAt(index);
      });
    }
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = UserSessionService.getCurrentUser();
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to save recipes'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare image URL
      String imageUrl =
          _existingImageUrl ?? 'assets/images/recipe_placeholder.png';
      if (_recipeImage != null) {
        final uploadedUrl =
            await FirebaseService.uploadImage(_recipeImage!, 'recipes');
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
        }
      }

      // Prepare ingredients, directions, and nutritions
      final ingredients = _ingredientControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      final directions = _directionControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      final nutritions = _nutritionControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      // Create or update recipe
      final recipe = Recipe(
        id: widget.recipeToEdit?.id ?? FirebaseService.generateId(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        image: imageUrl,
        rating: widget.recipeToEdit?.rating ?? 0.0,
        prepTimeMinutes: int.tryParse(_prepTimeController.text) ?? 0,
        servings: int.tryParse(_servingsController.text) ?? 1,
        calories: int.tryParse(_caloriesController.text) ?? 0,
        fat: double.tryParse(_fatController.text),
        protein: double.tryParse(_proteinController.text),
        carbs: double.tryParse(_carbsController.text),
        ingredients: ingredients,
        directions: directions,
        nutritions: nutritions,
        authorId: user.id,
        authorName: user.name,
        difficultyLevel: _selectedDifficulty,
        dateCreated: widget.recipeToEdit?.dateCreated ?? DateTime.now(),
      );

      print('💾 Saving recipe with authorId: ${user.id} (${user.name})');
      print('📝 Recipe title: ${recipe.title}');

      bool success;
      if (widget.recipeToEdit != null) {
        success = await FirebaseService.updateRecipe(recipe);
      } else {
        final recipeId = await FirebaseService.createRecipe(recipe);
        success = recipeId != null;
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.recipeToEdit != null
                ? 'Recipe updated successfully!'
                : 'Recipe created successfully!'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception('Failed to save recipe');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving recipe: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.recipeToEdit != null ? 'Edit Recipe' : 'Create Recipe',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveRecipe,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image picker
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                      color: Colors.grey.shade100,
                    ),
                    child: _recipeImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_recipeImage!, fit: BoxFit.cover),
                          )
                        : _existingImageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: _existingImageUrl!.startsWith('assets/')
                                    ? Image.asset(_existingImageUrl!,
                                        fit: BoxFit.cover)
                                    : Image.network(_existingImageUrl!,
                                        fit: BoxFit.cover),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt,
                                      size: 50, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text('Tap to add recipe image',
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Basic Information
              const Text(
                'Basic Information',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),

              _buildTextFormField(
                controller: _titleController,
                label: 'Recipe Title',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a recipe title';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              _buildTextFormField(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 3,
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildDropdownField(
                      label: 'Category',
                      value: _selectedCategory,
                      items: _categories,
                      onChanged: (value) =>
                          setState(() => _selectedCategory = value!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdownField(
                      label: 'Difficulty',
                      value: _selectedDifficulty,
                      items: _difficulties,
                      onChanged: (value) =>
                          setState(() => _selectedDifficulty = value!),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: _prepTimeController,
                      label: 'Prep Time (minutes)',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Enter a number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextFormField(
                      controller: _servingsController,
                      label: 'Servings',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Enter a number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Nutrition Information
              const Text(
                'Nutrition Information',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: _caloriesController,
                      label: 'Calories',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextFormField(
                      controller: _fatController,
                      label: 'Fat (g)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: _proteinController,
                      label: 'Protein (g)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextFormField(
                      controller: _carbsController,
                      label: 'Carbs (g)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Ingredients
              _buildDynamicSection(
                title: 'Ingredients',
                controllers: _ingredientControllers,
                onAdd: _addIngredientField,
                onRemove: _removeIngredientField,
                hintText: 'Enter ingredient',
              ),

              const SizedBox(height: 24),

              // Directions
              _buildDynamicSection(
                title: 'Directions',
                controllers: _directionControllers,
                onAdd: _addDirectionField,
                onRemove: _removeDirectionField,
                hintText: 'Enter step',
                maxLines: 3,
              ),

              const SizedBox(height: 24),

              // Additional Nutrition Info
              _buildDynamicSection(
                title: 'Additional Nutrition Info',
                controllers: _nutritionControllers,
                onAdd: _addNutritionField,
                onRemove: _removeNutritionField,
                hintText: 'Enter nutrition fact',
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int? maxLines,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDynamicSection({
    required String title,
    required List<TextEditingController> controllers,
    required VoidCallback onAdd,
    required Function(int) onRemove,
    required String hintText,
    int? maxLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary),
            ),
            IconButton(
              onPressed: onAdd,
              icon: const Icon(Icons.add_circle, color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...controllers.asMap().entries.map((entry) {
          final index = entry.key;
          final controller = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    maxLines: maxLines ?? 1,
                    decoration: InputDecoration(
                      hintText: '$hintText ${index + 1}',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
                if (controllers.length > 1)
                  IconButton(
                    onPressed: () => onRemove(index),
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                  ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
