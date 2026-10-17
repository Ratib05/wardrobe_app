import 'dart:convert';

import 'package:drift/drift.dart';

import '../core/clothing_item.dart';
import '../core/wardrobe_values.dart';
import 'clothing_dao.dart';
import 'outfit_dao.dart';
import 'recommendation_dao.dart';

part 'app_database.g.dart';

/// Stores a set of enum values as a sorted JSON array of names.
/// Unknown names are skipped on read so old data never breaks the app.
class EnumSetConverter<T extends Enum> extends TypeConverter<Set<T>, String> {
  const EnumSetConverter(this.values);
  final List<T> values;

  @override
  Set<T> fromSql(String fromDb) {
    final byName = values.asNameMap();
    final names = (jsonDecode(fromDb) as List).cast<String>();
    return {
      for (final n in names)
        if (byName[n] != null) byName[n]!,
    };
  }

  @override
  String toSql(Set<T> value) =>
      jsonEncode(value.map((e) => e.name).toList()..sort());
}

const colourSet = EnumSetConverter<WardrobeColour>(WardrobeColour.values);
const styleSet = EnumSetConverter<StyleTag>(StyleTag.values);
const seasonSet = EnumSetConverter<Season>(Season.values);
const occasionSet = EnumSetConverter<Occasion>(Occasion.values);

@UseRowClass(ClothingItem, generateInsertable: true)
class ClothingItems extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get category => textEnum<ClothingCategory>()();
  TextColumn get subcategory => text().nullable()();
  TextColumn get primaryColour => textEnum<WardrobeColour>().nullable()();
  TextColumn get secondaryColours =>
      text().map(colourSet).withDefault(const Constant('[]'))();
  TextColumn get pattern => textEnum<ClothingPattern>().nullable()();
  TextColumn get material => text().nullable()();
  TextColumn get fit => textEnum<ClothingFit>().nullable()();
  TextColumn get styleTags =>
      text().map(styleSet).withDefault(const Constant('[]'))();
  TextColumn get formality => textEnum<Formality>().nullable()();
  TextColumn get seasons =>
      text().map(seasonSet).withDefault(const Constant('[]'))();
  TextColumn get occasions =>
      text().map(occasionSet).withDefault(const Constant('[]'))();
  TextColumn get brand => text().nullable()();
  TextColumn get size => text().nullable()();
  TextColumn get condition => textEnum<ItemCondition>().withDefault(
    Constant(ItemCondition.good.name),
  )();
  TextColumn get imagePath => text().nullable()();
  BoolColumn get isFavourite => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Outfits extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get occasion => textEnum<Occasion>().nullable()();
  TextColumn get season => textEnum<Season>().nullable()();
  IntColumn get rating =>
      // ignore: recursive_getters
      integer().nullable().check(rating.isBetweenValues(1, 5))();
  BoolColumn get isFavourite => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class OutfitItems extends Table {
  TextColumn get outfitId =>
      text().references(Outfits, #id, onDelete: KeyAction.cascade)();
  TextColumn get clothingItemId =>
      text().references(ClothingItems, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {outfitId, clothingItemId};
}

class WishlistItems extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get category => textEnum<ClothingCategory>()();
  TextColumn get subcategory => text().nullable()();
  TextColumn get preferredColours =>
      text().map(colourSet).withDefault(const Constant('[]'))();
  TextColumn get styleTags =>
      text().map(styleSet).withDefault(const Constant('[]'))();
  TextColumn get formality => textEnum<Formality>().nullable()();
  IntColumn get targetPriceCents =>
      integer().nullable()
      // ignore: recursive_getters
      .check(targetPriceCents.isBiggerOrEqualValue(0))();
  TextColumn get priority => textEnum<WishlistPriority>().withDefault(
    Constant(WishlistPriority.medium.name),
  )();
  TextColumn get reason => text().nullable()();
  TextColumn get status => textEnum<WishlistStatus>().withDefault(
    Constant(WishlistStatus.planned.name),
  )();
  TextColumn get purchasedItemId => text().nullable().references(
    ClothingItems,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class UserPreferences extends Table {
  TextColumn get preferenceType => textEnum<PreferenceType>()();
  TextColumn get preferenceValue => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {preferenceType, preferenceValue};
}

@DataClassName('FeedbackEntry')
class RecommendationFeedback extends Table {
  TextColumn get id => text()();
  TextColumn get outfitFingerprint => text()();
  IntColumn get rating => integer().nullable()();
  TextColumn get feedbackType => textEnum<FeedbackType>()();
  TextColumn get reason => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    ClothingItems,
    Outfits,
    OutfitItems,
    WishlistItems,
    UserPreferences,
    RecommendationFeedback,
  ],
  daos: [ClothingDao, OutfitDao, RecommendationDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
