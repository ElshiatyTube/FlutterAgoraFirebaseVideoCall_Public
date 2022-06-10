import 'package:flutter/cupertino.dart';

class DefaultCircleImage extends StatelessWidget {
  final Widget image;
  final Color bgColor;
  final bool center;
  final double width;
  final double height;
  const DefaultCircleImage({
    Key? key, required this.image,
    required this.bgColor,
    this.center = false,
    this.width = 45,
    this.height = 45
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: center? Center(child: image) : Padding(
        padding: const EdgeInsets.all(13.0),
        child: image,
      ),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
      ),
    );
  }
}
