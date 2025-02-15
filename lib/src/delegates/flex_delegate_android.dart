import 'dart:ffi';

import 'package:lite_rt_for_dart/src/bindings/bindings.dart';
import 'package:lite_rt_for_dart/src/bindings/tensorflow_lite_bindings_generated.dart';
import 'package:quiver/check.dart';
import '../delegate.dart';



/// Flex Delegate for Android
/// 
/// Note:
/// On all other platforms the flex delegate is automatically linked and does
/// not need to be create manually
class FlexDelegateAndroid implements Delegate {
  Pointer<TfLiteDelegate> _delegate;
  bool _deleted = false;

  @override
  Pointer<TfLiteDelegate> get base => _delegate;

  FlexDelegateAndroid._(this._delegate);

  factory FlexDelegateAndroid() {
    return FlexDelegateAndroid._(tfLite_flex_createDelegate());
  }

  @override
  void delete() {
    checkState(!_deleted,
        message: 'TfLiteFlex_delegate already deleted.');

    tfLite_flex_deleteDelegate(_delegate);
    _deleted = true;
  }
}