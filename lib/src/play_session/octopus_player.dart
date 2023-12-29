import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';

class OctopusPlayer extends SpriteComponent
    with HasGameRef, CollisionCallbacks {
  /// Pixels/s
  double maxSpeed = 300.0;
  late final Vector2 _lastSize = size.clone();
  late final Transform2D _lastTransform = transform.clone();

  final JoystickComponent joystick;

  OctopusPlayer(this.joystick)
      : super(size: Vector2.all(100.0), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    final image = await Flame.images.load('octopus.png');
    final spriteSheet =
        SpriteSheet.fromColumnsAndRows(image: image, columns: 5, rows: 4);
    final octopusAnimation =
        spriteSheet.createAnimation(row: 0, stepTime: 0.1, to: 17);
    final spriteSize = Vector2(80.0, 90.0);
    final octopusComponent =
        SpriteAnimationComponent(animation: octopusAnimation, size: spriteSize);
    sprite = Sprite(image, srcSize: Vector2.zero());
    add(RectangleHitbox());
    add(octopusComponent);
  }

  @override
  void update(double dt) {
    if (!joystick.delta.isZero() && activeCollisions.isEmpty) {
      _lastSize.setFrom(size);
      _lastTransform.setFrom(transform);
      position.add(joystick.relativeDelta * maxSpeed * dt);
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    transform.setFrom(_lastTransform);
    size.setFrom(_lastSize);
  }
}
