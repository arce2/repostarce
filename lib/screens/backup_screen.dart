import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../services/backup_service.dart';

/// Copia de seguridad de los datos personales guardados solo en el
/// dispositivo (favoritas, repostajes, tarjetas de descuento e histórico
/// de precios): exportarlos a un archivo, o restaurar uno anterior.
class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final _service = BackupService();
  bool _working = false;
  String? _message;
  bool _messageIsError = false;

  Future<void> _export() async {
    setState(() {
      _working = true;
      _message = null;
    });
    try {
      final json = await _service.buildBackupJson();
      final dir = await getTemporaryDirectory();
      final now = DateTime.now();
      final stamp = '${now.year}${now.month.toString().padLeft(2, '0')}'
          '${now.day.toString().padLeft(2, '0')}';
      final file = File('${dir.path}/repostarce-copia-$stamp.json');
      await file.writeAsString(json);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Copia de seguridad de Repostarce',
      );
    } catch (e) {
      setState(() {
        _message = 'No se ha podido exportar la copia: $e';
        _messageIsError = true;
      });
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _import() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Restaurar copia de seguridad?'),
        content: const Text(
          'Esto sobrescribirá tus favoritas, repostajes, tarjetas de '
          'descuento e histórico de precios actuales con los de la copia '
          'elegida. No se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() {
      _working = true;
      _message = null;
    });
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      final path = result?.files.single.path;
      if (path == null) {
        setState(() => _working = false);
        return;
      }
      final content = await File(path).readAsString();
      await _service.restoreFromJson(content);
      setState(() {
        _message = 'Copia restaurada correctamente.';
        _messageIsError = false;
      });
    } catch (e) {
      setState(() {
        _message = 'No se ha podido restaurar la copia: $e';
        _messageIsError = true;
      });
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Copia de seguridad')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Tus favoritas, repostajes, tarjetas de descuento e '
              'histórico de precios se guardan solo en este teléfono. Si '
              'lo cambias o desinstalas la app, se pierden a menos que '
              'hagas una copia antes.',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _working ? null : _export,
              icon: const Icon(Icons.upload_rounded),
              label: const Text('Exportar copia'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _working ? null : _import,
              icon: const Icon(Icons.download_rounded),
              label: const Text('Restaurar copia'),
            ),
            if (_working) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
            if (_message != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: _messageIsError
                      ? colorScheme.errorContainer
                      : colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  _message!,
                  style: TextStyle(
                    color: _messageIsError
                        ? colorScheme.onErrorContainer
                        : colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
