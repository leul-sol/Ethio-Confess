import 'package:flutter/material.dart';

class VentTextInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final int characterCount;
  final int maxCharacters;
  final TextStyle currentStyle;
  final TextAlign textAlignment;
  final Function(String) onChanged;

  const VentTextInput({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.characterCount,
    required this.maxCharacters,
    required this.currentStyle,
    required this.textAlignment,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // color: const Color(0xFF4A90E2).withAlpha(50),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: const Color(0xFF4A90E2).withAlpha(70), width: 1),
        ),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                maxLength: maxCharacters,
                maxLines: null,
                expands: true,
                textAlign: textAlignment,
                style: currentStyle,
                decoration: const InputDecoration(
                  hintText: 'Vent Here ...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                  counter: SizedBox.shrink(),
                ),
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
