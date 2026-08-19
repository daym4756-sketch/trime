import 'dart:math';

double haversineDistanceKm(
  double lat1,
  double lng1,
  double lat2,
  double lng2,
) {
  const double earthRadiusKm = 6371.0;
  final double dLat = _degToRad(lat2 - lat1);
  final double dLng = _degToRad(lng2 - lng1);
  final double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_degToRad(lat1)) * cos(_degToRad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
  final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  final double distance = earthRadiusKm * c;
  return double.parse(distance.toStringAsFixed(2));
}

double _degToRad(double deg) => deg * (pi / 180);

class _DistanceItem<T> {
  final T item;
  final double distanceKm;
  _DistanceItem({required this.item, required this.distanceKm});
}

List<T> sortByDistance<T>({
  required List<T> items,
  required List<double> userPos,
  required double Function(T) getLat,
  required double Function(T) getLng,
}) {
  final userLat = userPos[0];
  final userLng = userPos[1];
  final list = items
      .map((item) => _DistanceItem<T>(
            item: item,
            distanceKm: haversineDistanceKm(
              userLat,
              userLng,
              getLat(item),
              getLng(item),
            ),
          ))
      .toList(growable: false)
    ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
  return list.map((e) => e.item).toList(growable: false);
}

List<T> sortByDistanceLatLng<T>({
  required List<T> items,
  required double userLat,
  required double userLng,
  required double Function(T) getLat,
  required double Function(T) getLng,
}) {
  final list = items
      .map((item) => _DistanceItem<T>(
            item: item,
            distanceKm: haversineDistanceKm(
              userLat,
              userLng,
              getLat(item),
              getLng(item),
            ),
          ))
      .toList(growable: false)
    ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
  return list.map((e) => e.item).toList(growable: false);
}
