/// Annotation to mark a class for extended json (ejson) serialization
const ejson = EJson();

/// Annotation to mark a property to be ignored wrt. ejson serialization
const ignore = Ignore();

/// Annotation to mark a class for extended json (ejson) serialization
class EJson {
  const EJson();
}

/// Annotation to mark a property to be ignored wrt. ejson serialization
class Ignore {
  const Ignore();
}

enum EJsonType {
  array,
  binary,
  boolean,
  date,
  decimal128,
  document,
  double,
  int32,
  int64,
  maxKey,
  minKey,
  objectId,
  string,
  symbol,
  nil, // aka. null
  undefined,
  // TODO: The following is not supported yet
  // code,
  // codeWithScope,
  // databasePointer,
  // databaseRef,
  // regularExpression,
  // timestamp, // Why? Isn't this just a date?
}
