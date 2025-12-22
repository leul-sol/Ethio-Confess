import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/vent_widget/vent_post_button.dart';
import '../../widgets/vent_widget/vent_text_input.dart';

class EditContentScreen extends ConsumerStatefulWidget {
  final String initialContent;
  final Future<void> Function(String) onUpdate;

  const EditContentScreen({
    Key? key,
    required this.initialContent,
    required this.onUpdate,
  }) : super(key: key);

  @override
  ConsumerState<EditContentScreen> createState() => _EditContentScreenState();
}

class _EditContentScreenState extends ConsumerState<EditContentScreen> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;

  int get _characterCount => _controller.text.length;
  final int _maxCharacters = 100000;

  // Track text formatting (matching CreateVentScreen)
  final bool _isBold = false;
  final bool _isItalic = false;
  final bool _isUnderlined = false;
  final TextAlign _textAlignment = TextAlign.left;

  TextStyle get _currentStyle => TextStyle(
        fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
        fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
        decoration:
            _isUnderlined ? TextDecoration.underline : TextDecoration.none,
      );

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onUpdate(_controller.text);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      print(error); // Log the error for debugging
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update vent. Try again.'),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit',
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
            onPressed: (_characterCount > 0 && !_isLoading)
                ? _handleUpdate
                : null,
            buttonText: 'Update', // Custom text for edit mode
          ),
        ],
      ),
    );
  }
}
