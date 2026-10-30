import 'package:flutter/material.dart';

import 'brand_loader.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) => Center(
        child: BrandLoader(
          size: 48,
          reduceMotion: MediaQuery.disableAnimationsOf(context),
        ),
      );
}
