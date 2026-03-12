class AddressModel {
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final double latitude;
  final double longitude;
  final String? name;

  AddressModel({
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.name,
  });

  @override
  String toString() => "$street, $city, $state $postalCode, $country";
}
