import 'package:flutter/material.dart';

import '../l10n/l10n_x.dart';
import '../legal/legal_texts.dart';
import '../services/locale_service.dart';
import 'legal_screen.dart';

/// Ajustes de la app: por ahora, solo el selector de idioma.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.localeController});

  final LocaleController localeController;

  String _labelFor(BuildContext context, Locale? locale) {
    final l10n = context.l10n;
    if (locale == null) return l10n.settingsLanguageSystem;
    switch (locale.languageCode) {
      case 'es':
        return l10n.settingsLanguageSpanish;
      case 'en':
        return l10n.settingsLanguageEnglish;
      case 'fr':
        return l10n.settingsLanguageFrench;
      default:
        return locale.languageCode;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final options = <Locale?>[null, ...supportedAppLocales];

    return AnimatedBuilder(
      animation: localeController,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: Text(l10n.settingsTitle)),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Text(
                  l10n.settingsLanguageLabel,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              for (final option in options)
                RadioListTile<Locale?>(
                  // ignore: deprecated_member_use
                  value: option,
                  // ignore: deprecated_member_use
                  groupValue: localeController.locale,
                  // ignore: deprecated_member_use
                  onChanged: (value) => localeController.setLocale(value),
                  title: Text(_labelFor(context, option)),
                ),
              const Divider(height: 32),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Text(
                  l10n.settingsLegalLabel,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: Text(l10n.settingsPrivacyPolicy),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LegalScreen(
                      title: l10n.settingsPrivacyPolicy,
                      body: privacyPolicyText,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.gavel_outlined),
                title: Text(l10n.settingsLegalNotice),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LegalScreen(
                      title: l10n.settingsLegalNotice,
                      body: legalNoticeText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
