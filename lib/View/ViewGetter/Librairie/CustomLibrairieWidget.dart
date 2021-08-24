import 'package:flutter/material.dart';


/*    CIRCULAR INDICATOR  */

class CircularTabIndicator extends Decoration {
  final BoxPainter _painter;

  CircularTabIndicator({@required Color color, @required double radius, @required double width, @required int index})
      : _painter = _CircularPainter(color, radius, width, index);

  @override
  BoxPainter createBoxPainter([onChanged]) => _painter;
}

class _CircularPainter extends BoxPainter {
  final Paint _paint;
  final double radius;
  final double width;
  final int index;

  _CircularPainter(Color color, this.radius, this.width, this.index)
      : _paint = Paint()
          ..color = color
          ..isAntiAlias = true;


  double _ratioValue(Offset offset, ImageConfiguration cfg) {
    final double tempRatio = (offset.dx%cfg.size.width)/cfg.size.width;
    double finalRatio;
    if(tempRatio >= 0.5) finalRatio = tempRatio;
    else finalRatio = tempRatio+(0.5-tempRatio)*2;
    return (1-finalRatio)*2;
  }


  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {

    final double ratio = _ratioValue(offset, cfg);
    final Offset newOffset =
        offset + Offset(cfg.size.width / 2, cfg.size.height - radius);
        
    Rect rectangle = Rect.fromCenter(center: newOffset, width: width+ratio*100, height: 3);
    canvas.drawRRect(RRect.fromRectAndRadius(rectangle, Radius.circular(20)), _paint);
  }
}