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

import 'dart:ffi';
import 'dart:io';

import 'package:lite_rt_for_dart/lite_rt_for_dart.dart';
import 'package:lite_rt_for_dart/src/bindings/tensorflow_lite_bindings_generated.dart';


/// if a library path is set to this value, the `DynamicLibrary` shoudl be
/// loaded with `DynamicLibrary.process()`
String shouldUseDynamicLibraryProcess = "DynamicLibrary.process();";

final DynamicLibrary _dylibGpu = () {
  
  if (Platform.isAndroid) {
    return DynamicLibrary.open('libtensorflowlite_gpu_jni.so');
  }
  // TODO MacOS
  // TODO Linux
  // TODO Windows

  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

/// Have the tflite bindings been initialized
bool _tfliteBindingInitialized = false;
/// Have the tflite bindings been initialized
bool get tfliteBindingInitialized => _tfliteBindingInitialized;
/// TensorFlowLite Bindings
late final TensorFlowLiteBindings _tfliteBinding;
/// TensorFlowLite Bindings
TensorFlowLiteBindings get tfliteBinding {

  if(!tfliteBindingInitialized){
    try {
      
      DynamicLibrary dl;

      // check if the library should be loaded from path or not
      if(libTfLiteBasePath == shouldUseDynamicLibraryProcess) dl = DynamicLibrary.process();
      else dl = DynamicLibrary.open(libTfLiteBasePath);
      
      _tfliteBinding = TensorFlowLiteBindings(dl);
      
      _tfliteBindingInitialized = true;

    }
    catch (e) {
      print("The given path: $libTfLiteBasePath does not contain a valid TF Lite runtime!");
      throw Exception(e);
    }
  }

  return _tfliteBinding;

}

/// TensorFlowLite Gpu Bindings
late final TensorFlowLiteBindings tfliteBindingGpu;
