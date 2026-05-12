// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_history_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTripHistoryModelCollection on Isar {
  IsarCollection<TripHistoryModel> get tripHistoryModels => this.collection();
}

const TripHistoryModelSchema = CollectionSchema(
  name: r'TripHistoryModel',
  id: 4285509825201105969,
  properties: {
    r'endedAt': PropertySchema(
      id: 0,
      name: r'endedAt',
      type: IsarType.dateTime,
    ),
    r'hostName': PropertySchema(
      id: 1,
      name: r'hostName',
      type: IsarType.string,
    ),
    r'latitudes': PropertySchema(
      id: 2,
      name: r'latitudes',
      type: IsarType.doubleList,
    ),
    r'longitudes': PropertySchema(
      id: 3,
      name: r'longitudes',
      type: IsarType.doubleList,
    ),
    r'memberNames': PropertySchema(
      id: 4,
      name: r'memberNames',
      type: IsarType.stringList,
    ),
    r'startedAt': PropertySchema(
      id: 5,
      name: r'startedAt',
      type: IsarType.dateTime,
    ),
    r'totalDistance': PropertySchema(
      id: 6,
      name: r'totalDistance',
      type: IsarType.double,
    )
  },
  estimateSize: _tripHistoryModelEstimateSize,
  serialize: _tripHistoryModelSerialize,
  deserialize: _tripHistoryModelDeserialize,
  deserializeProp: _tripHistoryModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _tripHistoryModelGetId,
  getLinks: _tripHistoryModelGetLinks,
  attach: _tripHistoryModelAttach,
  version: '3.1.0+1',
);

int _tripHistoryModelEstimateSize(
  TripHistoryModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.hostName.length * 3;
  bytesCount += 3 + object.latitudes.length * 8;
  bytesCount += 3 + object.longitudes.length * 8;
  bytesCount += 3 + object.memberNames.length * 3;
  {
    for (var i = 0; i < object.memberNames.length; i++) {
      final value = object.memberNames[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _tripHistoryModelSerialize(
  TripHistoryModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.endedAt);
  writer.writeString(offsets[1], object.hostName);
  writer.writeDoubleList(offsets[2], object.latitudes);
  writer.writeDoubleList(offsets[3], object.longitudes);
  writer.writeStringList(offsets[4], object.memberNames);
  writer.writeDateTime(offsets[5], object.startedAt);
  writer.writeDouble(offsets[6], object.totalDistance);
}

TripHistoryModel _tripHistoryModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TripHistoryModel();
  object.endedAt = reader.readDateTime(offsets[0]);
  object.hostName = reader.readString(offsets[1]);
  object.id = id;
  object.latitudes = reader.readDoubleList(offsets[2]) ?? [];
  object.longitudes = reader.readDoubleList(offsets[3]) ?? [];
  object.memberNames = reader.readStringList(offsets[4]) ?? [];
  object.startedAt = reader.readDateTime(offsets[5]);
  object.totalDistance = reader.readDouble(offsets[6]);
  return object;
}

P _tripHistoryModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDoubleList(offset) ?? []) as P;
    case 3:
      return (reader.readDoubleList(offset) ?? []) as P;
    case 4:
      return (reader.readStringList(offset) ?? []) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _tripHistoryModelGetId(TripHistoryModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _tripHistoryModelGetLinks(TripHistoryModel object) {
  return [];
}

void _tripHistoryModelAttach(
    IsarCollection<dynamic> col, Id id, TripHistoryModel object) {
  object.id = id;
}

extension TripHistoryModelQueryWhereSort
    on QueryBuilder<TripHistoryModel, TripHistoryModel, QWhere> {
  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TripHistoryModelQueryWhere
    on QueryBuilder<TripHistoryModel, TripHistoryModel, QWhereClause> {
  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TripHistoryModelQueryFilter
    on QueryBuilder<TripHistoryModel, TripHistoryModel, QFilterCondition> {
  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      endedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      endedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      endedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      endedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      hostNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hostName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      hostNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hostName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      hostNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hostName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      hostNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hostName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      hostNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'hostName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      hostNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'hostName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      hostNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'hostName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      hostNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'hostName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      hostNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hostName',
        value: '',
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      hostNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'hostName',
        value: '',
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      latitudesElementEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'latitudes',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      latitudesElementGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'latitudes',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      latitudesElementLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'latitudes',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      latitudesElementBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'latitudes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      latitudesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'latitudes',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      latitudesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'latitudes',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      latitudesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'latitudes',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      latitudesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'latitudes',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      latitudesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'latitudes',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      latitudesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'latitudes',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      longitudesElementEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longitudes',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      longitudesElementGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'longitudes',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      longitudesElementLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'longitudes',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      longitudesElementBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'longitudes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      longitudesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'longitudes',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      longitudesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'longitudes',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      longitudesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'longitudes',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      longitudesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'longitudes',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      longitudesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'longitudes',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      longitudesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'longitudes',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      memberNamesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'memberNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      memberNamesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'memberNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      memberNamesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'memberNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      memberNamesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'memberNames',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      memberNamesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'memberNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      memberNamesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'memberNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      memberNamesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'memberNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      memberNamesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'memberNames',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      memberNamesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'memberNames',
        value: '',
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      memberNamesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'memberNames',
        value: '',
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      memberNamesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'memberNames',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      memberNamesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'memberNames',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      memberNamesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'memberNames',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      memberNamesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'memberNames',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      memberNamesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'memberNames',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      memberNamesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'memberNames',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      startedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      startedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      startedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      startedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      totalDistanceEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalDistance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      totalDistanceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalDistance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      totalDistanceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalDistance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterFilterCondition>
      totalDistanceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalDistance',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension TripHistoryModelQueryObject
    on QueryBuilder<TripHistoryModel, TripHistoryModel, QFilterCondition> {}

extension TripHistoryModelQueryLinks
    on QueryBuilder<TripHistoryModel, TripHistoryModel, QFilterCondition> {}

extension TripHistoryModelQuerySortBy
    on QueryBuilder<TripHistoryModel, TripHistoryModel, QSortBy> {
  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterSortBy>
      sortByEndedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endedAt', Sort.asc);
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterSortBy>
      sortByEndedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endedAt', Sort.desc);
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterSortBy>
      sortByHostName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hostName', Sort.asc);
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterSortBy>
      sortByHostNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hostName', Sort.desc);
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterSortBy>
      sortByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterSortBy>
      sortByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterSortBy>
      sortByTotalDistance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDistance', Sort.asc);
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterSortBy>
      sortByTotalDistanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDistance', Sort.desc);
    });
  }
}

extension TripHistoryModelQuerySortThenBy
    on QueryBuilder<TripHistoryModel, TripHistoryModel, QSortThenBy> {
  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterSortBy>
      thenByEndedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endedAt', Sort.asc);
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterSortBy>
      thenByEndedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endedAt', Sort.desc);
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterSortBy>
      thenByHostName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hostName', Sort.asc);
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterSortBy>
      thenByHostNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hostName', Sort.desc);
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterSortBy>
      thenByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.asc);
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterSortBy>
      thenByStartedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAt', Sort.desc);
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterSortBy>
      thenByTotalDistance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDistance', Sort.asc);
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QAfterSortBy>
      thenByTotalDistanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDistance', Sort.desc);
    });
  }
}

extension TripHistoryModelQueryWhereDistinct
    on QueryBuilder<TripHistoryModel, TripHistoryModel, QDistinct> {
  QueryBuilder<TripHistoryModel, TripHistoryModel, QDistinct>
      distinctByEndedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endedAt');
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QDistinct>
      distinctByHostName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hostName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QDistinct>
      distinctByLatitudes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'latitudes');
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QDistinct>
      distinctByLongitudes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longitudes');
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QDistinct>
      distinctByMemberNames() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'memberNames');
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QDistinct>
      distinctByStartedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startedAt');
    });
  }

  QueryBuilder<TripHistoryModel, TripHistoryModel, QDistinct>
      distinctByTotalDistance() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalDistance');
    });
  }
}

extension TripHistoryModelQueryProperty
    on QueryBuilder<TripHistoryModel, TripHistoryModel, QQueryProperty> {
  QueryBuilder<TripHistoryModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TripHistoryModel, DateTime, QQueryOperations> endedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endedAt');
    });
  }

  QueryBuilder<TripHistoryModel, String, QQueryOperations> hostNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hostName');
    });
  }

  QueryBuilder<TripHistoryModel, List<double>, QQueryOperations>
      latitudesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'latitudes');
    });
  }

  QueryBuilder<TripHistoryModel, List<double>, QQueryOperations>
      longitudesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longitudes');
    });
  }

  QueryBuilder<TripHistoryModel, List<String>, QQueryOperations>
      memberNamesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'memberNames');
    });
  }

  QueryBuilder<TripHistoryModel, DateTime, QQueryOperations>
      startedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startedAt');
    });
  }

  QueryBuilder<TripHistoryModel, double, QQueryOperations>
      totalDistanceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalDistance');
    });
  }
}
