import 'package:flutter/material.dart';
import 'package:ethioconfess/widgets/text_widget.dart';

AppBar buidAppBar() {
  return AppBar(
    bottom: PreferredSize(
      preferredSize: Size.fromHeight(10),
      child: Container(
        height: 10,
      ),
    ),
    title: text36Normal(text: "Let's Sign You in", color: Colors.black),
  );
}

//not for my case

Widget thirdPartyLogin() {
  return Container(
    margin: const EdgeInsets.only(left: 80, right: 80, bottom: 80),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _loginButton("assets/icons/google.png"),
        _loginButton("assets/icons/facebook.png"),
        _loginButton("assets/icons/apple.png"),
      ],
    ),
  );
}

Widget _loginButton(String imagePath) {
  return GestureDetector(
    onTap: () {},
    child: Container(
      width: 40,
      height: 40,
      child: Image.asset(imagePath),
    ),
  );
}

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
        text14Normal(text: text),
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
