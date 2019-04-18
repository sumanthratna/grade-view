import 'package:flutter/material.dart'
    show
        Brightness,
        StatefulWidget,
        DropdownMenuItem,
        FormFieldSetter,
        FormFieldValidator,
        InputDecoration,
        Key,
        required,
        State,
        StatelessWidget,
        GestureTapCallback,
        Widget,
        BuildContext,
        Card,
        InkWell,
        Container,
        Row,
        EdgeInsets,
        MainAxisAlignment,
        Flexible,
        Text,
        TextStyle,
        Colors,
        FontWeight,
        TextOverflow,
        Align,
        Alignment,
        TextEditingController,
        TextInputType,
        TextFormField,
        OutlineInputBorder,
        BorderRadius,
        Stack,
        Opacity,
        ModalBarrier,
        Center,
        CircularProgressIndicator,
        AlwaysStoppedAnimation,
        Color,
        PreferredSizeWidget,
        AppBar,
        Size,
        kToolbarHeight,
        DropdownButtonFormField;

class BackBar extends StatelessWidget implements PreferredSizeWidget {
  final GestureTapCallback onTap;
  final AppBar appBar;

  BackBar(
      {final Key key, @required final this.onTap, @required final this.appBar})
      : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(final BuildContext context) =>
      InkWell(onTap: onTap, child: appBar);
}

class DropdownFormField extends StatefulWidget {
  final List<DropdownMenuItem> items;
  final FormFieldSetter<String> onSaved;
  final FormFieldValidator<String> validator;
  final InputDecoration decoration;
  final String initialValue;

  DropdownFormField(
      {final Key key,
      @required final this.items,
      @required final this.onSaved,
      @required final this.validator,
      @required final this.decoration,
      final this.initialValue})
      : super(key: key);

  @override
  State<DropdownFormField> createState() => _DropdownFormFieldState();
}

class Info extends StatelessWidget {
  final String left, right;
  final GestureTapCallback onTap;

  Info(
      {final Key key,
      @required final this.left,
      @required final this.right,
      @required final this.onTap})
      : super(key: key);

  @override
  Widget build(final BuildContext context) => Card(
      child: InkWell(
          onTap: onTap,
          child: Container(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                        child: Text(left ?? '',
                            softWrap: false,
                            style: const TextStyle(
                                fontSize: 16.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                            overflow: TextOverflow.fade,
                            maxLines: 1)),
                    Align(
                        child: Text(right ?? '',
                            style: const TextStyle(
                                fontSize: 16.0, color: Colors.black)),
                        alignment: Alignment.centerRight)
                  ]))));
}

class InputText extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool autofocus;
  final bool obscureText;
  final String helpText;
  const InputText(
      {final Key key,
      @required final this.controller,
      @required final this.keyboardType,
      @required final this.obscureText,
      @required final this.helpText,
      @required final this.autofocus})
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
      );
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({final Key key}) : super(key: key);

  @override
  Widget build(final BuildContext context) => Stack(children: <Widget>[
        Container(),
        const Opacity(
            child: ModalBarrier(dismissible: false, color: Colors.transparent),
            opacity: 0.3),
        const Center(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
      ]);
}

class _DropdownFormFieldState extends State<DropdownFormField> {
  String _value;
  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(final BuildContext context) => DropdownButtonFormField<String>(
        value: _value,
        items: widget.items,
        onSaved: widget.onSaved,
        decoration: widget.decoration,
        validator: widget.validator,
        onChanged: (final String value) => setState(() => _value = value),
      );
}
