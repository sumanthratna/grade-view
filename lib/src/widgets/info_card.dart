import 'package:flutter/material.dart'
    show
        Align,
        Alignment,
        BuildContext,
        Card,
        Colors,
        Container,
        EdgeInsets,
        Flexible,
        FontWeight,
        GestureTapCallback,
        InkWell,
        Key,
        MainAxisAlignment,
        Row,
        StatelessWidget,
        Text,
        TextOverflow,
        TextStyle,
        Widget,
        required;

class InfoCard extends StatelessWidget {
  final String left, right;
  final GestureTapCallback onTap;

  InfoCard(
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
