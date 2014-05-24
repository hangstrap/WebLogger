import 'package:unittest/unittest.dart';
import 'package:jsonx/jsonx.dart';


main(){
  
  test( "encode", (){
    
    String json = encode( new Message( "type", [1,2,2]));
    print( json);
  });
}

class Message<T> {
  String type;
  T data;
  Message( this.type, this.data);
}