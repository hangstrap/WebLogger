library stream_test;

import "package:unittest/unittest.dart";
import "dart:async";

void main() {
  test("aa", () {
    StreamController streamController = new StreamController();

    Timer t;
    
    t = new Timer(new Duration(seconds: 3), () {
      fail('event not fired in time');
    });

    Stream underTest = streamController.stream;
    underTest.first.then(expectAsync((e) {
      expect(e, equals("test"));
      if (t != null) {
       t.cancel();
      }
    }));

//Fire the event

//   streamController.add("test");
  });
}