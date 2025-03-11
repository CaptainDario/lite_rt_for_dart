 <p align="center">
    <br>
    <img src="./.github/readme/lite_rt_dart.jpg"/>
    </br>
</p>

**IMPORTANT, READ THIS BEFORE USING THIS PLUGIN!**
* **This is NOT an official implementation, [Google's official plugin is here](https://pub.dev/packages/tflite_flutter)**
  * For proper support please use that plugin
* **I created this plugin to use in my own applications as I encountered various difficulties with the official plugin.**
  * Therefore, the main use case is that it works in my own applications, but it may be useful for others, which is why I opened sourced it.

## LiteRT (TF Lite) for dart

This plugin provides bindings for LiteRT (formerly TF lite) for standalone dart.
If you want to use this in Flutter, consider [using the Flutter package](https://github.com/CaptainDario/lite_rt_for_flutter/releases).
[Try it out in the browser!](https://captaindario.github.io/lite_rt_for_flutter/)

## Why another plugin?

This fork of the official plugin tries to improve upon the official implementation in a few key areas:

* Dart standalone support
* Improved binary handling
  * Up-to-date binaries
  * Easily switch between binaries
* Improved platform support
  * Linux arm 64
  * Windows arm 64
  * Web support is planned

New features from the official implementation will also be integrated in this fork.

## Example

### Import and initialize the library

In the dependency section of `pubspec.yaml` file, add `lite_rt_for_dart: <your version>`

```dart
import 'package:lite_rt_for_dart/tflite_flutter.dart';

// IMPORTANT: initialize the plugin
initLiteRT("path/to/your/lib_tflite")

// Load a model from file
final interpreter = await Interpreter.fromFile('path/to/your/model.tflite');

```

Refer to the documentation for info on creating interpreter from a buffer or a file.

### Performing inference

<details>
<summary>For single input and output</summary>

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

</details>
  
#### 

<details>
<summary>For multiple inputs and outputs</summary>

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

</details>

#### Closing the interpreter

```dart
interpreter.close();
```

### Asynchronous Inference with `IsolateInterpreter`

<details>

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

</details>

## Development

<details>

### Generated code

This package uses [ffigen](https://pub.dev/packages/ffigen) to generate FFI bindings. To run code generation, you can use the following melos command:

```sh
melos run ffigen 
```

</details>
