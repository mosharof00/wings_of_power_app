import 'package:flutter/cupertino.dart';

import '../../../gen/assets.gen.dart';

class BgHeaderSky extends StatelessWidget {
  const BgHeaderSky({super.key, this.top, this.left, this.right});

  final double? top;
  final double? left;
  final double? right;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top ?? 10,
      left: left ?? -10,
      right: right ?? -10,
      child: Assets.backgrounds.bgHomeSky.image(
        fit: BoxFit.cover,
        // height: 110.h,
      ),
    );
  }
}
