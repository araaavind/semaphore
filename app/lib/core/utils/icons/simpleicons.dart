// ignore_for_file: constant_identifier_names

import 'package:flutter/widgets.dart';

class SimpleIconsIconData extends IconData {
  const SimpleIconsIconData(super.code) : super(fontFamily: 'SimpleIcons');
}

class SimpleIcons {
  /// Substack icon
  static const substack = SimpleIconsIconData(0xf4bd);

  /// YouTube icon
  static const youtube = SimpleIconsIconData(0xf6a0);
}
