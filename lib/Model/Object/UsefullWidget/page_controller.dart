import 'package:flutter/material.dart';


class CustomPageController extends PageController {

  CustomPageController({
    initialPage = 0,
    keepPage = true,
    viewportFraction = 1.0,
  }) : super(initialPage: initialPage, keepPage: keepPage, viewportFraction: viewportFraction);

  bool blockNotifier = false;
  // int tempIndex = 0;

  @override
  void jumpToPage(int page) {
    print('jumpTopage');
    blockNotifier = true;
    // tempIndex = page;
    super.jumpToPage(page);
    blockNotifier = false;
  }

  // @override
  // Future<void> previousPage({ @required Duration duration, @required Curve curve }) async {
  //   blockNotifier = true;
  //   await super.previousPage(duration: duration, curve: curve);
  //   blockNotifier = false;
  // }

  // @override
  // Future<void> nextPage({ @required Duration duration, @required Curve curve }) async {
  //   blockNotifier = true;
  //   await super.nextPage(duration: duration, curve: curve);
  //   blockNotifier = false;
  // }

  @override
  Future<void> animateToPage(
    int page, {
    @required Duration duration,
    @required Curve curve
    }) async {
    blockNotifier = true;
    // tempIndex = page;
    await super.animateToPage(page, duration: duration, curve: curve);
    blockNotifier = false;
  }
  

}