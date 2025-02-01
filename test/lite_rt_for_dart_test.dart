import 'dart:io';

import 'package:test/test.dart';
import 'package:tflite_flutter/tflite_flutter.dart';



void main() {

  test('Run test inference', () {
    
    // load tf lite lib and ensure by showing version
    String libPath = './libtflite_c.dylib';
    initLiteRT(libPath);
    print(tfLiteVersion);

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
