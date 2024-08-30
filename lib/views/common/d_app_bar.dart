import 'package:flutter/material.dart';
import 'package:immolink_mobile/utils/helpers.dart';
import 'package:immolink_mobile/utils/t_sizes.dart';

class DAppBar extends StatelessWidget {
  const DAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(padding: EdgeInsets.symmetric(horizontal: TSizes.md));
  }

  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(Helper.getAppBarHeight());
}
