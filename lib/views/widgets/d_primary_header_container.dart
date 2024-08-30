import 'package:flutter/material.dart';

class DPrimaryHeaderContainer extends StatelessWidget {
  const DPrimaryHeaderContainer({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Container(
        color: Colors.blue,
        child: Stack(
          children: [
            Positioned(top: -150, right: -250, child: Container()),
            child
          ],
        ),
      ),
    );
  }
}
