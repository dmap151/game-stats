// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMatchRecordCollection on Isar {
  IsarCollection<MatchRecord> get matchRecords => this.collection();
}

const MatchRecordSchema = CollectionSchema(
  name: r'MatchRecord',
  id: -3321931835933376304,
  properties: {
    r'date': PropertySchema(
      id: 0,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'imagePath': PropertySchema(
      id: 1,
      name: r'imagePath',
      type: IsarType.string,
    ),
    r'imagePaths': PropertySchema(
      id: 2,
      name: r'imagePaths',
      type: IsarType.stringList,
    ),
    r'numberOfPlayers': PropertySchema(
      id: 3,
      name: r'numberOfPlayers',
      type: IsarType.long,
    ),
    r'playerScores': PropertySchema(
      id: 4,
      name: r'playerScores',
      type: IsarType.objectList,
      target: r'PlayerScore',
    )
  },
  estimateSize: _matchRecordEstimateSize,
  serialize: _matchRecordSerialize,
  deserialize: _matchRecordDeserialize,
  deserializeProp: _matchRecordDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'game': LinkSchema(
      id: -8744576982167377353,
      name: r'game',
      target: r'Game',
      single: true,
    )
  },
  embeddedSchemas: {r'PlayerScore': PlayerScoreSchema},
  getId: _matchRecordGetId,
  getLinks: _matchRecordGetLinks,
  attach: _matchRecordAttach,
  version: '3.1.0+1',
);

int _matchRecordEstimateSize(
  MatchRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.imagePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.imagePaths.length * 3;
  {
    for (var i = 0; i < object.imagePaths.length; i++) {
      final value = object.imagePaths[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.playerScores.length * 3;
  {
    final offsets = allOffsets[PlayerScore]!;
    for (var i = 0; i < object.playerScores.length; i++) {
      final value = object.playerScores[i];
      bytesCount += PlayerScoreSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  return bytesCount;
}

void _matchRecordSerialize(
  MatchRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.date);
  writer.writeString(offsets[1], object.imagePath);
  writer.writeStringList(offsets[2], object.imagePaths);
  writer.writeLong(offsets[3], object.numberOfPlayers);
  writer.writeObjectList<PlayerScore>(
    offsets[4],
    allOffsets,
    PlayerScoreSchema.serialize,
    object.playerScores,
  );
}

MatchRecord _matchRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MatchRecord();
  object.date = reader.readDateTime(offsets[0]);
  object.id = id;
  object.imagePath = reader.readStringOrNull(offsets[1]);
  object.imagePaths = reader.readStringList(offsets[2]) ?? [];
  object.numberOfPlayers = reader.readLong(offsets[3]);
  object.playerScores = reader.readObjectList<PlayerScore>(
        offsets[4],
        PlayerScoreSchema.deserialize,
        allOffsets,
        PlayerScore(),
      ) ??
      [];
  return object;
}

P _matchRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringList(offset) ?? []) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readObjectList<PlayerScore>(
            offset,
            PlayerScoreSchema.deserialize,
            allOffsets,
            PlayerScore(),
          ) ??
          []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _matchRecordGetId(MatchRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _matchRecordGetLinks(MatchRecord object) {
  return [object.game];
}

void _matchRecordAttach(
    IsarCollection<dynamic> col, Id id, MatchRecord object) {
  object.id = id;
  object.game.attach(col, col.isar.collection<Game>(), r'game', id);
}

extension MatchRecordQueryWhereSort
    on QueryBuilder<MatchRecord, MatchRecord, QWhere> {
  QueryBuilder<MatchRecord, MatchRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MatchRecordQueryWhere
    on QueryBuilder<MatchRecord, MatchRecord, QWhereClause> {
  QueryBuilder<MatchRecord, MatchRecord, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<MatchRecord, MatchRecord, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterWhereClause> idBetween(
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

extension MatchRecordQueryFilter
    on QueryBuilder<MatchRecord, MatchRecord, QFilterCondition> {
  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition> dateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition> dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition> dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition> dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition> idBetween(
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

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition>
      imagePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'imagePath',
      ));
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition>
      imagePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'imagePath',
      ));
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition>
      imagePathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition>
      imagePathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition>
      imagePathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition>
      imagePathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imagePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition>
      imagePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'imagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition>
      imagePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'imagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition>
      imagePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition>
      imagePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imagePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition>
      imagePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition>
      imagePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition>
      imagePathsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imagePaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition>
      imagePathsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imagePaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition>
      imagePathsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imagePaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition>
      imagePathsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imagePaths',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition>
      imagePathsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'imagePaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition>
      imagePathsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'imagePaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition>
      imagePathsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imagePaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition>
      imagePathsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imagePaths',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition>
      imagePathsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imagePaths',
        value: '',
      ));
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition>
      imagePathsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imagePaths',
        value: '',
      ));
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition>
      imagePathsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imagePaths',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition>
      imagePathsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imagePaths',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition>
      imagePathsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imagePaths',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition>
      imagePathsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imagePaths',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition>
      imagePathsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imagePaths',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition>
      imagePathsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imagePaths',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition>
      numberOfPlayersEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'numberOfPlayers',
        value: value,
      ));
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition>
      numberOfPlayersGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'numberOfPlayers',
        value: value,
      ));
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition>
      numberOfPlayersLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'numberOfPlayers',
        value: value,
      ));
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition>
      numberOfPlayersBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'numberOfPlayers',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition>
      playerScoresLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'playerScores',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition>
      playerScoresIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'playerScores',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition>
      playerScoresIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'playerScores',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition>
      playerScoresLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'playerScores',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition>
      playerScoresLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'playerScores',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition>
      playerScoresLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'playerScores',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension MatchRecordQueryObject
    on QueryBuilder<MatchRecord, MatchRecord, QFilterCondition> {
  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition>
      playerScoresElement(FilterQuery<PlayerScore> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'playerScores');
    });
  }
}

extension MatchRecordQueryLinks
    on QueryBuilder<MatchRecord, MatchRecord, QFilterCondition> {
  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition> game(
      FilterQuery<Game> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'game');
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterFilterCondition> gameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'game', 0, true, 0, true);
    });
  }
}

extension MatchRecordQuerySortBy
    on QueryBuilder<MatchRecord, MatchRecord, QSortBy> {
  QueryBuilder<MatchRecord, MatchRecord, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterSortBy> sortByImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagePath', Sort.asc);
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterSortBy> sortByImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagePath', Sort.desc);
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterSortBy> sortByNumberOfPlayers() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numberOfPlayers', Sort.asc);
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterSortBy>
      sortByNumberOfPlayersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numberOfPlayers', Sort.desc);
    });
  }
}

extension MatchRecordQuerySortThenBy
    on QueryBuilder<MatchRecord, MatchRecord, QSortThenBy> {
  QueryBuilder<MatchRecord, MatchRecord, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterSortBy> thenByImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagePath', Sort.asc);
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterSortBy> thenByImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagePath', Sort.desc);
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterSortBy> thenByNumberOfPlayers() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numberOfPlayers', Sort.asc);
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QAfterSortBy>
      thenByNumberOfPlayersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numberOfPlayers', Sort.desc);
    });
  }
}

extension MatchRecordQueryWhereDistinct
    on QueryBuilder<MatchRecord, MatchRecord, QDistinct> {
  QueryBuilder<MatchRecord, MatchRecord, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QDistinct> distinctByImagePath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imagePath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QDistinct> distinctByImagePaths() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imagePaths');
    });
  }

  QueryBuilder<MatchRecord, MatchRecord, QDistinct>
      distinctByNumberOfPlayers() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'numberOfPlayers');
    });
  }
}

extension MatchRecordQueryProperty
    on QueryBuilder<MatchRecord, MatchRecord, QQueryProperty> {
  QueryBuilder<MatchRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MatchRecord, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<MatchRecord, String?, QQueryOperations> imagePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imagePath');
    });
  }

  QueryBuilder<MatchRecord, List<String>, QQueryOperations>
      imagePathsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imagePaths');
    });
  }

  QueryBuilder<MatchRecord, int, QQueryOperations> numberOfPlayersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'numberOfPlayers');
    });
  }

  QueryBuilder<MatchRecord, List<PlayerScore>, QQueryOperations>
      playerScoresProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playerScores');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const PlayerScoreSchema = Schema(
  name: r'PlayerScore',
  id: 2297535275541076806,
  properties: {
    r'placement': PropertySchema(
      id: 0,
      name: r'placement',
      type: IsarType.long,
    ),
    r'playerId': PropertySchema(
      id: 1,
      name: r'playerId',
      type: IsarType.long,
    ),
    r'playerName': PropertySchema(
      id: 2,
      name: r'playerName',
      type: IsarType.string,
    ),
    r'score': PropertySchema(
      id: 3,
      name: r'score',
      type: IsarType.long,
    )
  },
  estimateSize: _playerScoreEstimateSize,
  serialize: _playerScoreSerialize,
  deserialize: _playerScoreDeserialize,
  deserializeProp: _playerScoreDeserializeProp,
);

int _playerScoreEstimateSize(
  PlayerScore object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.playerName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _playerScoreSerialize(
  PlayerScore object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.placement);
  writer.writeLong(offsets[1], object.playerId);
  writer.writeString(offsets[2], object.playerName);
  writer.writeLong(offsets[3], object.score);
}

PlayerScore _playerScoreDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PlayerScore();
  object.placement = reader.readLong(offsets[0]);
  object.playerId = reader.readLongOrNull(offsets[1]);
  object.playerName = reader.readStringOrNull(offsets[2]);
  object.score = reader.readLong(offsets[3]);
  return object;
}

P _playerScoreDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension PlayerScoreQueryFilter
    on QueryBuilder<PlayerScore, PlayerScore, QFilterCondition> {
  QueryBuilder<PlayerScore, PlayerScore, QAfterFilterCondition>
      placementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'placement',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerScore, PlayerScore, QAfterFilterCondition>
      placementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'placement',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerScore, PlayerScore, QAfterFilterCondition>
      placementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'placement',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerScore, PlayerScore, QAfterFilterCondition>
      placementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'placement',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlayerScore, PlayerScore, QAfterFilterCondition>
      playerIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'playerId',
      ));
    });
  }

  QueryBuilder<PlayerScore, PlayerScore, QAfterFilterCondition>
      playerIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'playerId',
      ));
    });
  }

  QueryBuilder<PlayerScore, PlayerScore, QAfterFilterCondition> playerIdEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playerId',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerScore, PlayerScore, QAfterFilterCondition>
      playerIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'playerId',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerScore, PlayerScore, QAfterFilterCondition>
      playerIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'playerId',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerScore, PlayerScore, QAfterFilterCondition> playerIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'playerId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlayerScore, PlayerScore, QAfterFilterCondition>
      playerNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'playerName',
      ));
    });
  }

  QueryBuilder<PlayerScore, PlayerScore, QAfterFilterCondition>
      playerNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'playerName',
      ));
    });
  }

  QueryBuilder<PlayerScore, PlayerScore, QAfterFilterCondition>
      playerNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerScore, PlayerScore, QAfterFilterCondition>
      playerNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'playerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerScore, PlayerScore, QAfterFilterCondition>
      playerNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'playerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerScore, PlayerScore, QAfterFilterCondition>
      playerNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'playerName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerScore, PlayerScore, QAfterFilterCondition>
      playerNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'playerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerScore, PlayerScore, QAfterFilterCondition>
      playerNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'playerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerScore, PlayerScore, QAfterFilterCondition>
      playerNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'playerName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerScore, PlayerScore, QAfterFilterCondition>
      playerNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'playerName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerScore, PlayerScore, QAfterFilterCondition>
      playerNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playerName',
        value: '',
      ));
    });
  }

  QueryBuilder<PlayerScore, PlayerScore, QAfterFilterCondition>
      playerNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'playerName',
        value: '',
      ));
    });
  }

  QueryBuilder<PlayerScore, PlayerScore, QAfterFilterCondition> scoreEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'score',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerScore, PlayerScore, QAfterFilterCondition>
      scoreGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'score',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerScore, PlayerScore, QAfterFilterCondition> scoreLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'score',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerScore, PlayerScore, QAfterFilterCondition> scoreBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'score',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PlayerScoreQueryObject
    on QueryBuilder<PlayerScore, PlayerScore, QFilterCondition> {}
