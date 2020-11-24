import 'package:flutter/material.dart';
import 'package:services_discovery/utils/colorConstant.dart';

class ItemContainer extends StatelessWidget {
  final Widget item;
  final EdgeInsetsGeometry margin;
  static const EdgeInsetsGeometry defaultMargin = EdgeInsets.only(top: 10,left: 15, right: 15);

  ItemContainer({
    this.item,
    this.margin: defaultMargin,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 100),
      margin: margin,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(8)),
        boxShadow: [
          BoxShadow(color: ColorConstant.borderGrey3, offset: Offset(1,1), blurRadius: 5,),
        ],
      ),
      child: item
    );
  }
}