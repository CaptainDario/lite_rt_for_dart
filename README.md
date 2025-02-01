 <p align="center">
    <br>
    <img src="https://github.com/am15h/tflite_flutter_plugin/raw/update_readme/docs/tflite_flutter_cover.png"/>
    </br>
</p>
<p align="center">

   <a href="https://flutter.dev">
     <img src="https://img.shields.io/badge/Platform-Flutter-02569B?logo=flutter"
       alt="Platform" />
   </a>
   <a href="https://pub.dartlang.org/packages/tflite_flutter">
     <img src="https://img.shields.io/pub/v/tflite_flutter.svg"
       alt="Pub Package" />
   </a>
    <a href="https://pub.dev/documentation/tflite_flutter/latest/tflite_flutter/tflite_flutter-library.html">
        <img alt="Docs" src="https://readthedocs.org/projects/hubdb/badge/?version=latest">
    </a>
    <a href="https://opensource.org/licenses/Apache-2.0"><img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg"></a>

</a>
</p>

## RT Lite (TF Lite) for dart

**This is not an official implementation, [Google's official plugin is here](https://pub.dev/packages/tflite_flutter)**

This plugin provides bindings for RT Lite (formerly tf lite) for standalone dart.

## Why another plugin?

This fork of the official plugin tries to improve upon the official implementation in a few key areas:

* Dart standalone support
* Easier and better binary handling
* Up-to-date binaries
* Better desktop support

New features from the official implementation will also be integrated in this fork.

## Usage instructions

### Import the libraries

In the dependency section of `pubspec.yaml` file, add `tflite_flutter: <your version>`

### Import

```dart
import 'package:tflite_flutter/tflite_flutter.dart';
```

### Creating the Interpreter

- **From asset**

    Place `your_model.tflite` in `assets` directory. Make sure to include assets in `pubspec.yaml`.

    ```dart
    final interpreter = await Interpreter.fromAsset('assets/your_model.tflite');
    ```

Refer to the documentation for info on creating interpreter from buffer or file.

### Performing inference

- **For single input and output**

    Use `void run(Object input, Object output)`.

    ```dart
    // For ex: if input tensor shape [1,5] and type is float32
    var input = [[1.23, 6.54, 7.81, 3.21, 2.22]];

    // if output tensor shape [1,2] and type is float32
    var output = List.filled(1*2, 0).reshape([1,2]);

    // inference
    interpreter.run(input, output);

    // print the output
    print(output);
    ```
  
- **For multiple inputs and outputs**

    Use `void runForMultipleInputs(List<Object> inputs, Map<int, Object> outputs)`.

    ```dart
    var input0 = [1.23];  
    var input1 = [2.43];  

    // input: List<Object>
    var inputs = [input0, input1, input0, input1];  

    var output0 = List<double>.filled(1, 0);  
    var output1 = List<double>.filled(1, 0);

    // output: Map<int, Object>
    var outputs = {0: output0, 1: output1};

    // inference  
    interpreter.runForMultipleInputs(inputs, outputs);

    // print outputs
    print(outputs)
    ```

### Closing the interpreter

```dart
interpreter.close();
```

### Asynchronous Inference with `IsolateInterpreter`

To utilize asynchronous inference, first create your `Interpreter` and then wrap it with `IsolateInterpreter`.

```dart
final interpreter = await Interpreter.fromAsset('assets/your_model.tflite');
final isolateInterpreter =
        await IsolateInterpreter.create(address: interpreter.address);
```

Both `run` and `runForMultipleInputs` methods of `isolateInterpreter` are asynchronous:

```dart
await isolateInterpreter.run(input, output);
await isolateInterpreter.runForMultipleInputs(inputs, outputs);
```

By using `IsolateInterpreter`, the inference runs in a separate isolate. This ensures that the main isolate, responsible for UI tasks, remains unblocked and responsive.

### Generated code

This package uses [ffigen](https://pub.dev/packages/ffigen) to generate FFI bindings. To run code generation, you can use the following melos command:

```sh
melos run ffigen 
```
