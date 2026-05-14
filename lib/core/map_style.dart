import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapStyle {
  const MapStyle({
    required this.id,
    required this.label,
    required this.urlTemplate,
    required this.attribution,
    this.subdomains = const [],
    this.maxNativeZoom = 19,
    this.icon = Icons.layers_outlined,
  });

  final String id;
  final String label;
  final String urlTemplate;
  final String attribution;
  final List<String> subdomains;
  final int maxNativeZoom;
  final IconData icon;
}

/// Available basemap tile providers. All free / no API key required.
const List<MapStyle> kMapStyles = [
  MapStyle(
    id: 'osm',
    label: 'Mapa estándar',
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    attribution: '© OpenStreetMap',
    icon: Icons.map_outlined,
  ),
  MapStyle(
    id: 'satellite',
    label: 'Satélite',
    urlTemplate:
        'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
    attribution: '© Esri World Imagery',
    icon: Icons.satellite_alt_outlined,
  ),
  MapStyle(
    id: 'topo',
    label: 'Topográfico',
    urlTemplate: 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png',
    attribution: '© OpenTopoMap (CC-BY-SA)',
    subdomains: ['a', 'b', 'c'],
    maxNativeZoom: 17,
    icon: Icons.terrain_outlined,
  ),
  MapStyle(
    id: 'dark',
    label: 'Oscuro',
    urlTemplate:
        'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png',
    attribution: '© CartoDB / OpenStreetMap',
    subdomains: ['a', 'b', 'c', 'd'],
    icon: Icons.dark_mode_outlined,
  ),
];

class MapStyleController extends ValueNotifier<MapStyle> {
  MapStyleController._() : super(kMapStyles.first);

  static final MapStyleController instance = MapStyleController._();

  static const _key = 'map_style_id';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_key);
    value = kMapStyles.firstWhere(
      (s) => s.id == id,
      orElse: () => kMapStyles.first,
    );
  }

  Future<void> setStyle(MapStyle style) async {
    value = style;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, style.id);
  }
}
