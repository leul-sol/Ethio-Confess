import 'package:flutter/material.dart';
import 'package:ethioconfess/screens/text_detail.dart';
import '../utils/text_preview.dart';

class ExpandableText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const ExpandableText({
    Key? key,
    required this.text,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TextDetailPage(text: text),
          ),
        );
      },
      child: Text(
        textPreview(text, 100),
        style: style,
      ),
    );
  }
}
