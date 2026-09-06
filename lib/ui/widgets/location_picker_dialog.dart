import 'package:flutter/material.dart';

import '../../l10n/l10n_extension.dart';
import '../../services/location_service.dart';

class LocationPickerResult {
  final double? latitude;
  final double? longitude;
  final bool isDeleted;

  const LocationPickerResult({
    this.latitude,
    this.longitude,
    this.isDeleted = false,
  });
}

class LocationPickerDialog extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;

  const LocationPickerDialog({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  static Future<LocationPickerResult?> show({
    required BuildContext context,
    double? initialLatitude,
    double? initialLongitude,
  }) {
    return showModalBottomSheet<LocationPickerResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => LocationPickerDialog(
        initialLatitude: initialLatitude,
        initialLongitude: initialLongitude,
      ),
    );
  }

  @override
  State<LocationPickerDialog> createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<LocationPickerDialog> {
  final _searchController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  double? _currentLat;
  double? _currentLng;
  String? _resolvedAddress;

  bool _isLoadingGps = false;
  bool _isSearching = false;
  String? _errorMessage;
  bool _showManualCoordinates = false;

  @override
  void initState() {
    super.initState();
    _currentLat = widget.initialLatitude;
    _currentLng = widget.initialLongitude;

    if (_currentLat != null && _currentLng != null) {
      _latController.text = _currentLat!.toStringAsFixed(6);
      _lngController.text = _currentLng!.toStringAsFixed(6);
      _resolveInitialAddress(_currentLat!, _currentLng!);
    }
  }

  Future<void> _resolveInitialAddress(double lat, double lng) async {
    final address = await LocationService.getAddress(lat, lng);
    if (mounted) {
      setState(() {
        _resolvedAddress = address;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentGps() async {
    setState(() {
      _isLoadingGps = true;
      _errorMessage = null;
    });

    final position = await LocationService.getCurrentLocation();
    if (!mounted) return;

    if (position != null) {
      final address = await LocationService.getAddress(
        position.latitude,
        position.longitude,
      );
      if (!mounted) return;
      setState(() {
        _currentLat = position.latitude;
        _currentLng = position.longitude;
        _latController.text = position.latitude.toStringAsFixed(6);
        _lngController.text = position.longitude.toStringAsFixed(6);
        _resolvedAddress = address;
        _isLoadingGps = false;
      });
    } else {
      setState(() {
        _isLoadingGps = false;
        _errorMessage = context.l10n.locationPermissionDenied;
      });
    }
  }

  Future<void> _searchAddress() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    final result = await LocationService.searchCoordinatesFromAddress(query);
    if (!mounted) return;

    if (result != null) {
      setState(() {
        _currentLat = result.latitude;
        _currentLng = result.longitude;
        _latController.text = result.latitude.toStringAsFixed(6);
        _lngController.text = result.longitude.toStringAsFixed(6);
        _resolvedAddress = result.address;
        _isSearching = false;
      });
    } else {
      setState(() {
        _isSearching = false;
        _errorMessage = context.l10n.locationNotFound;
      });
    }
  }

  void _applyManualCoordinates() {
    final latText = _latController.text.trim().replaceAll(',', '.');
    final lngText = _lngController.text.trim().replaceAll(',', '.');
    final lat = double.tryParse(latText);
    final lng = double.tryParse(lngText);

    if (lat != null && lng != null && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
      setState(() {
        _currentLat = lat;
        _currentLng = lng;
        _errorMessage = null;
      });
      _resolveInitialAddress(lat, lng);
    } else {
      setState(() {
        _errorMessage = context.l10n.invalidCoordinates;
      });
    }
  }

  void _confirm() {
    if (_showManualCoordinates) {
      _applyManualCoordinates();
      if (_errorMessage != null) return;
    }

    Navigator.pop(
      context,
      LocationPickerResult(
        latitude: _currentLat,
        longitude: _currentLng,
        isDeleted: false,
      ),
    );
  }

  void _deleteLocation() {
    Navigator.pop(
      context,
      const LocationPickerResult(
        latitude: null,
        longitude: null,
        isDeleted: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final hasLocation = _currentLat != null && _currentLng != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Icon(
                  hasLocation ? Icons.edit_location_alt : Icons.add_location_alt,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  hasLocation ? l10n.editLocation : l10n.addLocation,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Current selected location preview
            if (hasLocation) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.place,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _resolvedAddress ?? '${_currentLat!.toStringAsFixed(4)}°, ${_currentLng!.toStringAsFixed(4)}°',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_currentLat!.toStringAsFixed(5)}°, ${_currentLng!.toStringAsFixed(5)}°',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                      tooltip: l10n.deleteLocation,
                      onPressed: () {
                        setState(() {
                          _currentLat = null;
                          _currentLng = null;
                          _resolvedAddress = null;
                          _latController.clear();
                          _lngController.clear();
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Action 1: Address / Place Search
            Text(
              l10n.searchAddressOrCity,
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchAddressHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        tooltip: l10n.confirm,
                        onPressed: _searchAddress,
                      ),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _searchAddress(),
            ),
            const SizedBox(height: 12),

            // Action 2: Use Current Location (GPS)
            OutlinedButton.icon(
              onPressed: _isLoadingGps ? null : _getCurrentGps,
              icon: _isLoadingGps
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: Text(
                _isLoadingGps ? l10n.searchingLocation : l10n.useCurrentLocation,
              ),
            ),
            const SizedBox(height: 12),

            // Action 3: Manual Coordinates (Expandable)
            InkWell(
              onTap: () {
                setState(() {
                  _showManualCoordinates = !_showManualCoordinates;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      _showManualCoordinates
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.manualCoordinates,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_showManualCoordinates) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _latController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration: InputDecoration(
                        labelText: l10n.latitudeLabel,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _lngController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration: InputDecoration(
                        labelText: l10n.longitudeLabel,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.check),
                    tooltip: l10n.apply,
                    onPressed: _applyManualCoordinates,
                  ),
                ],
              ),
            ],

            // Error Message display
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: theme.colorScheme.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Bottom action buttons
            Row(
              children: [
                if (widget.initialLatitude != null && widget.initialLongitude != null)
                  TextButton.icon(
                    onPressed: _deleteLocation,
                    icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                    label: Text(
                      l10n.deleteLocation,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: hasLocation ? _confirm : null,
                  child: Text(l10n.apply),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
