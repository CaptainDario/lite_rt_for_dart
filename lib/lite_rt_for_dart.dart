// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// TensorFlow Lite for Flutter
library lite_rt_for_dart;

export 'src/delegate.dart';
export 'src/delegates/gpu_delegate.dart';
export 'src/delegates/metal_delegate.dart';
export 'src/delegates/xnnpack_delegate.dart';
export 'src/delegates/coreml_delegate.dart';
export 'src/interpreter/interpreter.dart';
export 'src/interpreter/isolate_interpreter.dart';
export 'src/interpreter/interpreter_options.dart';
export 'src/quanitzation_params.dart';
export 'src/tensor.dart';
export 'src/util/byte_conversion_utils.dart';
export 'src/util/list_shape_extension.dart';



/// The path to the library which contains that base LiteRT
String? _libTfLiteBasePath;
/// The path to the library which contains that base LiteRT
String get libTfLiteBasePath {

  if(_libTfLiteBasePath == null){
    throw Exception("LiteRT has not been initialized! Run `initLiteRT` first!");
  }

  return _libTfLiteBasePath!;
}

/// Call this **before** using any methods of this package
/// 
/// `libraryPath` should be a path to a tensorflow lite dynamic library
/// `gpuDelegatelibraryPath` should be a path to a tensorflow lite gpu delegate
/// dynamic library
/// `loadLibs` controls if the tf lite libraries should be loaded into memory
/// when calling `initLiteRT`. If set to false loads the libraries
/// when the first call to TFLite is being made.
/// If you intend to use this package in an isolate, set keep this set to false
void initLiteRT(String libraryPath, {
    String? gpuDelegatelibraryPath,
    bool loadLibs = false
  }){

  _libTfLiteBasePath = libraryPath;
  // TODO GPU LIB
  // TODO FLEX LIB

  if(loadLibs){

  }

}