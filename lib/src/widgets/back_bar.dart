import 'package:flutter/material.dart'
    show
        AppBar,
        BuildContext,
        GestureTapCallback,
        InkWell,
        Key,
        PreferredSizeWidget,
        Size,
        StatelessWidget,
        Widget,
        kToolbarHeight,
        required;

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
