import 'package:flutter/material.dart';

route(context, widget, {bool close = false}) => close
    ? Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => widget), (route) => false)
    : Navigator.of(context).push(MaterialPageRoute(builder: (_) => widget));