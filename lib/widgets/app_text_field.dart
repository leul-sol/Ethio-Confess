import 'package:flutter/material.dart';

Widget appTextField({
  String text = "",
  String iconName = "",
  String hintText = "",
  bool obsecureText = false,
}) {
  return Container(
    padding: const EdgeInsets.only(left: 25, right: 25),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF3A6FE5),
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Container(
          width: 325,
          height: 50,
          decoration: appBoxDecorationTextField(),
          child: TextField(
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.grey),
              border: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.transparent,
                ),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.transparent,
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.transparent,
                ),
              ),
            ),
            onChanged: (value) {},
            maxLines: 1,
            autocorrect: false,
            obscureText: obsecureText,
          ),
        ),
      ],
    ),
  );
}

BoxDecoration appBoxDecorationTextField(
    {Color color = Colors.white,
    double radius = 15,
    Color borderColor = Colors.black45}) {
  return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: borderColor));
}
