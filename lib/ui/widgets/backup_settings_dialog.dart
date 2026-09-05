import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/l10n_extension.dart';
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
    final l10n = context.l10n;
    setState(() => _isExporting = true);
    try {
      final backupService = ref.read(backupServiceProvider);
      await backupService.exportAndShare();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.exportSuccess),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.exportError(e.toString())),
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
    final l10n = context.l10n;
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
                ? l10n.importSuccessOverwrite
                : l10n.importSuccessMerge,
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.importError(e.toString())),
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
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    final dateString = preview.exportedAt != null
        ? dateFormat.format(preview.exportedAt!.toLocal())
        : l10n.unknown;

    return showDialog<_ImportMode>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          icon: Icon(Icons.inventory_2_outlined, color: theme.colorScheme.primary, size: 32),
          title: Text(l10n.importDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.importDialogContent,
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
                      label: l10n.gamesCountLabel,
                      value: '${preview.gamesCount}',
                    ),
                    const SizedBox(height: 6),
                    _InfoRow(
                      icon: Icons.people_outline,
                      label: l10n.playersCountLabel,
                      value: '${preview.playersCount}',
                    ),
                    const SizedBox(height: 6),
                    _InfoRow(
                      icon: Icons.history_edu_outlined,
                      label: l10n.matchesCountLabel,
                      value: '${preview.matchesCount}',
                    ),
                    if (preview.imagesCount > 0) ...[
                      const SizedBox(height: 6),
                      _InfoRow(
                        icon: Icons.photo_library_outlined,
                        label: l10n.photosCountLabel,
                        value: '${preview.imagesCount}',
                      ),
                    ],
                    const Divider(height: 16),
                    _InfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: l10n.createdAtLabel,
                      value: dateString,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.importModeQuestion,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(null),
              child: Text(l10n.cancel),
            ),
            OutlinedButton(
              onPressed: () => Navigator.of(dialogCtx).pop(_ImportMode.merge),
              child: Text(l10n.merge),
            ),
            FilledButton.tonal(
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.errorContainer,
                foregroundColor: theme.colorScheme.onErrorContainer,
              ),
              onPressed: () => Navigator.of(dialogCtx).pop(_ImportMode.overwrite),
              child: Text(l10n.overwrite),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    final l10n = context.l10n;
    final currentLocale = ref.watch(localeProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.language, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              l10n.languageSectionTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<String>(
            segments: [
              ButtonSegment(
                value: 'system',
                label: Text(
                  l10n.languageSystem,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const ButtonSegment(
                value: 'de',
                label: Text(
                  '🇩🇪 DE',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              const ButtonSegment(
                value: 'en',
                label: Text(
                  '🇬🇧 EN',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
            selected: {
              currentLocale == null ? 'system' : currentLocale.languageCode,
            },
            onSelectionChanged: (Set<String> newSelection) {
              final val = newSelection.first;
              if (val == 'system') {
                ref.read(localeProvider.notifier).setLocale(null);
              } else {
                ref.read(localeProvider.notifier).setLocale(Locale(val));
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.settings_outlined, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Text(l10n.manageDataTitle),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLanguageSelector(context),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              l10n.manageDataDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
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
                            ? l10n.preparingBackup
                            : l10n.importingBackup,
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
                title: Text(l10n.exportDatabase),
                subtitle: Text(l10n.exportDatabaseSubtitle),
                onTap: _handleExport,
              ),
              const Divider(height: 24),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  child: Icon(Icons.download_for_offline_outlined, color: theme.colorScheme.onSecondaryContainer),
                ),
                title: Text(l10n.importDatabase),
                subtitle: Text(l10n.importDatabaseSubtitle),
                onTap: _handleImport,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: (_isExporting || _isImporting) ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.close),
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
