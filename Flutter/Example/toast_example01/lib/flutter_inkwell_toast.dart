
import 'package:flutter/material.dart';

class InkwellToast extends StatefulWidget {

  @override
  _InkwellToastState createState() => new _InkwellToastState();
}
class _InkwellToastState extends State<InkwellToast>{

  @override
  Widget build(BuildContext context) {

  }
}




class ToastFuture {

  final OverlayEntry _overlayEntry;

  bool _isShow = true;

  ToastFuture._(this._overlayEntry);

  void dismiss(){

    if(!_isShow) return;

    _isShow = false;



  }
}
