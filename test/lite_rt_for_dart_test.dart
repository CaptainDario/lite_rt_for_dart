import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:lite_rt_for_dart/src/bindings/bindings.dart';
import 'package:test/test.dart';
import 'package:lite_rt_for_dart/lite_rt_for_dart.dart';



void main() {

  test('Run test inference', () {
    
    // load tf lite lib and ensure by showing version
    String libPath = './libtflite_c.dylib';
    initLiteRT(libPath);
    print(tfliteBinding.TfLiteVersion().cast<Utf8>().toDartString());

    // load a model
    Interpreter i = Interpreter.fromFile(File("mobilenet_quant.tflite"));
    
    // prepare input / output
    final shape = [224, 224, 3];
    final inp = List.generate(shape[0], (y)
      => List.generate(shape[1], (x)
        => List.filled(shape[2], 0))
    );
    final output = List<int>.filled(1001, 0);

    // run inference
    i.run([inp], [output]);

  });
}
