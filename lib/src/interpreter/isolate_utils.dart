


import 'dart:isolate';

import 'package:lite_rt_for_dart/lite_rt_for_dart.dart';

/// All names that are valid interpreter functions
enum InterpreterFunctionNames {
  allocateTensors,
  invoke,
  run,
  runForMultipleInputs,
  runInference,
  getInputTensors,
  getOutputTensors,
  resizeInputTensor,
  getInputTensor,
  getOutputTensor,
  getInputIndex,
  getOutputIndex,
  resetVariableTensors
}

/// Class that bundles data to easily invoke functions inside an isolate
class IsolateFunctionArguments {

  /// The name of the function to invoke
  final InterpreterFunctionNames name;
  /// The positional Arugments that should be passed to the function
  final List<dynamic>? positionalArguments;
  /// the named arguments that should be passed to the isolate
  final List<dynamic>? namedArguments;

  IsolateFunctionArguments({
    required this.name,
    this.positionalArguments,
    this.namedArguments
  });

}

/// Maps the given `IsolateFunctionArguments` to the call that it describes
void mapIsolateFunctionArgumentsToFunctionCall(
  IsolateFunctionArguments iFA, Interpreter interpreter,
  SendPort sendToMainIsolatePort){

  final args      = iFA.positionalArguments;
  final namedArgs = iFA.namedArguments;
  
  switch (iFA.name) {
    case InterpreterFunctionNames.allocateTensors:
      interpreter.allocateTensors();
      sendToMainIsolatePort.send(null);
      break;
    case InterpreterFunctionNames.invoke:
      interpreter.invoke();
      sendToMainIsolatePort.send(null);
      break;
    case InterpreterFunctionNames.run:
      interpreter.run(args![0], args[1]);
      sendToMainIsolatePort.send(args[1]);
      break;
    case InterpreterFunctionNames.runForMultipleInputs:
      interpreter.runForMultipleInputs(args![0], args[1]);
      sendToMainIsolatePort.send(args[1]);
      break;
    case InterpreterFunctionNames.runInference:
      interpreter.invoke();
      sendToMainIsolatePort.send(null);
      break;
    case InterpreterFunctionNames.getInputTensors:
      sendToMainIsolatePort.send(interpreter.getInputTensors());
      break;
    case InterpreterFunctionNames.getOutputTensors:
      sendToMainIsolatePort.send(interpreter.getOutputTensors());
      break;
    case InterpreterFunctionNames.resizeInputTensor:
      interpreter.resizeInputTensor(args![0]!, args[1]);
      sendToMainIsolatePort.send(null);
      break;
    case InterpreterFunctionNames.getInputTensor:
      sendToMainIsolatePort.send(interpreter.getInputTensor(args![0]));
      break;
    case InterpreterFunctionNames.getOutputTensor:
      sendToMainIsolatePort.send(interpreter.getOutputTensor(args![0]));
      break;
    case InterpreterFunctionNames.getInputIndex:
      sendToMainIsolatePort.send(interpreter.getInputIndex(args![0]));
      break;
    case InterpreterFunctionNames.getOutputIndex:
      sendToMainIsolatePort.send(interpreter.getOutputIndex(args![0]));
      break;
    case InterpreterFunctionNames.resetVariableTensors:
      interpreter.resetVariableTensors();
      sendToMainIsolatePort.send(null);
      break;
  }

}