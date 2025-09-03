# Geospatial - Flutter SDK
> Version added: 1.6.0

Geospatial data, or "geodata", specifies points and geometric objects on the
Earth's surface. With the geodata types, you can create queries that check
whether a given point is contained within a shape. For example, you can find
all coffee shops within 15 km of a specified point.

## Geospatial Data Types
The Flutter SDK supports geospatial queries using the following data types:

- `GeoPoint`
- `GeoCircle`
- `GeoBox`

The SDK provides these geospatial data types to simplify querying geospatial
data. You *cannot* persist these data types directly.

For information on how to persist geospatial data, refer to the
Persist Geospatial Data section on this page.

### GeoPoint
A [GeoPoint](https://pub.dev/documentation/realm/latest/realm/GeoPoint-class.html) defines a specific
location on the Earth's surface. All of the geospatial data types use
`GeoPoints` to define their location.

A `GeoPoint` is an object with two required properties:

- `lat`: a double value
- `lon`: a double value

A GeoPoint is used only as a building block of the other shapes:
GeoCircle and GeoBox. These shapes, and the GeoPoint type,
are used in queries, not for persistence.

To save geospatial data to the database, refer to
Persist Geospatial Data.

### GeoCircle
A [GeoCircle](https://pub.dev/documentation/realm/latest/realm/GeoCircle-class.html) defines a circle on
the Earth's surface. You define a `GeoCircle` by providing:

- A `GeoPoint` for the center of the circle
- A `GeoDistance` for the distance (radius) of the circle

The radius distance uses radians as the unit of measure, implemented as
a double in the SDK. The SDK provides convenience methods to create a
`GeoDistance` from other units of measure:

- [GeoDistance.fromDegrees()](https://pub.dev/documentation/realm/latest/realm/GeoDistance/GeoDistance.fromDegrees.html)
- [GeoDistance.fromKilometers()](https://pub.dev/documentation/realm/latest/realm/GeoDistance/GeoDistance.fromKilometers.html)
- [GeoDistance.fromMeters()](https://pub.dev/documentation/realm/latest/realm/GeoDistance/GeoDistance.fromMeters.html)
- [GeoDistance.fromMiles()](https://pub.dev/documentation/realm/latest/realm/GeoDistance/GeoDistance.fromMiles.html)

The following code shows two examples of creating a circle:

```dart
final smallCircle =
    GeoCircle(GeoPoint(lon: -121.9, lat: 47.3), 0.25.degrees);

final largeCircleCenter = GeoPoint(lon: -122.6, lat: 47.8);

// The SDK provides convenience methods to convert measurements to radians.
final radiusFromKm = GeoDistance.fromKilometers(44.4);

final largeCircle = GeoCircle(largeCircleCenter, radiusFromKm);
```

![Two GeoCircles](../../images/geocircles.png)

### GeoBox
A [GeoBox](https://pub.dev/documentation/realm/latest/realm/GeoBox-class.html) defines a
rectangle on the Earth's surface. You define the rectangle by specifying
the bottom left (southwest) corner and the top right (northeast) corner.

The following example creates 2 boxes:

```dart
final largeBox = GeoBox(
    GeoPoint(lon: -122.7, lat: 47.3), GeoPoint(lon: -122.1, lat: 48.1));

final smallBoxSouthWest = GeoPoint(lon: -122.4, lat: 47.5);
final smallBoxNorthEast = GeoPoint(lon: -121.8, lat: 47.9);
final smallBox = GeoBox(smallBoxSouthWest, smallBoxNorthEast);
```

![2 GeoBoxes](../../images/geoboxes.png)

## Persist Geospatial Data
> **IMPORTANT:**
> Currently, you can only persist geospatial data. Geospatial data
> types *cannot* be persisted directly. For example, you can't declare
> a property that is of type `GeoBox`.
>
> These types can only be used as arguments for geospatial queries.
>

If you want to persist geospatial data, it must conform to the
[GeoJSON spec](https://datatracker.ietf.org/doc/html/rfc7946).

### Create a GeoJSON-Compatible Class
To create a class that conforms to the GeoJSON spec, you:

1. Create an embedded object. For more information about embedded
objects, refer to Embedded Objects.
2. At a minimum, add the two fields required by the GeoJSON spec: A field of type `double[]` that maps to a "coordinates" (case sensitive)
property in the schema.A field of type `string` that maps to a "type" property. The value of this
field must be "Point".

The following example shows an embedded class named `MyGeoPoint` that is
used to persist geospatial data:

```dart
// To store geospatial data, create an embedded object with this structure.
// Name it whatever is most convenient for your application.
@RealmModel(ObjectType.embeddedObject)
class _MyGeoPoint {
  // These two properties are required to persist geo data.
  final String type = 'Point';
  final List<double> coordinates = const [];

  // You can optionally implement convenience methods to simplify
  // creating and working with geospatial data.
  double get lon => coordinates[0];
  set lon(double value) => coordinates[0] = value;

  double get lat => coordinates[1];
  set lat(double value) => coordinates[1] = value;

  GeoPoint toGeoPoint() => GeoPoint(lon: lon, lat: lat);
}
```

### Use the Embedded Class
You then use the custom `MyGeoPoint` class in your data model, as shown
in the following example:

```dart
// Use the GeoJSON-compatible class as a property in your model.
@RealmModel()
class _Company {
  @PrimaryKey()
  late ObjectId id;
  _MyGeoPoint? location;
}
```

You add instances of your class to the database just like any other model.

```dart
final realm =
    Realm(Configuration.local([MyGeoPoint.schema, Company.schema]));

realm.write(() {
  realm.addAll([
    Company(
      firstCompanyID,
      location: MyGeoPoint(coordinates: [-122.35, 47.68]),
    ),
    Company(
      secondCompanyID,
      location: MyGeoPoint(coordinates: [-121.85, 47.9]),
    )
  ]);
});
```

The following image shows the results of creating these two company objects.

![2 GeoPoints](../../images/geopoints.png)

## Query Geospatial Data
To query against geospatial data, you can use the `geoWithin` operator
with RQL. The `geoWithin` operator takes the "coordinates"
property of an embedded object that defines the point we're querying, and
one of the geospatial shapes to check if that point is contained within
the shape.

> Note:
> The format for querying geospatial data is the same, regardless of
> the shape of the geodata region.
>

The following examples show querying against various shapes to return a list of
companies within the shape:

**GeoCircle**

```dart
final companiesInSmallCircle =
    realm.query<Company>("location geoWithin \$0", [smallCircle]);

final companiesInLargeCircle =
    realm.query<Company>("location geoWithin \$0", [largeCircle]);
```

![Querying a GeoCircle example.](../../images/geocircles-query.png)

**GeoBox**

```dart
final companiesInLargeBox =
    realm.query<Company>("location geoWithin \$0", [largeBox]);
final companiesInSmallBox =
    realm.query<Company>("location geoWithin \$0", [smallBox]);
```

![Querying a GeoBox example.](../../images/geoboxes-query.png)
