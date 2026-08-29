import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationService {
  static final Map<String, String> _addressCache = {};

  /// Silently attempts to get current GPS coordinates.
  /// Returns null if permissions are denied, location services are disabled, or on timeout.
  static Future<Position?> getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // Medium accuracy is fast and battery-friendly, with a 4s timeout so save is never delayed
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      debugPrint('LocationService error: $e');
      return null;
    }
  }

  /// Resolves human-readable place/city name from coordinates with in-memory caching.
  static Future<String> getAddress(double latitude, double longitude) async {
    final key = '${latitude.toStringAsFixed(4)},${longitude.toStringAsFixed(4)}';
    if (_addressCache.containsKey(key)) {
      return _addressCache[key]!;
    }

    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = <String>[];
        if (p.locality != null && p.locality!.trim().isNotEmpty) {
          parts.add(p.locality!.trim());
        } else if (p.subAdministrativeArea != null && p.subAdministrativeArea!.trim().isNotEmpty) {
          parts.add(p.subAdministrativeArea!.trim());
        }

        if (p.country != null && p.country!.trim().isNotEmpty) {
          parts.add(p.country!.trim());
        }

        final address = parts.isNotEmpty
            ? parts.join(', ')
            : '${latitude.toStringAsFixed(4)}°, ${longitude.toStringAsFixed(4)}°';
        _addressCache[key] = address;
        return address;
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
    }

    final fallback = '${latitude.toStringAsFixed(4)}°, ${longitude.toStringAsFixed(4)}°';
    _addressCache[key] = fallback;
    return fallback;
  }

  /// Opens the location in Google Maps / Apple Maps / Map App.
  static Future<void> openMap(double latitude, double longitude) async {
    final geoUri = Uri.parse('geo:$latitude,$longitude?q=$latitude,$longitude');
    final webUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');

    try {
      if (await canLaunchUrl(geoUri)) {
        await launchUrl(geoUri);
      } else if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Could not open map: $e');
    }
  }
}
