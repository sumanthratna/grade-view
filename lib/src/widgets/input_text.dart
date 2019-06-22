import 'package:flutter/material.dart'
    show
        BorderRadius,
        Brightness,
        BuildContext,
        EdgeInsets,
        InputDecoration,
        Key,
        OutlineInputBorder,
        StatelessWidget,
        TextEditingController,
        TextFormField,
        TextInputType,
        required,
        Widget;

class InputText extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool autofocus;
  final bool obscureText;
  final String helpText;
  final bool enabled;
  const InputText(
      {final Key key,
      @required final this.controller,
      @required final this.keyboardType,
      @required final this.obscureText,
      @required final this.helpText,
      @required final this.autofocus,
      @required final this.enabled})
      : super(key: key);

  @override
  Widget build(final BuildContext context) => TextFormField(
        key: key,
        controller: controller,
        keyboardType: keyboardType,
        keyboardAppearance: Brightness.dark,
        autofocus: autofocus,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: helpText,
          contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
        enabled: enabled,
      );
}
