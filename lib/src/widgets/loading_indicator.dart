import 'package:flutter/material.dart'
    show
        AlwaysStoppedAnimation,
        BuildContext,
        Center,
        CircularProgressIndicator,
        Color,
        Colors,
        Container,
        Key,
        ModalBarrier,
        Opacity,
        Stack,
        StatelessWidget,
        Widget;

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
