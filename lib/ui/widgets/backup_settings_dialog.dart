import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers/providers.dart';
import '../../services/backup_service.dart';

class BackupSettingsDialog extends ConsumerStatefulWidget {
  const BackupSettingsDialog({super.key});

  @override
  ConsumerState<BackupSettingsDialog> createState() => _BackupSettingsDialogState();
}

class _BackupSettingsDialogState extends ConsumerState<BackupSettingsDialog> {
  bool _isExporting = false;
  bool _isImporting = false;

  Future<void> _handleExport() async {
    setState(() => _isExporting = true);
    try {
      final backupService = ref.read(backupServiceProvider);
      await backupService.exportAndShare();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup erfolgreich erstellt!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Exportieren: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _handleImport() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip', 'gamestats', 'json'],
      );

      if (result == null || result.files.single.path == null) {
        return;
      }

      final file = File(result.files.single.path!);
      final backupService = ref.read(backupServiceProvider);

      setState(() => _isImporting = true);
      final preview = await backupService.parseBackupFile(file);
      setState(() => _isImporting = false);

      if (!mounted) return;

      final confirmedOption = await _showImportConfirmationDialog(preview);
      if (confirmedOption == null) return; // Cancelled

      final overwrite = confirmedOption == _ImportMode.overwrite;

      setState(() => _isImporting = true);
      await backupService.applyBackup(preview, overwrite: overwrite);

      if (mounted) {
        Navigator.of(context).pop(); // Close backup dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              overwrite
                ? 'Datenbank erfolgreich wiederhergestellt!'
                : 'Daten erfolgreich zusammengeführt!',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Importieren: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  Future<_ImportMode?> _showImportConfirmationDialog(BackupPreview preview) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    final dateString = preview.exportedAt != null
        ? dateFormat.format(preview.exportedAt!.toLocal())
        : 'Unbekannt';

    return showDialog<_ImportMode>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          icon: Icon(Icons.inventory_2_outlined, color: theme.colorScheme.primary, size: 32),
          title: const Text('Backup importieren'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Folgende Daten wurden in der Backup-Datei gefunden:',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.casino_outlined,
                      label: 'Spiele',
                      value: '${preview.gamesCount}',
                    ),
                    const SizedBox(height: 6),
                    _InfoRow(
                      icon: Icons.people_outline,
                      label: 'Spieler',
                      value: '${preview.playersCount}',
                    ),
                    const SizedBox(height: 6),
                    _InfoRow(
                      icon: Icons.history_edu_outlined,
                      label: 'Partien',
                      value: '${preview.matchesCount}',
                    ),
                    if (preview.imagesCount > 0) ...[
                      const SizedBox(height: 6),
                      _InfoRow(
                        icon: Icons.photo_library_outlined,
                        label: 'Bilder/Fotos',
                        value: '${preview.imagesCount}',
                      ),
                    ],
                    const Divider(height: 16),
                    _InfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Erstellt am',
                      value: dateString,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Wie möchtest du die Daten importieren?',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(null),
              child: const Text('Abbrechen'),
            ),
            OutlinedButton(
              onPressed: () => Navigator.of(dialogCtx).pop(_ImportMode.merge),
              child: const Text('Zusammenführen'),
            ),
            FilledButton.tonal(
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.errorContainer,
                foregroundColor: theme.colorScheme.onErrorContainer,
              ),
              onPressed: () => Navigator.of(dialogCtx).pop(_ImportMode.overwrite),
              child: const Text('Überschreiben'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.cloud_sync_outlined, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          const Text('Daten verwalten'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sichere deine Spieldaten, Spieler und Fotos als Datei oder importiere ein bestehendes Backup von einem anderen Gerät.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          if (_isExporting || _isImporting)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text(
                      _isExporting
                          ? 'Backup wird vorbereitet & verpackt...'
                          : 'Backup wird importiert...',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            )
          else ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(Icons.upload_file_outlined, color: theme.colorScheme.onPrimaryContainer),
              ),
              title: const Text('Datenbank exportieren'),
              subtitle: const Text('Erstellt ein ZIP-Archiv inklusive Fotos zum Teilen oder Speichern.'),
              onTap: _handleExport,
            ),
            const Divider(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.secondaryContainer,
                child: Icon(Icons.download_for_offline_outlined, color: theme.colorScheme.onSecondaryContainer),
              ),
              title: const Text('Datenbank importieren'),
              subtitle: const Text('Importiert Spiele, Spieler und Partien aus einem Backup (.zip oder .json).'),
              onTap: _handleImport,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: (_isExporting || _isImporting) ? null : () => Navigator.of(context).pop(),
          child: const Text('Schließen'),
        ),
      ],
    );
  }
}

enum _ImportMode { merge, overwrite }

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(label, style: theme.textTheme.bodyMedium),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
