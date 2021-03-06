// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

import 'states.dart';

void main() {
  testWidgets('ScrollController control test', (WidgetTester tester) async {
    final ScrollController controller = new ScrollController();

    await tester.pumpWidget(new ListView(
      controller: controller,
      children: kStates.map<Widget>((String state) {
        return new Container(
          height: 200.0,
          child: new Text(state),
        );
      }).toList()
    ));

    double realOffset() {
      return tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels;
    }

    expect(controller.offset, equals(0.0));
    expect(realOffset(), equals(controller.offset));

    controller.jumpTo(653.0);

    expect(controller.offset, equals(653.0));
    expect(realOffset(), equals(controller.offset));

    await tester.pump();

    expect(controller.offset, equals(653.0));
    expect(realOffset(), equals(controller.offset));

    controller.animateTo(326.0, duration: const Duration(milliseconds: 300), curve: Curves.ease);
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(controller.offset, equals(326.0));
    expect(realOffset(), equals(controller.offset));

    await tester.pumpWidget(new ListView(
      key: const Key('second'),
      controller: controller,
      children: kStates.map<Widget>((String state) {
        return new Container(
          height: 200.0,
          child: new Text(state),
        );
      }).toList()
    ));

    expect(controller.offset, equals(0.0));
    expect(realOffset(), equals(controller.offset));

    controller.jumpTo(653.0);

    expect(controller.offset, equals(653.0));
    expect(realOffset(), equals(controller.offset));

    final ScrollController controller2 = new ScrollController();

    await tester.pumpWidget(new ListView(
      key: const Key('second'),
      controller: controller2,
      children: kStates.map<Widget>((String state) {
        return new Container(
          height: 200.0,
          child: new Text(state),
        );
      }).toList()
    ));

    expect(() => controller.offset, throwsAssertionError);
    expect(controller2.offset, equals(653.0));
    expect(realOffset(), equals(controller2.offset));

    expect(() => controller.jumpTo(120.0), throwsAssertionError);
    expect(() => controller.animateTo(132.0, duration: const Duration(milliseconds: 300), curve: Curves.ease), throwsAssertionError);

    await tester.pumpWidget(new ListView(
      key: const Key('second'),
      controller: controller2,
      physics: const BouncingScrollPhysics(),
      children: kStates.map<Widget>((String state) {
        return new Container(
          height: 200.0,
          child: new Text(state),
        );
      }).toList()
    ));

    expect(controller2.offset, equals(653.0));
    expect(realOffset(), equals(controller2.offset));

    controller2.jumpTo(432.0);

    expect(controller2.offset, equals(432.0));
    expect(realOffset(), equals(controller2.offset));

    await tester.pump();

    expect(controller2.offset, equals(432.0));
    expect(realOffset(), equals(controller2.offset));
  });

  testWidgets('ScrollController control test', (WidgetTester tester) async {
    final ScrollController controller = new ScrollController(
      initialScrollOffset: 209.0,
    );

    await tester.pumpWidget(new GridView.count(
      crossAxisCount: 4,
      controller: controller,
      children: kStates.map<Widget>((String state) => new Text(state)).toList(),
    ));

    double realOffset() {
      return tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels;
    }

    expect(controller.offset, equals(209.0));
    expect(realOffset(), equals(controller.offset));

    controller.jumpTo(105.0);

    await tester.pump();

    expect(controller.offset, equals(105.0));
    expect(realOffset(), equals(controller.offset));

    await tester.pumpWidget(new GridView.count(
      crossAxisCount: 2,
      controller: controller,
      children: kStates.map<Widget>((String state) => new Text(state)).toList(),
    ));

    expect(controller.offset, equals(105.0));
    expect(realOffset(), equals(controller.offset));
  });

  testWidgets('DrivenScrollActivity ending after dispose', (WidgetTester tester) async {
    final ScrollController controller = new ScrollController();

    await tester.pumpWidget(new ListView(
      controller: controller,
      children: <Widget>[ new Container(height: 200000.0) ],
    ));

    controller.animateTo(1000.0, duration: const Duration(seconds: 1), curve: Curves.linear);

    await tester.pump(); // Start the animation.

    // We will now change the tree on the same frame as the animation ends.
    await tester.pumpWidget(new Container(), const Duration(seconds: 2));
  });

  testWidgets('Read operations on ScrollControllers with no positions fail', (WidgetTester tester) async {
    final ScrollController controller = new ScrollController();
    expect(() => controller.offset, throwsAssertionError);
    expect(() => controller.position, throwsAssertionError);
  });

  testWidgets('Read operations on ScrollControllers with more than one position fail', (WidgetTester tester) async {
    final ScrollController controller = new ScrollController();
    await tester.pumpWidget(new ListView(
      children: <Widget>[
        new Container(
          constraints: const BoxConstraints(maxHeight: 500.0),
          child: new ListView(
            controller: controller,
            children: kStates.map<Widget>((String state) {
              return new Container(height: 200.0, child: new Text(state));
            }).toList(),
          ),
        ),
        new Container(
          constraints: const BoxConstraints(maxHeight: 500.0),
          child: new ListView(
            controller: controller,
            children: kStates.map<Widget>((String state) {
              return new Container(height: 200.0, child: new Text(state));
            }).toList(),
          ),
        ),
      ],
    ));

    expect(() => controller.offset, throwsAssertionError);
    expect(() => controller.position, throwsAssertionError);
  });

  testWidgets('Write operations on ScrollControllers with no positions fail', (WidgetTester tester) async {
    final ScrollController controller = new ScrollController();
    expect(() => controller.animateTo(1.0, duration: const Duration(seconds: 1), curve: Curves.linear), throwsAssertionError);
    expect(() => controller.jumpTo(1.0), throwsAssertionError);
  });

  testWidgets('Write operations on ScrollControllers with more than one position do not throw', (WidgetTester tester) async {
    final ScrollController controller = new ScrollController();
    await tester.pumpWidget(new ListView(
      children: <Widget>[
        new Container(
          constraints: const BoxConstraints(maxHeight: 500.0),
          child: new ListView(
            controller: controller,
            children: kStates.map<Widget>((String state) {
              return new Container(height: 200.0, child: new Text(state));
            }).toList(),
          ),
        ),
        new Container(
          constraints: const BoxConstraints(maxHeight: 500.0),
          child: new ListView(
            controller: controller,
            children: kStates.map<Widget>((String state) {
              return new Container(height: 200.0, child: new Text(state));
            }).toList(),
          ),
        ),
      ],
    ));

    controller.jumpTo(1.0);
    controller.animateTo(1.0, duration: const Duration(seconds: 1), curve: Curves.linear);
    await tester.pumpAndSettle();
  });

  testWidgets('Scroll controllers notify when the position changes', (WidgetTester tester) async {
    final ScrollController controller = new ScrollController();

    final List<double> log = <double>[];

    controller.addListener(() {
      log.add(controller.offset);
    });

    await tester.pumpWidget(new ListView(
      controller: controller,
      children: kStates.map<Widget>((String state) {
        return new Container(height: 200.0, child: new Text(state));
      }).toList(),
    ));

    expect(log, isEmpty);

    await tester.drag(find.byType(ListView), const Offset(0.0, -250.0));

    expect(log, equals(<double>[ 250.0 ]));
    log.clear();

    controller.dispose();

    await tester.drag(find.byType(ListView), const Offset(0.0, -130.0));
    expect(log, isEmpty);
  });

  testWidgets('keepScrollOffset', (WidgetTester tester) async {
    final PageStorageBucket bucket = new PageStorageBucket();

    Widget buildFrame(ScrollController controller) {
      return new PageStorage(
        bucket: bucket,
        child: new ListView(
          key: new UniqueKey(), // it's a different ListView every time
          controller: controller,
          children: new List<Widget>.generate(50, (int index) {
            return new Container(height: 100.0, child: new Text('Item $index'));
          }).toList(),
        ),
      );
    }

    // keepScrollOffset: true (the default). The scroll offset is restored
    // when the ListView is recreated with a new ScrollController.

    // The initialScrollOffset is used in this case, because there's no saved
    // scroll offset.
    ScrollController controller = new ScrollController(initialScrollOffset: 200.0);
    await tester.pumpWidget(buildFrame(controller));
    expect(tester.getTopLeft(find.widgetWithText(Container, 'Item 2')), Offset.zero);

    controller.jumpTo(2000.0);
    await tester.pump();
    expect(tester.getTopLeft(find.widgetWithText(Container, 'Item 20')), Offset.zero);

    // The initialScrollOffset isn't used in this case, because the scrolloffset
    // can be restored.
    controller = new ScrollController(initialScrollOffset: 25.0);
    await tester.pumpWidget(buildFrame(controller));
    expect(controller.offset, 2000.0);
    expect(tester.getTopLeft(find.widgetWithText(Container, 'Item 20')), Offset.zero);

    // keepScrollOffset: false. The scroll offset is -not- restored
    // when the ListView is recreated with a new ScrollController and
    // the initialScrollOffset is used.

    controller = new ScrollController(keepScrollOffset: false, initialScrollOffset: 100.0);
    await tester.pumpWidget(buildFrame(controller));
    expect(controller.offset, 100.0);
    expect(tester.getTopLeft(find.widgetWithText(Container, 'Item 1')), Offset.zero);

  });
}
