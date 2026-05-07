import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

import '../../core/models/pet_character.dart';
import '../../core/models/pet_state.dart';
import 'pet_widget.dart';

/// Name of the Rive state machine and its weather input — must match
/// what the designer exports from Rive Studio.
const _kStateMachine = 'WeatherMachine';
const _kWeatherInput = 'weatherIndex';

/// Variant-aware animated pet backed by Rive.
///
/// Each character has one `.riv` file per variant at
/// `assets/rive/{id}/{variant}.riv`. The file must contain a state machine
/// named [_kStateMachine] with a Number input named [_kWeatherInput] that
/// accepts the integer value of [PetState.index]:
///
///   0 sunny · 1 cloudy · 2 rainy · 3 snowy · 4 stormy · 5 windy
///   6 hot · 7 cold · 8 night · 9 foggy · 10 loading
///
/// Falls back to the animated emoji [PetWidget] when the `.riv` file is
/// absent (e.g. during development before assets are dropped in).
class PetAnimationWidget extends StatefulWidget {
  const PetAnimationWidget({
    super.key,
    required this.petId,
    required this.weatherState,
    this.variant = 'default',
    this.size = 200,
  });

  final String petId;
  final PetState weatherState;
  final String variant;
  final double size;

  @override
  State<PetAnimationWidget> createState() => _PetAnimationWidgetState();
}

class _PetAnimationWidgetState extends State<PetAnimationWidget> {
  SMINumber? _weatherInput;
  late Future<bool> _assetCheck;
  late String _resolvedVariant;
  late PetCharacter _character;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void didUpdateWidget(PetAnimationWidget old) {
    super.didUpdateWidget(old);
    if (old.petId != widget.petId || old.variant != widget.variant) {
      // Different file — re-check asset and reload Rive.
      _weatherInput = null;
      _refresh();
    } else if (old.weatherState != widget.weatherState) {
      // Same file, different state — update SMI input directly (no rebuild).
      _weatherInput?.value = widget.weatherState.index.toDouble();
    }
  }

  void _refresh() {
    _character = PetCharacter.findById(widget.petId);
    _resolvedVariant = _character.availableVariants.contains(widget.variant)
        ? widget.variant
        : _character.availableVariants.first;
    _assetCheck = _checkAsset(_character.rivePath(variant: _resolvedVariant));
    setState(() {});
  }

  Future<bool> _checkAsset(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (_) {
      return false;
    }
  }

  void _onRiveInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(artboard, _kStateMachine);
    if (controller == null) return;
    artboard.addController(controller);
    _weatherInput = controller.findSMI<SMINumber>(_kWeatherInput);
    _weatherInput?.value = widget.weatherState.index.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: FutureBuilder<bool>(
        future: _assetCheck,
        builder: (context, snapshot) {
          if (snapshot.data == true) {
            return RiveAnimation.asset(
              _character.rivePath(variant: _resolvedVariant),
              stateMachines: const [_kStateMachine],
              onInit: _onRiveInit,
              fit: BoxFit.contain,
            );
          }
          return PetWidget(
            character: _character,
            petState: widget.weatherState,
            size: widget.size,
          );
        },
      ),
    );
  }
}
