import 'package:flutter/material.dart';
import 'package:immolink_mobile/utils/config.dart';

class FormDividerWidget extends StatelessWidget {
  const FormDividerWidget({super.key, required this.deividerText});

  final String deividerText;

  @override
  Widget build(BuildContext context) {
    return  Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Flexible(child: Divider(color: Colors.black, thickness: 0.5, indent: 60, endIndent: 5,)),
        Text(deividerText, style: const TextStyle(fontWeight: FontWeight.w200),),
        const Flexible(child: Divider(color: Colors.black, thickness: 0.5, indent: 5, endIndent: 60,))
      ],
    );
  }
}
