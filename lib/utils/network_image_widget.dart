import 'package:cached_network_image/cached_network_image.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/themes/responsive.dart';
import 'package:flutter/material.dart';

class NetworkImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final Widget? errorWidget;
  final BoxFit? fit;
  final double? borderRadius;
  final Color? color;

  const NetworkImageWidget({
    super.key,
    this.height,
    this.width,
    this.fit,
    required this.imageUrl,
    this.borderRadius,
    this.errorWidget,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit ?? BoxFit.fitWidth,
      height: height ?? Responsive.height(8, context),
      width: width ?? Responsive.width(15, context),
      color: color,
      progressIndicatorBuilder: (context, url, downloadProgress) => Constant.loader(context),
      errorWidget: (context, url, error) =>
          errorWidget ??
              Image.network(
                Constant.userPlaceHolder,
                fit: fit ?? BoxFit.cover,
                height: height ?? Responsive.height(8, context),
                width: width ?? Responsive.width(15, context),
              ),
    );
  }
}
