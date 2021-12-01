import 'package:flutter/material.dart';
import 'package:simple_pong/ball.dart';
import 'package:simple_pong/bat.dart';
import 'dart:math';

enum Direction { up, down, left, right }

class Pong extends StatefulWidget {
  @override
  _PongState createState() => _PongState();
}

class _PongState extends State<Pong> with SingleTickerProviderStateMixin {
  // Available space on the screen (Boundary of Game)
  double width = 0, height = 0;

  // Horizontal and Vertical Position of the ball
  double posX = 0, posY = 0;

  // Bat Size
  double batWidth = 0, batHeight = 0;

  // Bat horizontal Position
  double batPosition = 0;

  // For Ball Animation
  Animation<double> animation;
  AnimationController controller;

  // Ball Direction
  Direction vDir = Direction.down;
  Direction hDir = Direction.right;

  // Ball Speed
  double increment = 5;

  @override
  void initState() {
    posX = 0;
    posY = 0;
    controller = AnimationController(
      duration: const Duration(minutes: 10000),
      vsync: this,
    );

    animation = Tween<double>(begin: 0, end: 100).animate(controller);
    animation.addListener(() {
      safeSetState(() {
        (hDir == Direction.right) ? posX += increment : posX -= increment;
        (vDir == Direction.down) ? posY += increment : posY -= increment;
      });
      checkBorders();
    });

    controller.forward();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      height = constraints.maxHeight;
      width = constraints.maxWidth;
      batWidth = width / 5;
      batHeight = height / 20;
      return Stack(
        children: <Widget>[
          Positioned(
            child: Ball(),
            top: posY,
            left: posX,
          ),
          Positioned(
            bottom: 0,
            left: batPosition,
            child: GestureDetector(
                onHorizontalDragUpdate: (DragUpdateDetails update) =>
                    moveBat(update),
                child: Bat(batWidth, batHeight)),
          )
        ],
      );
    });
  }

  void checkBorders() {
    // Diameter of the ball
    double diameter = 50;

    if (posX <= 0 && hDir == Direction.left) {
      hDir = Direction.right;
    }
    if (posX >= width - diameter && hDir == Direction.right) {
      hDir = Direction.left;
    }
    if (posY >= height - diameter - batHeight && vDir == Direction.down) {
      // check if the bat is here, otherwise loose
      if (posX >= (batPosition - diameter) &&
          posX <= (batPosition + batWidth + diameter)) {
        vDir = Direction.up;
      } else {
        controller.stop();
        dispose();
      }
    }

    if (posY <= 0 && vDir == Direction.up) {
      vDir = Direction.down;
    }
  }

  moveBat(DragUpdateDetails update) {
    /* delta contains the distance moved during the drag operation
    * dx is the horizontal delta
    */
    safeSetState(() {
      batPosition += update.delta.dx;
    });
  }

  void safeSetState(Function function) {
    if (mounted && controller.isAnimating) {
      setState(() {
        function();
      });
    }
  }

  double randomNumber() {
    //this is a number between 0.5 and 1.5;
    var ran = Random();
    int myNum = ran.nextInt(101);
    return (50 + myNum) / 100;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
