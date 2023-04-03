import 'package:flutter/material.dart';

///
/// SubHeader
///

class SubHeader3 extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final Color? color;
  final int? maxLines;
  final TextOverflow? overflow;

  const SubHeader3(
    this.text, {
    this.textAlign,
    this.color,
    this.maxLines,
    this.overflow,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class Headline3 extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final FontWeight? fontWeight;
  final Color? color;

  const Headline3(this.text, {Key? key, this.textAlign, this.fontWeight, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.headline3?.copyWith(
            fontWeight: fontWeight,
            color: color,
          ),
      textAlign: textAlign,
    );
  }
}

class Headline4 extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final FontWeight? fontWeight;
  final Color? color;
  final double? fontSize;

  const Headline4(
    this.text, {
    Key? key,
    this.textAlign,
    this.fontWeight,
    this.color,
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.headline4?.copyWith(
            fontWeight: fontWeight,
            color: color,
            fontSize: fontSize,
            fontStyle: FontStyle.normal,
          ),
      textAlign: textAlign,
    );
  }
}

class Headline5 extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final FontWeight? fontWeight;
  final Color? color;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? fontSize;
  final double? height;
  final String? fontFamily;

  const Headline5(
    this.text, {
    Key? key,
    this.textAlign,
    this.fontWeight,
    this.color,
    this.maxLines,
    this.overflow,
    this.fontSize,
    this.height,
    this.fontFamily,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.headline5?.copyWith(
            fontWeight: fontWeight,
            color: color,
            fontSize: fontSize,
            fontFamily: fontFamily,
            height: height,
          ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class Headline6 extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final FontWeight? fontWeight;
  final Color? color;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? fontSize;
  final double? height;
  final String? fontFamily;

  const Headline6(
    this.text, {
    Key? key,
    this.textAlign,
    this.fontWeight,
    this.color,
    this.maxLines,
    this.overflow,
    this.fontSize,
    this.height,
    this.fontFamily,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.headline6?.copyWith(
            fontWeight: fontWeight,
            color: color,
            fontSize: fontSize,
            fontFamily: fontFamily,
            height: height,
          ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class Subtitle2 extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final FontWeight? fontWeight;
  final Color? color;
  final int? maxLines;
  final TextOverflow? overflow;

  const Subtitle2(
    this.text, {
    Key? key,
    this.textAlign,
    this.fontWeight,
    this.color,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.subtitle2?.copyWith(
            fontWeight: fontWeight,
            color: color,
          ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class Subtitle extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final FontWeight? fontWeight;
  final Color? color;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? fontSize;

  const Subtitle(
    this.text, {
    Key? key,
    this.textAlign,
    this.fontWeight,
    this.color,
    this.maxLines,
    this.overflow,
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.subtitle1?.copyWith(
            fontWeight: fontWeight,
            fontSize: fontSize,
            color: color,
          ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class BodyText2 extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final FontWeight? fontWeight;
  final Color? color;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? fontSize;

  const BodyText2(
    this.text, {
    Key? key,
    this.textAlign,
    this.fontWeight,
    this.color,
    this.maxLines,
    this.overflow,
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyText2?.copyWith(
            fontWeight: fontWeight,
            fontSize: fontSize,
            color: color,
          ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class BodyText extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final FontWeight? fontWeight;
  final Color? color;
  final TextOverflow? overflow;
  final int? maxLines;
  final double? fontSize;

  const BodyText(
    this.text, {
    Key? key,
    this.textAlign,
    this.fontWeight,
    this.color,
    this.maxLines,
    this.overflow,
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyText1?.copyWith(
            fontWeight: fontWeight,
            fontSize: fontSize,
            color: color,
          ),
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}

///
/// Label
///

class Label3 extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final Color? color;
  final int? maxLines;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;

  const Label3(
    this.text, {
    this.textAlign,
    this.color,
    this.maxLines,
    this.overflow,
    this.fontWeight,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: fontWeight ?? FontWeight.w300,
            color: color,
          ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class Caption extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final FontWeight? fontWeight;
  final Color? color;

  const Caption(this.text, {Key? key, this.textAlign, this.fontWeight, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.caption?.copyWith(
            fontWeight: fontWeight,
            color: color,
          ),
      textAlign: textAlign,
    );
  }
}

class Link extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final FontWeight? fontWeight;
  final Color? color;
  final double? fontsize;

  const Link(
    this.text, {
    Key? key,
    this.textAlign,
    this.fontWeight,
    this.color,
    this.fontsize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.caption?.copyWith(
            color: color ?? Colors.orange,
            decoration: TextDecoration.underline,
            fontSize: fontsize,
          ),
      textAlign: textAlign,
    );
  }
}
