import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:game_forge2d/component/game.dart';

void main() {
  runApp(
    const GameWidget.controlled(
      gameFactory: MyPhysicsGame.new,
    ),
  );
}
