library mock_function_test;

import "package:unittest/unittest.dart";
import "package:mock/mock.dart";

typedef int Adder(int a, int b);

int useAdder(Adder adder) {
  return adder(1, 2);
}
int myAdder( int a, int b){
  return a+b;
}
@proxy
class MyMock extends Mock {
  MyMock(){
    when(callsTo('call')).alwaysCall(this.foo);
  }
  int foo(int a, int b) => a+b;
  int call(int a, int b) => super.call(a, b);
}

void main() {
  test("aa", () {

    var mockf = new MyMock();
    expect(mockf(1, 2), 3);
    mockf.getLogs(callsTo('call', 1, 2)).verify(happenedOnce);
  });

  test("bb", () {
    var mockf = new MyMock();
    var result = useAdder( mockf.call);
    
    expect( result, 3);
    mockf.getLogs(callsTo('call', 1, 2)).verify(happenedOnce);
  });
  test("cc", () {
    expect(useAdder( myAdder), 3);

  });
}
