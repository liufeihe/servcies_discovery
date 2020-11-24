import 'package:flutter/material.dart';

class ColorConstant {
  static const Color themeBgColor = Color(0xff24292d);
  static const Color themeRedColor = Color(0xffEB6160);

  static const Color bgLinearGreenColor1 = Color(0xff3dbd7d);
  static const Color bgLinearGreenColor2 = Color(0xffc1f3da);
  static const Color btnBgLinearGreenColor1 = Color(0xffffffff);
  static const Color btnBgLinearGreenColor2 = Color(0xffe2fff1);
  static const Color bgLinearBlueColor1 = Color(0xff2266efa);
  static const Color bgLinearBlueColor2 = Color(0xffb3e1ff);
  static const Color btnBgLinearBlueColor1 = Color(0xffffffff);
  static const Color btnBgLinearBlueColor2 = Color(0xffdaebff);
  static const Color btnBgLinearDarkBlueColor1 = Color(0xff1c55ee);
  static const Color btnBgLinearDarkBlueColor2 = Color(0xff2b79ff);
  static const Color btnBgLinearYellowColor1 = Color(0xfffa5555);
  static const Color btnBgLinearYellowColor2 = Color(0xfffa5555);
  static const Color circleLinearColor1 = Color(0xff3dbd7d);
  static const Color circleLinearColor2 = Color(0xff1d59ef);
  static const Color circleLinearRed1 = Color(0xffe64a35);
  static const Color circleLinearRed2 = Color(0xffda214c);

  static const Color bgGreyColor = Color(0xfff7f7f7);
  static const Color bgGreyColor1 = Color(0xfffafafa);
  static const Color bgGreyColor2 = Color(0xfff5f5f5);
  static const Color bgGreyColor3 = Color(0xffe4e4e4);
  static const Color bgGrey4 = Color(0xffededed);
  static const Color bgGreyShallowColor = Color(0xffeeeeee);
  static const Color bgDarkGreyColor = Color(0xffbbbbbb);
  static const Color bgDarkColor = Color(0xff143d29);
  static const Color bgDarkDeep = Color(0x33000000);
  static const Color bgDarkDeeper = Color(0xff1a1d20);
  static const Color bgCircleGreyColor = Color(0xff3f464b);
  static const Color bgCircleGrey2 = Color(0xffd8d8d8);
  static const Color bgCircleGrey3 = Color(0xffcacaca);
  static const Color bgCircleRed = Color(0xffdd2c46);
  static const Color bgCircleRed2 = Color(0xffff3b30);
  static const Color bgCircleGreen = Color(0xff3dbd7d);
  static const Color bgCircleGreen2 = Color(0xff28c236);
  static const Color bgBlueShallow = Color(0xfff3f6ff);
  static const Color bgYellowTransparent = Color(0x33feaf16);
  static const Color bgGreenTransparent = Color(0x3302cf74);

  static const Color cirlceYellowColor = Color(0xffffb34f);
  static const Color cirlceBlueColor = Color(0xff2ecdff);
  static const Color cirlceRedColor = Color(0xfffd1c1c);
  static const Color cirlceGreenColor = Color(0xff02cf74);
  static const Color borderGreyColor = Color(0xffe6e6e6);
  static const Color borderGrey2 = Color(0xffdddddd);
  static const Color borderGrey3 = Color(0x1b666666);
  static const Color borderCircleGrey = Color(0xffc9c9c9);
  static const Color borderBlue = Color(0xff1c58df);
  static const Color borderYellow = Color(0xffe93d3d);

  static const Color textBlackDeep = Color(0xff1a1a1a);
  static const Color textColorBlack = Color(0xff333333);
  static const Color textBlack2 = Color(0xff393939);
  static const Color textBlack3 = Color(0xff555555);
  static const Color textColorBlackPlain = Color(0xff454545);
  static const Color textColorBlackPlain2 = Color(0xff4f4f4f);
  static const Color textColorBlackShallow = Color(0xff666666);
  static const Color textColorBlackShallow2 = Color(0x61666666);
  static const Color textColorGreenDeep = Color(0xff115f38);
  static const Color textColorGreen = Color(0xff3dbd7d);
  static const Color textGreen = Color(0xff01a55c);
  static const Color blueShallow = Color(0xff4093f9);
  static const Color blueBlur = Color(0x61317AF5);
  static const Color redBlur = Color(0x42e2393f);
  static const Color textColorBlueDeep = Color(0xff1e5af0);
  static const Color textColorBlue = Color(0xff367bfa);
  static const Color textColorGreyDeep = Color(0xff999999);
  static const Color textColorGreyDeep2 = Color(0xcca0a0a0);
  static const Color textColorGrey = Color(0xffcccccc);
  static const Color textYellow = Color(0xffcb8c11);
  
  static const Color textRed = Color(0xfff5222d);
  static const Color textOrange = Color(0xffe6a23b);

  static const Color arrowGrey = Color(0xff666666);

  static const Color iconGrey = Color(0xff979797);

  static Color getColorByOpacity(r,g,b,opacity){
    return Color.fromRGBO(r, g, b, opacity);
  }
}

class WeightStyle {
  static const FontWeight normal = FontWeight.w400;
  static const FontWeight med = FontWeight.w500;
  static const FontWeight semi = FontWeight.w600;
  static const FontWeight bold = FontWeight.bold;
}