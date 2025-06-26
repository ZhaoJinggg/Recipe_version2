import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/providers/language_provider.dart';

class LocalizedText extends StatelessWidget {
  final String englishText;
  final String? chineseText;
  final String? malayText;
  final TextStyle? style;

  const LocalizedText({
    Key? key,
    required this.englishText,
    this.chineseText,
    this.malayText,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        String text;
        switch (languageProvider.currentLocale.languageCode) {
          case 'zh':
            text = chineseText ?? englishText;
            break;
          case 'ms':
            text = malayText ?? englishText;
            break;
          default:
            text = englishText;
        }

        return Text(text, style: style);
      },
    );
  }
}

// Extension to provide localized strings
extension LocalizedStrings on BuildContext {
  String localizedString({
    required String en,
    String? zh,
    String? ms,
  }) {
    final languageProvider = Provider.of<LanguageProvider>(this, listen: false);
    switch (languageProvider.currentLocale.languageCode) {
      case 'zh':
        return zh ?? en;
      case 'ms':
        return ms ?? en;
      default:
        return en;
    }
  }
}
