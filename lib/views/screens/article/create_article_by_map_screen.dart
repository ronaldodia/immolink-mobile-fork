import 'package:flutter/material.dart';

class CreateArticleByMapScreen extends StatefulWidget {
  const CreateArticleByMapScreen({super.key, this.area, this.lotNumber, this.lotissement, this.moughataa});
  final double? area;
  final String? lotNumber;
  final String? lotissement;
  final String? moughataa;

  @override
  State<CreateArticleByMapScreen> createState() => _CreateArticleByMapScreenState();
}

class _CreateArticleByMapScreenState extends State<CreateArticleByMapScreen> {
  @override
  Widget build(BuildContext context) {
    String areaText =
    widget.area!.toStringAsFixed(2);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(areaText),
            Text(widget.lotNumber!),
            Text(widget.lotissement!),
            Text(widget.moughataa!),
          ],
        ),
      ),
    );
  }
}
