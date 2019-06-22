import 'package:flutter/material.dart'
    show
        Align,
        Alignment,
        BuildContext,
        Card,
        Colors,
        Container,
        EdgeInsets,
        Expanded,
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
                    Align(
                        child: Text(left ?? '',
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            maxLines: 1,
                            style: const TextStyle(
                                fontSize: 16.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                        alignment: Alignment.centerLeft),
                    Expanded(
                        child: Align(
                            child: Text(right ?? '',
                                softWrap: false,
                                overflow: TextOverflow.fade,
                                maxLines: 1,
                                style: const TextStyle(
                                    fontSize: 16.0, color: Colors.black)),
                            alignment: Alignment.centerRight))
                  ]))));
}
