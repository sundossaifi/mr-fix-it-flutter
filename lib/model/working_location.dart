class WorkingLocation {
  late String _locality;
  late String _latitude;
  late String _longitude;

  WorkingLocation({
    required String locality,
    required String latitude,
    required String longitude,
  }) {
    _locality = locality;
    _latitude = latitude;
    _longitude = longitude;
  }

  String get locality => _locality;
  String get latitude => _latitude;
  String get longitude => _longitude;

  set locality(String locality) {
    _locality = locality;
  }

  set latitude(String latitude) {
    _latitude = latitude;
  }

  set longitude(String longitude) {
    _longitude = longitude;
  }

  Map<String, dynamic> toJson() {
    return {
      'locality': _locality,
      'latitude': _latitude,
      'longitude': _longitude,
    };
  }
}
