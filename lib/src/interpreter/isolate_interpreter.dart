/*
 * Copyright 2023 The TensorFlow Authors. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *             http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:async';
import 'package:async/async.dart';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:lite_rt_for_dart/lite_rt_for_dart.dart';
import 'package:lite_rt_for_dart/src/interpreter/isolate_utils.dart';


/// `IsolateInterpreter` allows for the execution of TensorFlow models within an
/// isolate.
/// 
/// Caution: As it is not possible to share memory beween isolates, all data
/// is copied. This has two main consequences for this class
///   1. All methods that invoke the interpreter in the isolate are futures
///      and should be awaited
///   2. The data that is passed to the isolate (ex.: model input data) is
///      copied and therefore the methods return values instead of writing them
///      to the output arguments
class IsolateInterpreter {

  /// File that was used to initialize this interpreter
  File? _file;
  /// Buffer that was used to initialize this interpreter
  Uint8List? _buffer;
  /// Address that was used to initialize this interpreter
  int? _address;

  /// Name of the isolate used for inference
  final String debugName;

  /// Port that the isolate can send message to
  final ReceivePort _receiveFromIsolatePort = ReceivePort();
  /// Queue which buffers messages from the inference isolate
  late final StreamQueue<dynamic> isolateMessageQueue = StreamQueue<dynamic>(
    _receiveFromIsolatePort);
  /// Port that can be used to send messages to the isolate
  late final SendPort _sendToIsolatePort;
  /// The isolate in which the Interpreter is located
  late final Isolate _isolate;

  /// The memory address of the interpreter in the isolate
  late final int isolateInterpreterAddress;

  IsolateInterpreter._(
    this._file,
    this._buffer,
    this._address,
    this.debugName
  );

  /// private 'constructor' that the other 'constructors' use under the hood 
  static Future<IsolateInterpreter> _create(
    File? file, Uint8List? buffer, int? address, String debugName) async {

    final interpreter = IsolateInterpreter._(file, buffer, address, debugName);
    await interpreter._init();

    return interpreter;

  }

  /// Instantiates an isolate interpreter from a .tflite model as `File`
  static Future<IsolateInterpreter> createFromFile(File? file, {
    String debugName = 'TfLiteInterpreterIsolate',
  }) async => await _create(file, null, null, debugName);

  /// Instantiates an isolate interpreter from a .tflite model as `Uint8List`
  static Future<IsolateInterpreter> createFromBuffer(Uint8List? buffer, {
    String debugName = 'TfLiteInterpreterIsolate',
  }) async => await _create(null, buffer, null, debugName);

  /// Instantiates an isolate interpreter from an already existing interpreter's
  /// address
  static Future<IsolateInterpreter> createFromAddress(int? address, {
    String debugName = 'TfLiteInterpreterIsolate',
  }) async => await _create(null, null, address, debugName);

  // Initialize the isolate and set up communication.
  Future<void> _init() async {

    _isolate = await Isolate.spawn(
      _mainIsolate,
      _receiveFromIsolatePort.sendPort,
      debugName: debugName,
    );

    // get isolates port
    _sendToIsolatePort = await isolateMessageQueue.next;
    
    // send the library paths
    _sendToIsolatePort.send(libTfLiteBasePath);
    // TODO other libraries

    // send the data to initialize the isolate
    if(_file != null) _sendToIsolatePort.send(_file);
    if(_buffer != null) _sendToIsolatePort.send(_buffer);
    if(_address != null) _sendToIsolatePort.send(_address);

    // get the address of the interpreter in the isolate
    isolateInterpreterAddress = await isolateMessageQueue.next;

  }

  // Main function for the spawned isolate.
  static Future<void> _mainIsolate(SendPort sendToMainIsolatePort) async {
    // port and queue that receive messages
    final port = ReceivePort();
    final StreamQueue receiveQueue = StreamQueue(port);

    sendToMainIsolatePort.send(port.sendPort);

    // get the paths to the tflite libraries
    final baseLibPath = await receiveQueue.next;
    initLiteRT(baseLibPath);

    // init interpreter in isolate
    late final Interpreter interpreter;
    final d = await receiveQueue.next;
    // init from file
    if(d is File) interpreter = Interpreter.fromFile(d);
    // init from buffer
    else if(d is Uint8List) interpreter = Interpreter.fromBuffer(d);
    // init from address
    else if(d is int) interpreter = Interpreter.fromAddress(d);

    // send the address of the interpreter to the main isolate
    sendToMainIsolatePort.send(interpreter.address);

    // listen for inference requests or closing the isolate
    await for (final data in receiveQueue.rest) {
      if(data is IsolateInterpreterFunctionArguments){
        mapNameAndArgsToFunctionCall(data, interpreter, sendToMainIsolatePort);
      }
      if(data is InterpreterAttributeNames){
        mapNameToMember(data, interpreter, sendToMainIsolatePort);
      }
      // break the loop
      if(data == null){
        interpreter.close();
        break;
      }
    }
  }

  // Close resources and terminate the isolate.
  Future<void> close() async {
    _sendToIsolatePort.send(null);
    _isolate.kill();
  }

  /// Updates allocations for all tensors.
  Future<void> allocateTensors() async {

    _sendToIsolatePort.send(IsolateFunctionArguments(
      name: InterpreterFunctionNames.allocateTensors
    ));

    await isolateMessageQueue.next;

  }


  /// Runs inference for the loaded graph.
  Future<void> invoke() async {

    _sendToIsolatePort.send(IsolateFunctionArguments(
      name: InterpreterFunctionNames.invoke
    ));

    await isolateMessageQueue.next;

  }

  /// Run for single input and output
  Future<dynamic> run(Object input, Object output) async {
    _sendToIsolatePort.send(IsolateFunctionArguments(
      name: InterpreterFunctionNames.run,
      positionalArguments: [input, output]
    ));

    return (await isolateMessageQueue.next);
  }
  
  /// Run for multiple inputs and outputs
  Future<dynamic> runForMultipleInputs(
    List<Object> inputs, Map<int, Object> outputs) async {
    _sendToIsolatePort.send(IsolateFunctionArguments(
      name: InterpreterFunctionNames.runForMultipleInputs,
      positionalArguments: [inputs, outputs]
    ));

    return (await isolateMessageQueue.next);
  }

  /// Just run inference, without a result
  Future<void> runInference(List<Object> inputs) async {
    
    _sendToIsolatePort.send(IsolateFunctionArguments(
      name: InterpreterFunctionNames.runInference
    ));

    await isolateMessageQueue.next;

  }

  /// Gets all input tensors associated with the model.
  Future<List<Tensor>> getInputTensors() async {

    _sendToIsolatePort.send(IsolateFunctionArguments(
      name: InterpreterFunctionNames.getInputTensors,
    ));

    return await isolateMessageQueue.next;

  }

  /// Gets all output tensors associated with the model.
  Future<List<Tensor>> getOutputTensors() async {
    
    _sendToIsolatePort.send(IsolateFunctionArguments(
      name: InterpreterFunctionNames.getOutputTensors,
    ));

    return await isolateMessageQueue.next;

  }

  /// Resize input tensor for the given tensor index. `allocateTensors` must
  /// be called again afterward.
  Future<void> resizeInputTensor(int tensorIndex, List<int> shape) async {
        
    _sendToIsolatePort.send(IsolateFunctionArguments(
      name: InterpreterFunctionNames.getOutputTensors,
    ));

    return await isolateMessageQueue.next;

  }

  /// Gets the input Tensor for the provided input index.
  Future<Tensor> getInputTensor(int index) async {
    
    _sendToIsolatePort.send(IsolateFunctionArguments(
      name: InterpreterFunctionNames.getInputTensor,
      positionalArguments: [index]
    ));

    return await isolateMessageQueue.next;

  }

  /// Gets the output Tensor for the provided output index.
  Future<Tensor> getOutputTensor(int index) async {
    
    _sendToIsolatePort.send(IsolateFunctionArguments(
      name: InterpreterFunctionNames.getOutputTensor,
      positionalArguments: [index]
    ));

    return await isolateMessageQueue.next;

  }

  /// Gets index of an input given the op name of the input.
  Future<int> getInputIndex(String opName) async {
        
    _sendToIsolatePort.send(IsolateFunctionArguments(
      name: InterpreterFunctionNames.getOutputTensor,
      positionalArguments: [opName]
    ));

    return await isolateMessageQueue.next;

  }

  /// Gets index of an output given the op name of the output.
  Future<int> getOutputIndex(String opName) async {
        
    _sendToIsolatePort.send(IsolateFunctionArguments(
      name: InterpreterFunctionNames.getOutputTensor,
      positionalArguments: [opName]
    ));

    return await isolateMessageQueue.next;

  }

  // Resets all variable tensors to the defaul value
  Future<void> resetVariableTensors() async {
            
    _sendToIsolatePort.send(IsolateFunctionArguments(
      name: InterpreterFunctionNames.resetVariableTensors,
    ));

    await isolateMessageQueue.next;

  }
}
