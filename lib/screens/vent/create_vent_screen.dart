import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../providers/auth_provider.dart';
import '../../providers/biography_providers.dart';
import '../../providers/category_provider.dart';
import '../../providers/vent_provider.dart';
import '../../widgets/vent_widget/vent_post_button.dart';
import '../../widgets/vent_widget/vent_text_input.dart';

class CreateVentScreen extends ConsumerStatefulWidget {
  final String? preSelectedCategoryId;
  
  const CreateVentScreen({Key? key, this.preSelectedCategoryId}) : super(key: key);

  @override
  CreateVentScreenState createState() => CreateVentScreenState();
}

class CreateVentScreenState extends ConsumerState<CreateVentScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  int get _characterCount => _controller.text.length;
  final int _maxCharacters = 5000;
  String? _selectedCategoryId;

  // Track text formatting
  final bool _isBold = false;
  final bool _isItalic = false;
  final bool _isUnderlined = false;
  final TextAlign _textAlignment = TextAlign.left;

  // Style getters
  TextStyle get _currentStyle => TextStyle(
        fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
        fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
        decoration:
            _isUnderlined ? TextDecoration.underline : TextDecoration.none,
      );

  // Track loading state
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-select category if provided
    if (widget.preSelectedCategoryId != null) {
      _selectedCategoryId = widget.preSelectedCategoryId;
    }
    
    // Fetch categories when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryProvider.notifier).fetchCategories();
    });
  }

  Widget _buildCategoryDropdown(CategoryState categoryState) {
    if (categoryState.isLoading) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey[300]!),
          ),
        ),
      );
    }

    if (categoryState.error != null) {
      return Container(
        height: 60,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Failed to load categories. Please try again.',
                style: TextStyle(color: Colors.red[700]),
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(categoryProvider.notifier).fetchCategories();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: _selectedCategoryId,
      decoration: InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: const Color(0xFF4A90E2).withAlpha(70),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: const Color(0xFF4A90E2).withAlpha(70),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: const Color(0xFF4A90E2).withAlpha(70),
            width: 1,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      dropdownColor: Colors.white,
      menuMaxHeight: 300,
      isExpanded: true,
      itemHeight: 48,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black87,
      ),
      selectedItemBuilder: (BuildContext context) {
        return categoryState.categories.map<Widget>((category) {
          return Container(
            alignment: Alignment.centerLeft,
            child: Text(
              category.categoryName,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList();
      },
      items: categoryState.categories.map((category) {
        return DropdownMenuItem<String>(
          value: category.id,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              category.categoryName,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategoryId = value;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Vent',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildCategoryDropdown(categoryState),
          ),
          VentTextInput(
            controller: _controller,
            focusNode: _focusNode,
            characterCount: _characterCount,
            maxCharacters: _maxCharacters,
            currentStyle: _currentStyle,
            textAlignment: _textAlignment,
            onChanged: (text) {
              setState(() {});
            },
          ),
          VentPostButton(
            isLoading: _isLoading,
            onPressed: (_characterCount > 0 &&
                    _characterCount <= _maxCharacters &&
                    !_isLoading &&
                    _selectedCategoryId != null)
                ? () async {
                    setState(() {
                      _isLoading = true;
                    });

                    try {
                      await ref.read(createVentProvider({
                        'content': _controller.text,
                        'category': _selectedCategoryId!,
                      }).future);
                      
                      if (mounted) {
                        Navigator.pop(context, true); // Return true on success
                      }
                    } catch (error) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to post vent. Try again.'),
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
                : null,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
