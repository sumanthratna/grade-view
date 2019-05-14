import 'package:flutter/material.dart'
    show
        BuildContext,
        DropdownButtonFormField,
        DropdownMenuItem,
        FormFieldSetter,
        FormFieldValidator,
        InputDecoration,
        Key,
        State,
        StatefulWidget,
        Widget,
        required;

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
      final this.validator,
      @required final this.decoration,
      final this.initialValue})
      : super(key: key);

  @override
  State<DropdownFormField> createState() => _DropdownFormFieldState();
}

class _DropdownFormFieldState extends State<DropdownFormField> {
  String _value;
  @override
  Widget build(final BuildContext context) => DropdownButtonFormField<String>(
        value: _value,
        items: widget.items,
        onSaved: widget.onSaved,
        decoration: widget.decoration,
        validator: widget.validator ?? (final String _) => null,
        onChanged: (final String value) => setState(() => _value = value),
      );

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }
}
