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

import 'package:ffi/ffi.dart';
import 'package:lite_rt_for_dart/lite_rt_for_dart.dart';
import 'package:lite_rt_for_dart/src/bindings/tensorflow_lite_bindings_generated.dart';


/// if a library path is set to this value, the `DynamicLibrary` shoudl be
/// loaded with `DynamicLibrary.process()`
String shouldUseDynamicLibraryProcess = "DynamicLibrary.process();";



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

      print("Loaded LiteRT ${_tfliteBinding.TfLiteVersion().cast<Utf8>().toDartString()} from ${libTfLiteBasePath}");
    }
    catch (e) {
      print("The given path: $libTfLiteBasePath does not contain a valid TF Lite runtime!");
      throw Exception(e);
    }
  }

  return _tfliteBinding;

}


/// Have the tflite bindings been initialized
bool _tfliteGpuDelegateBindingInitialized = false;
/// Have the tflite bindings been initialized
bool get tfliteGpuDelegateBindingInitialized => _tfliteGpuDelegateBindingInitialized;
/// TensorFlowLite Bindings
late final TensorFlowLiteBindings _tfliteGpuDelegateBinding;
/// TensorFlowLite Bindings
TensorFlowLiteBindings get tfliteGpuDelegateBinding {

  if(!tfliteGpuDelegateBindingInitialized){
    try {
      
      DynamicLibrary dl;

      // check if the library should be loaded from path or not
      if(libTfLiteGPUDelegatePath == shouldUseDynamicLibraryProcess) dl = DynamicLibrary.process();
      else dl = DynamicLibrary.open(libTfLiteGPUDelegatePath);
      
      _tfliteGpuDelegateBinding = TensorFlowLiteBindings(dl);
      
      _tfliteGpuDelegateBindingInitialized = true;

      print("Loaded TF Lite GPU Delegate from $libTfLiteGPUDelegatePath");

    }
    catch (e) {
      print("The given path: $libTfLiteGPUDelegatePath does not contain a valid GPU delegate!");
      throw Exception(e);
    }
  }

  return _tfliteGpuDelegateBinding;

}


/// Have the tflite bindings been initialized
bool _tfliteCoreMLDelegateBindingInitialized = false;
/// Have the tflite bindings been initialized
bool get tfliteCoreMLDelegateBindingInitialized => _tfliteCoreMLDelegateBindingInitialized;
/// TensorFlowLite Bindings
late final TensorFlowLiteBindings _tfliteCoreMLDelegateBinding;
/// TensorFlowLite Bindings
TensorFlowLiteBindings get tfliteCoreMLDelegateBinding {

  if(!tfliteCoreMLDelegateBindingInitialized){
    try {
      
      DynamicLibrary dl;

      // check if the library should be loaded from path or not
      if(libTfLiteCoreMLDelegatePath == shouldUseDynamicLibraryProcess) dl = DynamicLibrary.process();
      else dl = DynamicLibrary.open(libTfLiteCoreMLDelegatePath);
      
      _tfliteCoreMLDelegateBinding = TensorFlowLiteBindings(dl);
      
      _tfliteCoreMLDelegateBindingInitialized = true;

      print("Loaded TF Lite CoreML Delegate from $libTfLiteCoreMLDelegatePath");

    }
    catch (e) {
      print("The given path: $libTfLiteCoreMLDelegatePath does not contain a valid CoreML delegate!");
      throw Exception(e);
    }
  }

  return _tfliteCoreMLDelegateBinding;

}

// android flex delegate bindings
late DynamicLibrary _tfliteFlexDelegateLibrary;
typedef _TfLite_flex_initTensorflow_native_t = Pointer<TfLiteDelegate> Function();
late Pointer<TfLiteDelegate> Function() tfLite_flex_initTensorflow;
typedef _TfLite_flex_createDelegate_native_t = Pointer<TfLiteDelegate> Function();
late Pointer<TfLiteDelegate> Function() tfLite_flex_createDelegate;
typedef _TfLite_flex_deleteDelegate_native_t = Void Function(
    Pointer<TfLiteDelegate> delegate);
late void Function(Pointer<TfLiteDelegate>) tfLite_flex_deleteDelegate;
/// Has the flex delegate been created for android
bool createdFlexDelegateAndroid = false;

void initAndroidFlexDelegate(String libTfLiteFlexDelegatePath){

  try {

    _tfliteFlexDelegateLibrary = DynamicLibrary.open(libTfLiteFlexDelegatePath);

    tfLite_flex_initTensorflow = _tfliteFlexDelegateLibrary
      .lookup<NativeFunction<_TfLite_flex_initTensorflow_native_t>>(
      'Java_org_tensorflow_lite_flex_FlexDelegate_nativeInitTensorFlow')
      .asFunction();
    tfLite_flex_createDelegate = _tfliteFlexDelegateLibrary
      .lookup<NativeFunction<_TfLite_flex_createDelegate_native_t>>(
      'Java_org_tensorflow_lite_flex_FlexDelegate_nativeCreateDelegate')
      .asFunction();
    tfLite_flex_deleteDelegate = _tfliteFlexDelegateLibrary
      .lookup<NativeFunction<_TfLite_flex_deleteDelegate_native_t>>(
      'Java_org_tensorflow_lite_flex_FlexDelegate_nativeDeleteDelegate')
      .asFunction();

    createdFlexDelegateAndroid = true;

  }
  catch (e) {
    
  }

}