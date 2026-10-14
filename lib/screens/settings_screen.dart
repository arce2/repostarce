import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/gen/app_localizations.dart';
import '../l10n/l10n_x.dart';
import '../legal/legal_texts.dart';
import '../services/backup_service.dart';
import '../services/locale_service.dart';
import 'legal_screen.dart';

/// Ajustes de la app: idioma, legal y copia de seguridad de los datos.
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

  Future<void> _exportData(BuildContext context) async {
    final l10n = context.l10n;
    try {
      final json = await BackupService().buildExport();
      final dir = await getTemporaryDirectory();
      final dateStamp = DateTime.now().toIso8601String().split('T').first;
      final file = File('${dir.path}/gasly_backup_$dateStamp.json');
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(json),
      );
      await Share.shareXFiles(
        [XFile(file.path)],
        text: l10n.settingsBackupShareText,
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsBackupExportError)),
      );
    }
  }

  Future<void> _importData(BuildContext context) async {
    final l10n = context.l10n;
    final pasteController = TextEditingController();
    final pasted = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.settingsBackupImportPasteTitle),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.settingsBackupImportPasteHint),
              const SizedBox(height: 12),
              TextField(
                controller: pasteController,
                maxLines: 8,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(pasteController.text),
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
    if (pasted == null || pasted.trim().isEmpty) return;

    Map<String, dynamic> json;
    try {
      json = jsonDecode(pasted) as Map<String, dynamic>;
      if (json['app'] != 'Gasly') throw const FormatException('not Gasly');
    } catch (_) {
      if (!context.mounted) return;
      await _showMessageDialog(
        context,
        title: l10n.settingsBackupImportErrorTitle,
        message: l10n.settingsBackupImportErrorMessage,
      );
      return;
    }

    if (!context.mounted) return;
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.settingsBackupImportConfirmTitle),
            content: Text(l10n.settingsBackupImportConfirmMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.commonCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(l10n.settingsBackupImportConfirmButton),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;

    await BackupService().restoreImport(json);
    if (!context.mounted) return;
    await _showMessageDialog(
      context,
      title: l10n.settingsBackupImportDoneTitle,
      message: l10n.settingsBackupImportDoneMessage,
    );
  }

  Future<void> _showMessageDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppLocalizations.of(dialogContext).commonOk),
          ),
        ],
      ),
    );
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
                  l10n.settingsBackupLabel,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  l10n.settingsBackupHint,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.upload_file_outlined),
                title: Text(l10n.settingsBackupExport),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _exportData(context),
              ),
              ListTile(
                leading: const Icon(Icons.download_outlined),
                title: Text(l10n.settingsBackupImport),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _importData(context),
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
