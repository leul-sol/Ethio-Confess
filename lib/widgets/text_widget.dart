import 'package:flutter/material.dart';

// Widget text24Normal({String text = "", Color color = AppColors.primaryText}) {
//   return Text(
//     text,
//     style: TextStyle(
//       color: color,
//       fontSize: 24,
//       fontWeight: FontWeight.normal,
//     ),
//   );
// }

Widget text16Normal({String text = "", Color color = Colors.white}) {
  return Text(
    text,
    textAlign: TextAlign.center,
    style: TextStyle(
      color: color,
      fontSize: 16,
      fontWeight: FontWeight.normal,
    ),
  );
}

Widget text14Normal({String text = "", Color color = Colors.black}) {
  return Text(
    text,
    textAlign: TextAlign.center,
    style: TextStyle(
      color: color,
      fontSize: 16,
      fontWeight: FontWeight.normal,
    ),
  );
}

Widget text32Normal({String text = "", Color color = Colors.black}) {
  return Text(
    text,
    textAlign: TextAlign.start,
    style: TextStyle(
      color: color,
      fontSize: 30,
      fontWeight: FontWeight.normal,
    ),
  );
}

Widget text36Normal({String text = "", Color color = Colors.black}) {
  return Text(
    text,
    textAlign: TextAlign.start,
    style: TextStyle(color: color, fontSize: 32, fontWeight: FontWeight.w500),
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
