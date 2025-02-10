import 'package:lite_rt_for_dart/src/interpreter/web_interpreter.dart';

import 'native_interpreter.dart';



/// Super thin wrapper around `NativeInterpreter` and `WebInterpreter`
/// to use them the same after initalization
class InterpreterWrapper<T> {

  /// The `NativeInterpreter` or `WebInterpreter` instance used by this 
  T? interpreter;
  /// Is this wrapper based on a `NativeInterpreter`
  bool get isNativeInterpreter => this.interpreter is NativeInterpreter;
  /// Is this wrapper based on a `WebInterpreter`
  bool get isWebInterpreter => this.interpreter is TfJsLiteInterpreter;


  InterpreterWrapper(T interpreter){

    if(!isNativeInterpreter && !isWebInterpreter){
      throw Exception("${interpreter.runtimeType} is not a valid `T` for this `InterpreterWrapper`");
    }

    this.interpreter = interpreter;

  }

  Future<Object> run() async {

    if(isNativeInterpreter){

    }
    else if(isWebInterpreter){

    }
  
    return [];

  }

}