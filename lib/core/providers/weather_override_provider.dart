import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pet_state.dart';

/// When non-null, overrides the live weather-derived [PetState] for the
/// entire app — cat animation, theme gradient, and conditions display all
/// update as if this were the real weather condition.
///
/// Set from Settings → Preview Mode. Cleared by toggling Preview Mode off.
final weatherOverrideProvider = StateProvider<PetState?>((ref) => null);
