import 'package:flutter/material.dart';

class Info extends StatelessWidget {
  final String left, right;
  final Function onTap;
  Info(
      {Key key,
      @required this.left,
      @required this.right,
      @required this.onTap})
      : super(key: key);
  @override
  Widget build(final BuildContext context) {
    return Card(
        child: InkWell(
            onTap: onTap,
            child: Container(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                          child: Text(left,
                              softWrap: false,
                              style: const TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                              overflow: TextOverflow.fade,
                              maxLines: 1)),
                      Align(
                          child: Text(right,
                              style: const TextStyle(
                                  fontSize: 16.0, color: Colors.black)),
                          alignment: Alignment.centerRight)
                    ]))));
  }
}

class InputText extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType inputType;
  final bool autofocus;
  final bool obscureText;
  final String helpText;
  const InputText(
      {@required final Key key,
      @required final this.controller,
      @required final this.inputType,
      @required final this.obscureText,
      @required final this.helpText,
      @required final this.autofocus})
      : super(key: key);

  @override
  Widget build(final BuildContext context) {
    return TextFormField(
      key: key,
      controller: controller,
      keyboardType: inputType,
      autofocus: autofocus,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: helpText,
        contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );
  }
}
