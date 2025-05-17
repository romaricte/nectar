import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final String? fontFamily;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? letterSpacing;
  final double? height;

  const CustomText({
    Key? key,
    required this.text,
    this.fontSize,
    this.fontWeight,
    this.fontFamily,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.letterSpacing,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontFamily: fontFamily ?? 'OpenSans',
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      ),
      textAlign: textAlign ?? TextAlign.left,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

// Texte en gras
class BoldText extends CustomText {
  const BoldText({
    Key? key,
    required String text,
    double? fontSize = 16,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) : super(
          key: key,
          text: text,
          fontSize: fontSize,
          fontFamily: 'OpenSans',
          fontWeight: FontWeight.bold,
          color: color,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
}

// Texte pour les titres
class TitleText extends CustomText {
  const TitleText({
    Key? key,
    required String text,
    Color? color,
    TextAlign? textAlign = TextAlign.center,
  }) : super(
          key: key,
          text: text,
          fontSize: 24,
          fontFamily: 'OpenSans',
          fontWeight: FontWeight.bold,
          color: color,
          textAlign: textAlign,
        );
}

// Texte pour les sous-titres
class SubtitleText extends CustomText {
  const SubtitleText({
    Key? key,
    required String text,
    Color? color,
    TextAlign? textAlign = TextAlign.center,
  }) : super(
          key: key,
          text: text,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          fontFamily: 'OpenSans',
          color: color,
          textAlign: textAlign,
        );
}

// Texte pour le corps
class BodyText extends CustomText {
  const BodyText({
    Key? key,
    required String text,
    double? fontSize = 14,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) : super(
          key: key,
          text: text,
          fontSize: fontSize,
          color: color,
          fontFamily: 'OpenSans',
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
}

// Texte pour les petites annotations
class CaptionText extends CustomText {
  const CaptionText({
    Key? key,
    required String text,
    Color? color,
    TextAlign? textAlign,
  }) : super(
          key: key,
          text: text,
          fontFamily: 'OpenSans',
          fontSize: 12,
          color: color ?? Colors.grey,
          textAlign: textAlign,
        );
} 