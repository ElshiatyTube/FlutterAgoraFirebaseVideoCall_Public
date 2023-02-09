import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


showToast(
    {required String msg}) {
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 5,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 16.0);
}

printDebug(String message) {
  if (kDebugMode) debugPrint(message);
}



Widget defaultLinearProgressIndicator() {
  return const ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(5.0)),
      child: LinearProgressIndicator(
        color: Colors.grey,
      ));
}

class DefaultNetworkImageWidget extends StatelessWidget {
  final double? height;
  final double? width;
  final String imageUrl;
  final BoxFit fit;
  final Widget placeHolderWidget;
  final ImageWidgetBuilder? imageBuilder;
  final bool cacheImage;
  const DefaultNetworkImageWidget({Key? key, this.height, required this.imageUrl, this.fit=BoxFit.cover, required this.placeHolderWidget, this.imageBuilder, this.width=double.infinity, this.cacheImage=true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return cacheImage ? CachedNetworkImage(
      width: width,
      height: height,
      imageUrl: imageUrl,
      fit:  fit,
      imageBuilder: imageBuilder,
      placeholder: (context, url) => placeHolderWidget,
      errorWidget: (context, url, error) => const Icon(Icons.error),
    ) : Image.network(
      imageUrl,
      height: height,
      width: width,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return SizedBox(
            height: height,
            child: placeHolderWidget);
      },
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Icon(Icons.error),
        );
      },
    );

  }
}