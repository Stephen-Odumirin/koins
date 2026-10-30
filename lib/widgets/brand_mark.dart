import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../l10n/app_localizations.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/login_logo.svg',
      width: size,
      height: size,
      semanticsLabel: AppLocalizations.of(context)!.brandLogoLabel,
    );
  }
}
