## 0.4.0

- `fromEJson<T>` now accepts a `defaultValue` argument that is returned if  
  `null` is passed as `ejson`.
- `fromEJson<T>` now accepts a `allowCustom` argument that can be used to specify
  the custom decoders are allowed to be used. Defaults to `null`, which specify that
  currently set value on the stack should be used. At top level the default is `true`.
- `register<T>` takes an optional `superTypes` argument to specify the super 
  types of `T` if needed.

## 0.3.1

- Update sane_uuid dependency to ^1.0.0 (compensate for breaking change)

## 0.3.0

- Rename `Key` class to `BsonKey` to avoid common conflict with flutter

## 0.2.0-pre.1

- First published version.

## 0.1.0

- Initial version.
