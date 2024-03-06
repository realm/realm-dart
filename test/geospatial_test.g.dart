// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geospatial_test.dart';

// **************************************************************************
// EJsonGenerator
// **************************************************************************

EJsonValue encodeLocation(Location value) {
  return {
    'type': value.type.toEJson(),
    'coordinates': value.coordinates.toEJson()
  };
}

Location decodeLocation(EJsonValue ejson) {
  return switch (ejson) {
    {'type': EJsonValue type, 'coordinates': EJsonValue coordinates} =>
      Location(
          type: type.to<String>(),
          coordinates: coordinates.to<Iterable<double>>()),
    _ => raiseInvalidEJson(ejson),
  };
}

extension LocationEJsonEncoderExtension on Location {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeLocation(this);
}

EJsonValue encodeRestaurant(Restaurant value) {
  return {'name': value.name.toEJson(), 'location': value.location.toEJson()};
}

Restaurant decodeRestaurant(EJsonValue ejson) {
  return switch (ejson) {
    {'name': EJsonValue name, 'location': EJsonValue location} =>
      Restaurant(name.to<String>(), location: location.to<Location?>()),
    _ => raiseInvalidEJson(ejson),
  };
}

extension RestaurantEJsonEncoderExtension on Restaurant {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeRestaurant(this);
}

EJsonValue encodeLocationList(LocationList value) {
  return {'locations': value.locations.toEJson()};
}

LocationList decodeLocationList(EJsonValue ejson) {
  return switch (ejson) {
    {'locations': EJsonValue locations} =>
      LocationList(locations: locations.to<Iterable<Location>>()),
    _ => raiseInvalidEJson(ejson),
  };
}

extension LocationListEJsonEncoderExtension on LocationList {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeLocationList(this);
}
