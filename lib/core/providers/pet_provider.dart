import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The active Lottie variant (e.g. 'default', 'ice').
/// Defaults to 'default'; update when the user picks a skin.
final selectedVariantProvider = StateProvider<String>((_) => 'default');
