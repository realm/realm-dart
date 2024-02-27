// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test.dart';

// **************************************************************************
// EJsonGenerator
// **************************************************************************

EJsonValue encodeCar(Car value) {
  return {'make': value.make.toEJson()};
}

Car decodeCar(EJsonValue ejson) {
  return switch (ejson) {
    {'make': EJsonValue make} => Car(fromEJson(make)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension CarEJsonEncoderExtension on Car {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeCar(this);
}

EJsonValue encodePerson(Person value) {
  return {'name': value.name.toEJson()};
}

Person decodePerson(EJsonValue ejson) {
  return switch (ejson) {
    {'name': EJsonValue name} => Person(fromEJson(name)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension PersonEJsonEncoderExtension on Person {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodePerson(this);
}

EJsonValue encodeDog(Dog value) {
  return {
    'name': value.name.toEJson(),
    'age': value.age.toEJson(),
    'owner': value.owner.toEJson()
  };
}

Dog decodeDog(EJsonValue ejson) {
  return switch (ejson) {
    {
      'name': EJsonValue name,
      'age': EJsonValue age,
      'owner': EJsonValue owner
    } =>
      Dog(fromEJson(name), age: fromEJson(age), owner: fromEJson(owner)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension DogEJsonEncoderExtension on Dog {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeDog(this);
}

EJsonValue encodeTeam(Team value) {
  return {
    'name': value.name.toEJson(),
    'players': value.players.toEJson(),
    'scores': value.scores.toEJson()
  };
}

Team decodeTeam(EJsonValue ejson) {
  return switch (ejson) {
    {
      'name': EJsonValue name,
      'players': EJsonValue players,
      'scores': EJsonValue scores
    } =>
      Team(fromEJson(name),
          players: fromEJson(players), scores: fromEJson(scores)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension TeamEJsonEncoderExtension on Team {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeTeam(this);
}

EJsonValue encodeStudent(Student value) {
  return {
    'number': value.number.toEJson(),
    'name': value.name.toEJson(),
    'yearOfBirth': value.yearOfBirth.toEJson(),
    'school': value.school.toEJson()
  };
}

Student decodeStudent(EJsonValue ejson) {
  return switch (ejson) {
    {
      'number': EJsonValue number,
      'name': EJsonValue name,
      'yearOfBirth': EJsonValue yearOfBirth,
      'school': EJsonValue school
    } =>
      Student(fromEJson(number),
          name: fromEJson(name),
          yearOfBirth: fromEJson(yearOfBirth),
          school: fromEJson(school)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension StudentEJsonEncoderExtension on Student {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeStudent(this);
}

EJsonValue encodeSchool(School value) {
  return {
    'name': value.name.toEJson(),
    'city': value.city.toEJson(),
    'branchOfSchool': value.branchOfSchool.toEJson(),
    'students': value.students.toEJson(),
    'branches': value.branches.toEJson()
  };
}

School decodeSchool(EJsonValue ejson) {
  return switch (ejson) {
    {
      'name': EJsonValue name,
      'city': EJsonValue city,
      'branchOfSchool': EJsonValue branchOfSchool,
      'students': EJsonValue students,
      'branches': EJsonValue branches
    } =>
      School(fromEJson(name),
          city: fromEJson(city),
          branchOfSchool: fromEJson(branchOfSchool),
          students: fromEJson(students),
          branches: fromEJson(branches)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension SchoolEJsonEncoderExtension on School {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeSchool(this);
}

EJsonValue encodeRemappedClass(RemappedClass value) {
  return {
    'remappedProperty': value.remappedProperty.toEJson(),
    'listProperty': value.listProperty.toEJson()
  };
}

RemappedClass decodeRemappedClass(EJsonValue ejson) {
  return switch (ejson) {
    {
      'remappedProperty': EJsonValue remappedProperty,
      'listProperty': EJsonValue listProperty
    } =>
      RemappedClass(fromEJson(remappedProperty),
          listProperty: fromEJson(listProperty)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension RemappedClassEJsonEncoderExtension on RemappedClass {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeRemappedClass(this);
}

EJsonValue encodeTask(Task value) {
  return {'id': value.id.toEJson()};
}

Task decodeTask(EJsonValue ejson) {
  return switch (ejson) {
    {'id': EJsonValue id} => Task(fromEJson(id)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension TaskEJsonEncoderExtension on Task {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeTask(this);
}

EJsonValue encodeProduct(Product value) {
  return {'id': value.id.toEJson(), 'name': value.name.toEJson()};
}

Product decodeProduct(EJsonValue ejson) {
  return switch (ejson) {
    {'id': EJsonValue id, 'name': EJsonValue name} =>
      Product(fromEJson(id), fromEJson(name)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension ProductEJsonEncoderExtension on Product {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeProduct(this);
}

EJsonValue encodeSchedule(Schedule value) {
  return {'id': value.id.toEJson(), 'tasks': value.tasks.toEJson()};
}

Schedule decodeSchedule(EJsonValue ejson) {
  return switch (ejson) {
    {'id': EJsonValue id, 'tasks': EJsonValue tasks} =>
      Schedule(fromEJson(id), tasks: fromEJson(tasks)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension ScheduleEJsonEncoderExtension on Schedule {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeSchedule(this);
}

EJsonValue encodeFoo(Foo value) {
  return {
    'requiredBinaryProp': value.requiredBinaryProp.toEJson(),
    'defaultValueBinaryProp': value.defaultValueBinaryProp.toEJson(),
    'nullableBinaryProp': value.nullableBinaryProp.toEJson()
  };
}

Foo decodeFoo(EJsonValue ejson) {
  return switch (ejson) {
    {
      'requiredBinaryProp': EJsonValue requiredBinaryProp,
      'defaultValueBinaryProp': EJsonValue defaultValueBinaryProp,
      'nullableBinaryProp': EJsonValue nullableBinaryProp
    } =>
      Foo(fromEJson(requiredBinaryProp),
          defaultValueBinaryProp: fromEJson(defaultValueBinaryProp),
          nullableBinaryProp: fromEJson(nullableBinaryProp)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension FooEJsonEncoderExtension on Foo {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeFoo(this);
}

EJsonValue encodeAllTypes(AllTypes value) {
  return {
    'stringProp': value.stringProp.toEJson(),
    'boolProp': value.boolProp.toEJson(),
    'dateProp': value.dateProp.toEJson(),
    'doubleProp': value.doubleProp.toEJson(),
    'objectIdProp': value.objectIdProp.toEJson(),
    'uuidProp': value.uuidProp.toEJson(),
    'intProp': value.intProp.toEJson(),
    'decimalProp': value.decimalProp.toEJson(),
    'binaryProp': value.binaryProp.toEJson(),
    'nullableStringProp': value.nullableStringProp.toEJson(),
    'nullableBoolProp': value.nullableBoolProp.toEJson(),
    'nullableDateProp': value.nullableDateProp.toEJson(),
    'nullableDoubleProp': value.nullableDoubleProp.toEJson(),
    'nullableObjectIdProp': value.nullableObjectIdProp.toEJson(),
    'nullableUuidProp': value.nullableUuidProp.toEJson(),
    'nullableIntProp': value.nullableIntProp.toEJson(),
    'nullableDecimalProp': value.nullableDecimalProp.toEJson(),
    'nullableBinaryProp': value.nullableBinaryProp.toEJson()
  };
}

AllTypes decodeAllTypes(EJsonValue ejson) {
  return switch (ejson) {
    {
      'stringProp': EJsonValue stringProp,
      'boolProp': EJsonValue boolProp,
      'dateProp': EJsonValue dateProp,
      'doubleProp': EJsonValue doubleProp,
      'objectIdProp': EJsonValue objectIdProp,
      'uuidProp': EJsonValue uuidProp,
      'intProp': EJsonValue intProp,
      'decimalProp': EJsonValue decimalProp,
      'binaryProp': EJsonValue binaryProp,
      'nullableStringProp': EJsonValue nullableStringProp,
      'nullableBoolProp': EJsonValue nullableBoolProp,
      'nullableDateProp': EJsonValue nullableDateProp,
      'nullableDoubleProp': EJsonValue nullableDoubleProp,
      'nullableObjectIdProp': EJsonValue nullableObjectIdProp,
      'nullableUuidProp': EJsonValue nullableUuidProp,
      'nullableIntProp': EJsonValue nullableIntProp,
      'nullableDecimalProp': EJsonValue nullableDecimalProp,
      'nullableBinaryProp': EJsonValue nullableBinaryProp
    } =>
      AllTypes(
          fromEJson(stringProp),
          fromEJson(boolProp),
          fromEJson(dateProp),
          fromEJson(doubleProp),
          fromEJson(objectIdProp),
          fromEJson(uuidProp),
          fromEJson(intProp),
          fromEJson(decimalProp),
          binaryProp: fromEJson(binaryProp),
          nullableStringProp: fromEJson(nullableStringProp),
          nullableBoolProp: fromEJson(nullableBoolProp),
          nullableDateProp: fromEJson(nullableDateProp),
          nullableDoubleProp: fromEJson(nullableDoubleProp),
          nullableObjectIdProp: fromEJson(nullableObjectIdProp),
          nullableUuidProp: fromEJson(nullableUuidProp),
          nullableIntProp: fromEJson(nullableIntProp),
          nullableDecimalProp: fromEJson(nullableDecimalProp),
          nullableBinaryProp: fromEJson(nullableBinaryProp)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension AllTypesEJsonEncoderExtension on AllTypes {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeAllTypes(this);
}

EJsonValue encodeLinksClass(LinksClass value) {
  return {
    'id': value.id.toEJson(),
    'link': value.link.toEJson(),
    'list': value.list.toEJson()
  };
}

LinksClass decodeLinksClass(EJsonValue ejson) {
  return switch (ejson) {
    {'id': EJsonValue id, 'link': EJsonValue link, 'list': EJsonValue list} =>
      LinksClass(fromEJson(id), link: fromEJson(link), list: fromEJson(list)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension LinksClassEJsonEncoderExtension on LinksClass {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeLinksClass(this);
}

EJsonValue encodeAllCollections(AllCollections value) {
  return {
    'strings': value.strings.toEJson(),
    'bools': value.bools.toEJson(),
    'dates': value.dates.toEJson(),
    'doubles': value.doubles.toEJson(),
    'objectIds': value.objectIds.toEJson(),
    'uuids': value.uuids.toEJson(),
    'ints': value.ints.toEJson(),
    'decimals': value.decimals.toEJson(),
    'nullableStrings': value.nullableStrings.toEJson(),
    'nullableBools': value.nullableBools.toEJson(),
    'nullableDates': value.nullableDates.toEJson(),
    'nullableDoubles': value.nullableDoubles.toEJson(),
    'nullableObjectIds': value.nullableObjectIds.toEJson(),
    'nullableUuids': value.nullableUuids.toEJson(),
    'nullableInts': value.nullableInts.toEJson(),
    'nullableDecimals': value.nullableDecimals.toEJson()
  };
}

AllCollections decodeAllCollections(EJsonValue ejson) {
  return switch (ejson) {
    {
      'strings': EJsonValue strings,
      'bools': EJsonValue bools,
      'dates': EJsonValue dates,
      'doubles': EJsonValue doubles,
      'objectIds': EJsonValue objectIds,
      'uuids': EJsonValue uuids,
      'ints': EJsonValue ints,
      'decimals': EJsonValue decimals,
      'nullableStrings': EJsonValue nullableStrings,
      'nullableBools': EJsonValue nullableBools,
      'nullableDates': EJsonValue nullableDates,
      'nullableDoubles': EJsonValue nullableDoubles,
      'nullableObjectIds': EJsonValue nullableObjectIds,
      'nullableUuids': EJsonValue nullableUuids,
      'nullableInts': EJsonValue nullableInts,
      'nullableDecimals': EJsonValue nullableDecimals
    } =>
      AllCollections(
          strings: fromEJson(strings),
          bools: fromEJson(bools),
          dates: fromEJson(dates),
          doubles: fromEJson(doubles),
          objectIds: fromEJson(objectIds),
          uuids: fromEJson(uuids),
          ints: fromEJson(ints),
          decimals: fromEJson(decimals),
          nullableStrings: fromEJson(nullableStrings),
          nullableBools: fromEJson(nullableBools),
          nullableDates: fromEJson(nullableDates),
          nullableDoubles: fromEJson(nullableDoubles),
          nullableObjectIds: fromEJson(nullableObjectIds),
          nullableUuids: fromEJson(nullableUuids),
          nullableInts: fromEJson(nullableInts),
          nullableDecimals: fromEJson(nullableDecimals)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension AllCollectionsEJsonEncoderExtension on AllCollections {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeAllCollections(this);
}

EJsonValue encodeNullableTypes(NullableTypes value) {
  return {
    'id': value.id.toEJson(),
    'differentiator': value.differentiator.toEJson(),
    'stringProp': value.stringProp.toEJson(),
    'boolProp': value.boolProp.toEJson(),
    'dateProp': value.dateProp.toEJson(),
    'doubleProp': value.doubleProp.toEJson(),
    'objectIdProp': value.objectIdProp.toEJson(),
    'uuidProp': value.uuidProp.toEJson(),
    'intProp': value.intProp.toEJson(),
    'decimalProp': value.decimalProp.toEJson()
  };
}

NullableTypes decodeNullableTypes(EJsonValue ejson) {
  return switch (ejson) {
    {
      'id': EJsonValue id,
      'differentiator': EJsonValue differentiator,
      'stringProp': EJsonValue stringProp,
      'boolProp': EJsonValue boolProp,
      'dateProp': EJsonValue dateProp,
      'doubleProp': EJsonValue doubleProp,
      'objectIdProp': EJsonValue objectIdProp,
      'uuidProp': EJsonValue uuidProp,
      'intProp': EJsonValue intProp,
      'decimalProp': EJsonValue decimalProp
    } =>
      NullableTypes(fromEJson(id), fromEJson(differentiator),
          stringProp: fromEJson(stringProp),
          boolProp: fromEJson(boolProp),
          dateProp: fromEJson(dateProp),
          doubleProp: fromEJson(doubleProp),
          objectIdProp: fromEJson(objectIdProp),
          uuidProp: fromEJson(uuidProp),
          intProp: fromEJson(intProp),
          decimalProp: fromEJson(decimalProp)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension NullableTypesEJsonEncoderExtension on NullableTypes {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeNullableTypes(this);
}

EJsonValue encodeEvent(Event value) {
  return {
    'id': value.id.toEJson(),
    'name': value.name.toEJson(),
    'isCompleted': value.isCompleted.toEJson(),
    'durationInMinutes': value.durationInMinutes.toEJson(),
    'assignedTo': value.assignedTo.toEJson()
  };
}

Event decodeEvent(EJsonValue ejson) {
  return switch (ejson) {
    {
      'id': EJsonValue id,
      'name': EJsonValue name,
      'isCompleted': EJsonValue isCompleted,
      'durationInMinutes': EJsonValue durationInMinutes,
      'assignedTo': EJsonValue assignedTo
    } =>
      Event(fromEJson(id),
          name: fromEJson(name),
          isCompleted: fromEJson(isCompleted),
          durationInMinutes: fromEJson(durationInMinutes),
          assignedTo: fromEJson(assignedTo)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension EventEJsonEncoderExtension on Event {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeEvent(this);
}

EJsonValue encodeParty(Party value) {
  return {
    'year': value.year.toEJson(),
    'host': value.host.toEJson(),
    'previous': value.previous.toEJson(),
    'guests': value.guests.toEJson()
  };
}

Party decodeParty(EJsonValue ejson) {
  return switch (ejson) {
    {
      'year': EJsonValue year,
      'host': EJsonValue host,
      'previous': EJsonValue previous,
      'guests': EJsonValue guests
    } =>
      Party(fromEJson(year),
          host: fromEJson(host),
          previous: fromEJson(previous),
          guests: fromEJson(guests)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension PartyEJsonEncoderExtension on Party {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeParty(this);
}

EJsonValue encodeFriend(Friend value) {
  return {
    'name': value.name.toEJson(),
    'age': value.age.toEJson(),
    'bestFriend': value.bestFriend.toEJson(),
    'friends': value.friends.toEJson()
  };
}

Friend decodeFriend(EJsonValue ejson) {
  return switch (ejson) {
    {
      'name': EJsonValue name,
      'age': EJsonValue age,
      'bestFriend': EJsonValue bestFriend,
      'friends': EJsonValue friends
    } =>
      Friend(fromEJson(name),
          age: fromEJson(age),
          bestFriend: fromEJson(bestFriend),
          friends: fromEJson(friends)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension FriendEJsonEncoderExtension on Friend {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeFriend(this);
}

EJsonValue encodeWhen(When value) {
  return {
    'dateTimeUtc': value.dateTimeUtc.toEJson(),
    'locationName': value.locationName.toEJson()
  };
}

When decodeWhen(EJsonValue ejson) {
  return switch (ejson) {
    {
      'dateTimeUtc': EJsonValue dateTimeUtc,
      'locationName': EJsonValue locationName
    } =>
      When(fromEJson(dateTimeUtc), fromEJson(locationName)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension WhenEJsonEncoderExtension on When {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeWhen(this);
}

EJsonValue encodePlayer(Player value) {
  return {
    'name': value.name.toEJson(),
    'game': value.game.toEJson(),
    'scoresByRound': value.scoresByRound.toEJson()
  };
}

Player decodePlayer(EJsonValue ejson) {
  return switch (ejson) {
    {
      'name': EJsonValue name,
      'game': EJsonValue game,
      'scoresByRound': EJsonValue scoresByRound
    } =>
      Player(fromEJson(name),
          game: fromEJson(game), scoresByRound: fromEJson(scoresByRound)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension PlayerEJsonEncoderExtension on Player {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodePlayer(this);
}

EJsonValue encodeGame(Game value) {
  return {'winnerByRound': value.winnerByRound.toEJson()};
}

Game decodeGame(EJsonValue ejson) {
  return switch (ejson) {
    {'winnerByRound': EJsonValue winnerByRound} =>
      Game(winnerByRound: fromEJson(winnerByRound)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension GameEJsonEncoderExtension on Game {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeGame(this);
}

EJsonValue encodeAllTypesEmbedded(AllTypesEmbedded value) {
  return {
    'stringProp': value.stringProp.toEJson(),
    'boolProp': value.boolProp.toEJson(),
    'dateProp': value.dateProp.toEJson(),
    'doubleProp': value.doubleProp.toEJson(),
    'objectIdProp': value.objectIdProp.toEJson(),
    'uuidProp': value.uuidProp.toEJson(),
    'intProp': value.intProp.toEJson(),
    'decimalProp': value.decimalProp.toEJson(),
    'nullableStringProp': value.nullableStringProp.toEJson(),
    'nullableBoolProp': value.nullableBoolProp.toEJson(),
    'nullableDateProp': value.nullableDateProp.toEJson(),
    'nullableDoubleProp': value.nullableDoubleProp.toEJson(),
    'nullableObjectIdProp': value.nullableObjectIdProp.toEJson(),
    'nullableUuidProp': value.nullableUuidProp.toEJson(),
    'nullableIntProp': value.nullableIntProp.toEJson(),
    'nullableDecimalProp': value.nullableDecimalProp.toEJson(),
    'strings': value.strings.toEJson(),
    'bools': value.bools.toEJson(),
    'dates': value.dates.toEJson(),
    'doubles': value.doubles.toEJson(),
    'objectIds': value.objectIds.toEJson(),
    'uuids': value.uuids.toEJson(),
    'ints': value.ints.toEJson(),
    'decimals': value.decimals.toEJson()
  };
}

AllTypesEmbedded decodeAllTypesEmbedded(EJsonValue ejson) {
  return switch (ejson) {
    {
      'stringProp': EJsonValue stringProp,
      'boolProp': EJsonValue boolProp,
      'dateProp': EJsonValue dateProp,
      'doubleProp': EJsonValue doubleProp,
      'objectIdProp': EJsonValue objectIdProp,
      'uuidProp': EJsonValue uuidProp,
      'intProp': EJsonValue intProp,
      'decimalProp': EJsonValue decimalProp,
      'nullableStringProp': EJsonValue nullableStringProp,
      'nullableBoolProp': EJsonValue nullableBoolProp,
      'nullableDateProp': EJsonValue nullableDateProp,
      'nullableDoubleProp': EJsonValue nullableDoubleProp,
      'nullableObjectIdProp': EJsonValue nullableObjectIdProp,
      'nullableUuidProp': EJsonValue nullableUuidProp,
      'nullableIntProp': EJsonValue nullableIntProp,
      'nullableDecimalProp': EJsonValue nullableDecimalProp,
      'strings': EJsonValue strings,
      'bools': EJsonValue bools,
      'dates': EJsonValue dates,
      'doubles': EJsonValue doubles,
      'objectIds': EJsonValue objectIds,
      'uuids': EJsonValue uuids,
      'ints': EJsonValue ints,
      'decimals': EJsonValue decimals
    } =>
      AllTypesEmbedded(
          fromEJson(stringProp),
          fromEJson(boolProp),
          fromEJson(dateProp),
          fromEJson(doubleProp),
          fromEJson(objectIdProp),
          fromEJson(uuidProp),
          fromEJson(intProp),
          fromEJson(decimalProp),
          nullableStringProp: fromEJson(nullableStringProp),
          nullableBoolProp: fromEJson(nullableBoolProp),
          nullableDateProp: fromEJson(nullableDateProp),
          nullableDoubleProp: fromEJson(nullableDoubleProp),
          nullableObjectIdProp: fromEJson(nullableObjectIdProp),
          nullableUuidProp: fromEJson(nullableUuidProp),
          nullableIntProp: fromEJson(nullableIntProp),
          nullableDecimalProp: fromEJson(nullableDecimalProp),
          strings: fromEJson(strings),
          bools: fromEJson(bools),
          dates: fromEJson(dates),
          doubles: fromEJson(doubles),
          objectIds: fromEJson(objectIds),
          uuids: fromEJson(uuids),
          ints: fromEJson(ints),
          decimals: fromEJson(decimals)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension AllTypesEmbeddedEJsonEncoderExtension on AllTypesEmbedded {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeAllTypesEmbedded(this);
}

EJsonValue encodeObjectWithEmbedded(ObjectWithEmbedded value) {
  return {
    'id': value.id.toEJson(),
    'differentiator': value.differentiator.toEJson(),
    'singleObject': value.singleObject.toEJson(),
    'recursiveObject': value.recursiveObject.toEJson(),
    'list': value.list.toEJson(),
    'recursiveList': value.recursiveList.toEJson()
  };
}

ObjectWithEmbedded decodeObjectWithEmbedded(EJsonValue ejson) {
  return switch (ejson) {
    {
      'id': EJsonValue id,
      'differentiator': EJsonValue differentiator,
      'singleObject': EJsonValue singleObject,
      'recursiveObject': EJsonValue recursiveObject,
      'list': EJsonValue list,
      'recursiveList': EJsonValue recursiveList
    } =>
      ObjectWithEmbedded(fromEJson(id),
          differentiator: fromEJson(differentiator),
          singleObject: fromEJson(singleObject),
          recursiveObject: fromEJson(recursiveObject),
          list: fromEJson(list),
          recursiveList: fromEJson(recursiveList)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension ObjectWithEmbeddedEJsonEncoderExtension on ObjectWithEmbedded {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeObjectWithEmbedded(this);
}

EJsonValue encodeRecursiveEmbedded1(RecursiveEmbedded1 value) {
  return {
    'value': value.value.toEJson(),
    'child': value.child.toEJson(),
    'realmObject': value.realmObject.toEJson(),
    'children': value.children.toEJson()
  };
}

RecursiveEmbedded1 decodeRecursiveEmbedded1(EJsonValue ejson) {
  return switch (ejson) {
    {
      'value': EJsonValue value,
      'child': EJsonValue child,
      'realmObject': EJsonValue realmObject,
      'children': EJsonValue children
    } =>
      RecursiveEmbedded1(fromEJson(value),
          child: fromEJson(child),
          realmObject: fromEJson(realmObject),
          children: fromEJson(children)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension RecursiveEmbedded1EJsonEncoderExtension on RecursiveEmbedded1 {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeRecursiveEmbedded1(this);
}

EJsonValue encodeRecursiveEmbedded2(RecursiveEmbedded2 value) {
  return {
    'value': value.value.toEJson(),
    'child': value.child.toEJson(),
    'realmObject': value.realmObject.toEJson(),
    'children': value.children.toEJson()
  };
}

RecursiveEmbedded2 decodeRecursiveEmbedded2(EJsonValue ejson) {
  return switch (ejson) {
    {
      'value': EJsonValue value,
      'child': EJsonValue child,
      'realmObject': EJsonValue realmObject,
      'children': EJsonValue children
    } =>
      RecursiveEmbedded2(fromEJson(value),
          child: fromEJson(child),
          realmObject: fromEJson(realmObject),
          children: fromEJson(children)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension RecursiveEmbedded2EJsonEncoderExtension on RecursiveEmbedded2 {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeRecursiveEmbedded2(this);
}

EJsonValue encodeRecursiveEmbedded3(RecursiveEmbedded3 value) {
  return {'value': value.value.toEJson()};
}

RecursiveEmbedded3 decodeRecursiveEmbedded3(EJsonValue ejson) {
  return switch (ejson) {
    {'value': EJsonValue value} => RecursiveEmbedded3(fromEJson(value)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension RecursiveEmbedded3EJsonEncoderExtension on RecursiveEmbedded3 {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeRecursiveEmbedded3(this);
}

EJsonValue encodeObjectWithDecimal(ObjectWithDecimal value) {
  return {
    'decimal': value.decimal.toEJson(),
    'nullableDecimal': value.nullableDecimal.toEJson()
  };
}

ObjectWithDecimal decodeObjectWithDecimal(EJsonValue ejson) {
  return switch (ejson) {
    {
      'decimal': EJsonValue decimal,
      'nullableDecimal': EJsonValue nullableDecimal
    } =>
      ObjectWithDecimal(fromEJson(decimal),
          nullableDecimal: fromEJson(nullableDecimal)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension ObjectWithDecimalEJsonEncoderExtension on ObjectWithDecimal {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeObjectWithDecimal(this);
}

EJsonValue encodeAsymmetric(Asymmetric value) {
  return {
    'id': value.id.toEJson(),
    'symmetric': value.symmetric.toEJson(),
    'embeddedObjects': value.embeddedObjects.toEJson()
  };
}

Asymmetric decodeAsymmetric(EJsonValue ejson) {
  return switch (ejson) {
    {
      'id': EJsonValue id,
      'symmetric': EJsonValue symmetric,
      'embeddedObjects': EJsonValue embeddedObjects
    } =>
      Asymmetric(fromEJson(id),
          symmetric: fromEJson(symmetric),
          embeddedObjects: fromEJson(embeddedObjects)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension AsymmetricEJsonEncoderExtension on Asymmetric {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeAsymmetric(this);
}

EJsonValue encodeEmbedded(Embedded value) {
  return {
    'value': value.value.toEJson(),
    'any': value.any.toEJson(),
    'symmetric': value.symmetric.toEJson()
  };
}

Embedded decodeEmbedded(EJsonValue ejson) {
  return switch (ejson) {
    {
      'value': EJsonValue value,
      'any': EJsonValue any,
      'symmetric': EJsonValue symmetric
    } =>
      Embedded(fromEJson(value),
          any: fromEJson(any), symmetric: fromEJson(symmetric)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension EmbeddedEJsonEncoderExtension on Embedded {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeEmbedded(this);
}

EJsonValue encodeSymmetric(Symmetric value) {
  return {'id': value.id.toEJson()};
}

Symmetric decodeSymmetric(EJsonValue ejson) {
  return switch (ejson) {
    {'id': EJsonValue id} => Symmetric(fromEJson(id)),
    _ => raiseInvalidEJson(ejson),
  };
}

extension SymmetricEJsonEncoderExtension on Symmetric {
  @pragma('vm:prefer-inline')
  EJsonValue toEJson() => encodeSymmetric(this);
}
