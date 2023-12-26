import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/painting.dart';

import 'octopus_player.dart';

class OctopusGame extends FlameGame {
  late final OctopusPlayer player;
  late final JoystickComponent joystick;

  @override
  Future<void> onLoad() async {
    final knobPaint = BasicPalette.blue.withAlpha(200).paint();
    final backgroundPaint = BasicPalette.blue.withAlpha(100).paint();
    joystick = JoystickComponent(
      knob: CircleComponent(radius: 30, paint: knobPaint),
      background: CircleComponent(radius: 100, paint: backgroundPaint),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );
    player = OctopusPlayer(joystick);

    world.add(player);
    camera.viewport.add(joystick);
  }
}
