// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// TensorFlow Lite for Flutter
library lite_rt_for_dart;

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:lite_rt_for_dart/src/bindings/bindings.dart';
import 'package:lite_rt_for_dart/src/bindings/tensorflow_lite_bindings_generated.dart';

export 'src/delegate.dart';
export 'src/delegates/gpu_delegate.dart';
export 'src/delegates/metal_delegate.dart';
export 'src/delegates/xnnpack_delegate.dart';
export 'src/delegates/coreml_delegate.dart';
export 'src/interpreter.dart';
export 'src/interpreter_options.dart';
export 'src/isolate_interpreter.dart';
export 'src/quanitzation_params.dart';
export 'src/tensor.dart';
export 'src/util/byte_conversion_utils.dart';
export 'src/util/list_shape_extension.dart';

/// tflite version information.
String get tfLiteVersion => tfliteBinding.TfLiteVersion().cast<Utf8>().toDartString();

/// Call this or `` **before** using any methods of this package
/// 
/// Pass a path to a tf lite dynmic library
void initLiteRT(String libraryPath, {
    String? gpuDelegatelibraryPath
  }){

  tfliteBinding = TensorFlowLiteBindings(DynamicLibrary.open(libraryPath));

  // add gpu delegate if set
  if(gpuDelegatelibraryPath != null){
    tfliteBindingGpu = TensorFlowLiteBindings(
      DynamicLibrary.open(gpuDelegatelibraryPath));
  }

}

/// Call this or `initLiteRT` **before** using any methods of this package
/// 
/// Pass a DynamicLibrary that holds the TFLite runtime symbols
void initLiteRTFromLib(DynamicLibrary library, {
    DynamicLibrary? gpuDelegatelibrary
  }){

  tfliteBinding = TensorFlowLiteBindings(library);

  // add gpu delegate if set
  if(gpuDelegatelibrary != null){
    tfliteBindingGpu = TensorFlowLiteBindings(gpuDelegatelibrary);
  }

}