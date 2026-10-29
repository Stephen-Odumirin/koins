import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/brand/logo.svg',
      width: size,
      height: size,
      semanticsLabel: 'Savings app logo',
    );
  }
}
