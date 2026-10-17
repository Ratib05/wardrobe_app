// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ClothingItemsTable extends ClothingItems
    with TableInfo<$ClothingItemsTable, ClothingItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClothingItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ClothingCategory, String>
  category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<ClothingCategory>($ClothingItemsTable.$convertercategory);
  static const VerificationMeta _subcategoryMeta = const VerificationMeta(
    'subcategory',
  );
  @override
  late final GeneratedColumn<String> subcategory = GeneratedColumn<String>(
    'subcategory',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<WardrobeColour?, String>
  primaryColour =
      GeneratedColumn<String>(
        'primary_colour',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<WardrobeColour?>(
        $ClothingItemsTable.$converterprimaryColourn,
      );
  @override
  late final GeneratedColumnWithTypeConverter<Set<WardrobeColour>, String>
  secondaryColours =
      GeneratedColumn<String>(
        'secondary_colours',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<Set<WardrobeColour>>(
        $ClothingItemsTable.$convertersecondaryColours,
      );
  @override
  late final GeneratedColumnWithTypeConverter<ClothingPattern?, String>
  pattern = GeneratedColumn<String>(
    'pattern',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<ClothingPattern?>($ClothingItemsTable.$converterpatternn);
  static const VerificationMeta _materialMeta = const VerificationMeta(
    'material',
  );
  @override
  late final GeneratedColumn<String> material = GeneratedColumn<String>(
    'material',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ClothingFit?, String> fit =
      GeneratedColumn<String>(
        'fit',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<ClothingFit?>($ClothingItemsTable.$converterfitn);
  @override
  late final GeneratedColumnWithTypeConverter<Set<StyleTag>, String> styleTags =
      GeneratedColumn<String>(
        'style_tags',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<Set<StyleTag>>($ClothingItemsTable.$converterstyleTags);
  @override
  late final GeneratedColumnWithTypeConverter<Formality?, String> formality =
      GeneratedColumn<String>(
        'formality',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Formality?>($ClothingItemsTable.$converterformalityn);
  @override
  late final GeneratedColumnWithTypeConverter<Set<Season>, String> seasons =
      GeneratedColumn<String>(
        'seasons',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<Set<Season>>($ClothingItemsTable.$converterseasons);
  @override
  late final GeneratedColumnWithTypeConverter<Set<Occasion>, String> occasions =
      GeneratedColumn<String>(
        'occasions',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<Set<Occasion>>($ClothingItemsTable.$converteroccasions);
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<String> size = GeneratedColumn<String>(
    'size',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ItemCondition, String> condition =
      GeneratedColumn<String>(
        'condition',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(ItemCondition.good.name),
      ).withConverter<ItemCondition>($ClothingItemsTable.$convertercondition);
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFavouriteMeta = const VerificationMeta(
    'isFavourite',
  );
  @override
  late final GeneratedColumn<bool> isFavourite = GeneratedColumn<bool>(
    'is_favourite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favourite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    category,
    subcategory,
    primaryColour,
    secondaryColours,
    pattern,
    material,
    fit,
    styleTags,
    formality,
    seasons,
    occasions,
    brand,
    size,
    condition,
    imagePath,
    isFavourite,
    isArchived,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clothing_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClothingItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('subcategory')) {
      context.handle(
        _subcategoryMeta,
        subcategory.isAcceptableOrUnknown(
          data['subcategory']!,
          _subcategoryMeta,
        ),
      );
    }
    if (data.containsKey('material')) {
      context.handle(
        _materialMeta,
        material.isAcceptableOrUnknown(data['material']!, _materialMeta),
      );
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('size')) {
      context.handle(
        _sizeMeta,
        size.isAcceptableOrUnknown(data['size']!, _sizeMeta),
      );
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    if (data.containsKey('is_favourite')) {
      context.handle(
        _isFavouriteMeta,
        isFavourite.isAcceptableOrUnknown(
          data['is_favourite']!,
          _isFavouriteMeta,
        ),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClothingItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClothingItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: $ClothingItemsTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}category'],
        )!,
      ),
      subcategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subcategory'],
      ),
      primaryColour: $ClothingItemsTable.$converterprimaryColourn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}primary_colour'],
        ),
      ),
      secondaryColours: $ClothingItemsTable.$convertersecondaryColours.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}secondary_colours'],
        )!,
      ),
      pattern: $ClothingItemsTable.$converterpatternn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}pattern'],
        ),
      ),
      material: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}material'],
      ),
      fit: $ClothingItemsTable.$converterfitn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}fit'],
        ),
      ),
      styleTags: $ClothingItemsTable.$converterstyleTags.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}style_tags'],
        )!,
      ),
      formality: $ClothingItemsTable.$converterformalityn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}formality'],
        ),
      ),
      seasons: $ClothingItemsTable.$converterseasons.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}seasons'],
        )!,
      ),
      occasions: $ClothingItemsTable.$converteroccasions.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}occasions'],
        )!,
      ),
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      size: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}size'],
      ),
      condition: $ClothingItemsTable.$convertercondition.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}condition'],
        )!,
      ),
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
      isFavourite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favourite'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ClothingItemsTable createAlias(String alias) {
    return $ClothingItemsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ClothingCategory, String, String>
  $convertercategory = const EnumNameConverter<ClothingCategory>(
    ClothingCategory.values,
  );
  static JsonTypeConverter2<WardrobeColour, String, String>
  $converterprimaryColour = const EnumNameConverter<WardrobeColour>(
    WardrobeColour.values,
  );
  static JsonTypeConverter2<WardrobeColour?, String?, String?>
  $converterprimaryColourn = JsonTypeConverter2.asNullable(
    $converterprimaryColour,
  );
  static TypeConverter<Set<WardrobeColour>, String> $convertersecondaryColours =
      colourSet;
  static JsonTypeConverter2<ClothingPattern, String, String> $converterpattern =
      const EnumNameConverter<ClothingPattern>(ClothingPattern.values);
  static JsonTypeConverter2<ClothingPattern?, String?, String?>
  $converterpatternn = JsonTypeConverter2.asNullable($converterpattern);
  static JsonTypeConverter2<ClothingFit, String, String> $converterfit =
      const EnumNameConverter<ClothingFit>(ClothingFit.values);
  static JsonTypeConverter2<ClothingFit?, String?, String?> $converterfitn =
      JsonTypeConverter2.asNullable($converterfit);
  static TypeConverter<Set<StyleTag>, String> $converterstyleTags = styleSet;
  static JsonTypeConverter2<Formality, String, String> $converterformality =
      const EnumNameConverter<Formality>(Formality.values);
  static JsonTypeConverter2<Formality?, String?, String?> $converterformalityn =
      JsonTypeConverter2.asNullable($converterformality);
  static TypeConverter<Set<Season>, String> $converterseasons = seasonSet;
  static TypeConverter<Set<Occasion>, String> $converteroccasions = occasionSet;
  static JsonTypeConverter2<ItemCondition, String, String> $convertercondition =
      const EnumNameConverter<ItemCondition>(ItemCondition.values);
}

class ClothingItemsCompanion extends UpdateCompanion<ClothingItem> {
  final Value<String> id;
  final Value<String> name;
  final Value<ClothingCategory> category;
  final Value<String?> subcategory;
  final Value<WardrobeColour?> primaryColour;
  final Value<Set<WardrobeColour>> secondaryColours;
  final Value<ClothingPattern?> pattern;
  final Value<String?> material;
  final Value<ClothingFit?> fit;
  final Value<Set<StyleTag>> styleTags;
  final Value<Formality?> formality;
  final Value<Set<Season>> seasons;
  final Value<Set<Occasion>> occasions;
  final Value<String?> brand;
  final Value<String?> size;
  final Value<ItemCondition> condition;
  final Value<String?> imagePath;
  final Value<bool> isFavourite;
  final Value<bool> isArchived;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ClothingItemsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.subcategory = const Value.absent(),
    this.primaryColour = const Value.absent(),
    this.secondaryColours = const Value.absent(),
    this.pattern = const Value.absent(),
    this.material = const Value.absent(),
    this.fit = const Value.absent(),
    this.styleTags = const Value.absent(),
    this.formality = const Value.absent(),
    this.seasons = const Value.absent(),
    this.occasions = const Value.absent(),
    this.brand = const Value.absent(),
    this.size = const Value.absent(),
    this.condition = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.isFavourite = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClothingItemsCompanion.insert({
    required String id,
    required String name,
    required ClothingCategory category,
    this.subcategory = const Value.absent(),
    this.primaryColour = const Value.absent(),
    this.secondaryColours = const Value.absent(),
    this.pattern = const Value.absent(),
    this.material = const Value.absent(),
    this.fit = const Value.absent(),
    this.styleTags = const Value.absent(),
    this.formality = const Value.absent(),
    this.seasons = const Value.absent(),
    this.occasions = const Value.absent(),
    this.brand = const Value.absent(),
    this.size = const Value.absent(),
    this.condition = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.isFavourite = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       category = Value(category),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ClothingItem> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? subcategory,
    Expression<String>? primaryColour,
    Expression<String>? secondaryColours,
    Expression<String>? pattern,
    Expression<String>? material,
    Expression<String>? fit,
    Expression<String>? styleTags,
    Expression<String>? formality,
    Expression<String>? seasons,
    Expression<String>? occasions,
    Expression<String>? brand,
    Expression<String>? size,
    Expression<String>? condition,
    Expression<String>? imagePath,
    Expression<bool>? isFavourite,
    Expression<bool>? isArchived,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (subcategory != null) 'subcategory': subcategory,
      if (primaryColour != null) 'primary_colour': primaryColour,
      if (secondaryColours != null) 'secondary_colours': secondaryColours,
      if (pattern != null) 'pattern': pattern,
      if (material != null) 'material': material,
      if (fit != null) 'fit': fit,
      if (styleTags != null) 'style_tags': styleTags,
      if (formality != null) 'formality': formality,
      if (seasons != null) 'seasons': seasons,
      if (occasions != null) 'occasions': occasions,
      if (brand != null) 'brand': brand,
      if (size != null) 'size': size,
      if (condition != null) 'condition': condition,
      if (imagePath != null) 'image_path': imagePath,
      if (isFavourite != null) 'is_favourite': isFavourite,
      if (isArchived != null) 'is_archived': isArchived,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClothingItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<ClothingCategory>? category,
    Value<String?>? subcategory,
    Value<WardrobeColour?>? primaryColour,
    Value<Set<WardrobeColour>>? secondaryColours,
    Value<ClothingPattern?>? pattern,
    Value<String?>? material,
    Value<ClothingFit?>? fit,
    Value<Set<StyleTag>>? styleTags,
    Value<Formality?>? formality,
    Value<Set<Season>>? seasons,
    Value<Set<Occasion>>? occasions,
    Value<String?>? brand,
    Value<String?>? size,
    Value<ItemCondition>? condition,
    Value<String?>? imagePath,
    Value<bool>? isFavourite,
    Value<bool>? isArchived,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ClothingItemsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      primaryColour: primaryColour ?? this.primaryColour,
      secondaryColours: secondaryColours ?? this.secondaryColours,
      pattern: pattern ?? this.pattern,
      material: material ?? this.material,
      fit: fit ?? this.fit,
      styleTags: styleTags ?? this.styleTags,
      formality: formality ?? this.formality,
      seasons: seasons ?? this.seasons,
      occasions: occasions ?? this.occasions,
      brand: brand ?? this.brand,
      size: size ?? this.size,
      condition: condition ?? this.condition,
      imagePath: imagePath ?? this.imagePath,
      isFavourite: isFavourite ?? this.isFavourite,
      isArchived: isArchived ?? this.isArchived,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(
        $ClothingItemsTable.$convertercategory.toSql(category.value),
      );
    }
    if (subcategory.present) {
      map['subcategory'] = Variable<String>(subcategory.value);
    }
    if (primaryColour.present) {
      map['primary_colour'] = Variable<String>(
        $ClothingItemsTable.$converterprimaryColourn.toSql(primaryColour.value),
      );
    }
    if (secondaryColours.present) {
      map['secondary_colours'] = Variable<String>(
        $ClothingItemsTable.$convertersecondaryColours.toSql(
          secondaryColours.value,
        ),
      );
    }
    if (pattern.present) {
      map['pattern'] = Variable<String>(
        $ClothingItemsTable.$converterpatternn.toSql(pattern.value),
      );
    }
    if (material.present) {
      map['material'] = Variable<String>(material.value);
    }
    if (fit.present) {
      map['fit'] = Variable<String>(
        $ClothingItemsTable.$converterfitn.toSql(fit.value),
      );
    }
    if (styleTags.present) {
      map['style_tags'] = Variable<String>(
        $ClothingItemsTable.$converterstyleTags.toSql(styleTags.value),
      );
    }
    if (formality.present) {
      map['formality'] = Variable<String>(
        $ClothingItemsTable.$converterformalityn.toSql(formality.value),
      );
    }
    if (seasons.present) {
      map['seasons'] = Variable<String>(
        $ClothingItemsTable.$converterseasons.toSql(seasons.value),
      );
    }
    if (occasions.present) {
      map['occasions'] = Variable<String>(
        $ClothingItemsTable.$converteroccasions.toSql(occasions.value),
      );
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (size.present) {
      map['size'] = Variable<String>(size.value);
    }
    if (condition.present) {
      map['condition'] = Variable<String>(
        $ClothingItemsTable.$convertercondition.toSql(condition.value),
      );
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (isFavourite.present) {
      map['is_favourite'] = Variable<bool>(isFavourite.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClothingItemsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('subcategory: $subcategory, ')
          ..write('primaryColour: $primaryColour, ')
          ..write('secondaryColours: $secondaryColours, ')
          ..write('pattern: $pattern, ')
          ..write('material: $material, ')
          ..write('fit: $fit, ')
          ..write('styleTags: $styleTags, ')
          ..write('formality: $formality, ')
          ..write('seasons: $seasons, ')
          ..write('occasions: $occasions, ')
          ..write('brand: $brand, ')
          ..write('size: $size, ')
          ..write('condition: $condition, ')
          ..write('imagePath: $imagePath, ')
          ..write('isFavourite: $isFavourite, ')
          ..write('isArchived: $isArchived, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class _$ClothingItemInsertable implements Insertable<ClothingItem> {
  ClothingItem _object;
  _$ClothingItemInsertable(this._object);
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return ClothingItemsCompanion(
      id: Value(_object.id),
      name: Value(_object.name),
      category: Value(_object.category),
      subcategory: Value(_object.subcategory),
      primaryColour: Value(_object.primaryColour),
      secondaryColours: Value(_object.secondaryColours),
      pattern: Value(_object.pattern),
      material: Value(_object.material),
      fit: Value(_object.fit),
      styleTags: Value(_object.styleTags),
      formality: Value(_object.formality),
      seasons: Value(_object.seasons),
      occasions: Value(_object.occasions),
      brand: Value(_object.brand),
      size: Value(_object.size),
      condition: Value(_object.condition),
      imagePath: Value(_object.imagePath),
      isFavourite: Value(_object.isFavourite),
      isArchived: Value(_object.isArchived),
      notes: Value(_object.notes),
      createdAt: Value(_object.createdAt),
      updatedAt: Value(_object.updatedAt),
    ).toColumns(false);
  }
}

extension ClothingItemToInsertable on ClothingItem {
  _$ClothingItemInsertable toInsertable() {
    return _$ClothingItemInsertable(this);
  }
}

class $OutfitsTable extends Outfits with TableInfo<$OutfitsTable, Outfit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutfitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Occasion?, String> occasion =
      GeneratedColumn<String>(
        'occasion',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Occasion?>($OutfitsTable.$converteroccasionn);
  @override
  late final GeneratedColumnWithTypeConverter<Season?, String> season =
      GeneratedColumn<String>(
        'season',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Season?>($OutfitsTable.$converterseasonn);
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    true,
    check: () => ComparableExpr(rating).isBetweenValues(1, 5),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFavouriteMeta = const VerificationMeta(
    'isFavourite',
  );
  @override
  late final GeneratedColumn<bool> isFavourite = GeneratedColumn<bool>(
    'is_favourite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favourite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    occasion,
    season,
    rating,
    isFavourite,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outfits';
  @override
  VerificationContext validateIntegrity(
    Insertable<Outfit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('is_favourite')) {
      context.handle(
        _isFavouriteMeta,
        isFavourite.isAcceptableOrUnknown(
          data['is_favourite']!,
          _isFavouriteMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Outfit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Outfit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      occasion: $OutfitsTable.$converteroccasionn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}occasion'],
        ),
      ),
      season: $OutfitsTable.$converterseasonn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}season'],
        ),
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      ),
      isFavourite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favourite'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $OutfitsTable createAlias(String alias) {
    return $OutfitsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Occasion, String, String> $converteroccasion =
      const EnumNameConverter<Occasion>(Occasion.values);
  static JsonTypeConverter2<Occasion?, String?, String?> $converteroccasionn =
      JsonTypeConverter2.asNullable($converteroccasion);
  static JsonTypeConverter2<Season, String, String> $converterseason =
      const EnumNameConverter<Season>(Season.values);
  static JsonTypeConverter2<Season?, String?, String?> $converterseasonn =
      JsonTypeConverter2.asNullable($converterseason);
}

class Outfit extends DataClass implements Insertable<Outfit> {
  final String id;
  final String name;
  final Occasion? occasion;
  final Season? season;
  final int? rating;
  final bool isFavourite;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Outfit({
    required this.id,
    required this.name,
    this.occasion,
    this.season,
    this.rating,
    required this.isFavourite,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || occasion != null) {
      map['occasion'] = Variable<String>(
        $OutfitsTable.$converteroccasionn.toSql(occasion),
      );
    }
    if (!nullToAbsent || season != null) {
      map['season'] = Variable<String>(
        $OutfitsTable.$converterseasonn.toSql(season),
      );
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<int>(rating);
    }
    map['is_favourite'] = Variable<bool>(isFavourite);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  OutfitsCompanion toCompanion(bool nullToAbsent) {
    return OutfitsCompanion(
      id: Value(id),
      name: Value(name),
      occasion: occasion == null && nullToAbsent
          ? const Value.absent()
          : Value(occasion),
      season: season == null && nullToAbsent
          ? const Value.absent()
          : Value(season),
      rating: rating == null && nullToAbsent
          ? const Value.absent()
          : Value(rating),
      isFavourite: Value(isFavourite),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Outfit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Outfit(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      occasion: $OutfitsTable.$converteroccasionn.fromJson(
        serializer.fromJson<String?>(json['occasion']),
      ),
      season: $OutfitsTable.$converterseasonn.fromJson(
        serializer.fromJson<String?>(json['season']),
      ),
      rating: serializer.fromJson<int?>(json['rating']),
      isFavourite: serializer.fromJson<bool>(json['isFavourite']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'occasion': serializer.toJson<String?>(
        $OutfitsTable.$converteroccasionn.toJson(occasion),
      ),
      'season': serializer.toJson<String?>(
        $OutfitsTable.$converterseasonn.toJson(season),
      ),
      'rating': serializer.toJson<int?>(rating),
      'isFavourite': serializer.toJson<bool>(isFavourite),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Outfit copyWith({
    String? id,
    String? name,
    Value<Occasion?> occasion = const Value.absent(),
    Value<Season?> season = const Value.absent(),
    Value<int?> rating = const Value.absent(),
    bool? isFavourite,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Outfit(
    id: id ?? this.id,
    name: name ?? this.name,
    occasion: occasion.present ? occasion.value : this.occasion,
    season: season.present ? season.value : this.season,
    rating: rating.present ? rating.value : this.rating,
    isFavourite: isFavourite ?? this.isFavourite,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Outfit copyWithCompanion(OutfitsCompanion data) {
    return Outfit(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      occasion: data.occasion.present ? data.occasion.value : this.occasion,
      season: data.season.present ? data.season.value : this.season,
      rating: data.rating.present ? data.rating.value : this.rating,
      isFavourite: data.isFavourite.present
          ? data.isFavourite.value
          : this.isFavourite,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Outfit(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('occasion: $occasion, ')
          ..write('season: $season, ')
          ..write('rating: $rating, ')
          ..write('isFavourite: $isFavourite, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    occasion,
    season,
    rating,
    isFavourite,
    notes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Outfit &&
          other.id == this.id &&
          other.name == this.name &&
          other.occasion == this.occasion &&
          other.season == this.season &&
          other.rating == this.rating &&
          other.isFavourite == this.isFavourite &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class OutfitsCompanion extends UpdateCompanion<Outfit> {
  final Value<String> id;
  final Value<String> name;
  final Value<Occasion?> occasion;
  final Value<Season?> season;
  final Value<int?> rating;
  final Value<bool> isFavourite;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const OutfitsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.occasion = const Value.absent(),
    this.season = const Value.absent(),
    this.rating = const Value.absent(),
    this.isFavourite = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutfitsCompanion.insert({
    required String id,
    required String name,
    this.occasion = const Value.absent(),
    this.season = const Value.absent(),
    this.rating = const Value.absent(),
    this.isFavourite = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Outfit> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? occasion,
    Expression<String>? season,
    Expression<int>? rating,
    Expression<bool>? isFavourite,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (occasion != null) 'occasion': occasion,
      if (season != null) 'season': season,
      if (rating != null) 'rating': rating,
      if (isFavourite != null) 'is_favourite': isFavourite,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutfitsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<Occasion?>? occasion,
    Value<Season?>? season,
    Value<int?>? rating,
    Value<bool>? isFavourite,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return OutfitsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      occasion: occasion ?? this.occasion,
      season: season ?? this.season,
      rating: rating ?? this.rating,
      isFavourite: isFavourite ?? this.isFavourite,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (occasion.present) {
      map['occasion'] = Variable<String>(
        $OutfitsTable.$converteroccasionn.toSql(occasion.value),
      );
    }
    if (season.present) {
      map['season'] = Variable<String>(
        $OutfitsTable.$converterseasonn.toSql(season.value),
      );
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (isFavourite.present) {
      map['is_favourite'] = Variable<bool>(isFavourite.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutfitsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('occasion: $occasion, ')
          ..write('season: $season, ')
          ..write('rating: $rating, ')
          ..write('isFavourite: $isFavourite, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutfitItemsTable extends OutfitItems
    with TableInfo<$OutfitItemsTable, OutfitItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutfitItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _outfitIdMeta = const VerificationMeta(
    'outfitId',
  );
  @override
  late final GeneratedColumn<String> outfitId = GeneratedColumn<String>(
    'outfit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES outfits (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _clothingItemIdMeta = const VerificationMeta(
    'clothingItemId',
  );
  @override
  late final GeneratedColumn<String> clothingItemId = GeneratedColumn<String>(
    'clothing_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clothing_items (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [outfitId, clothingItemId, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outfit_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutfitItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('outfit_id')) {
      context.handle(
        _outfitIdMeta,
        outfitId.isAcceptableOrUnknown(data['outfit_id']!, _outfitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_outfitIdMeta);
    }
    if (data.containsKey('clothing_item_id')) {
      context.handle(
        _clothingItemIdMeta,
        clothingItemId.isAcceptableOrUnknown(
          data['clothing_item_id']!,
          _clothingItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clothingItemIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {outfitId, clothingItemId};
  @override
  OutfitItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutfitItem(
      outfitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outfit_id'],
      )!,
      clothingItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clothing_item_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $OutfitItemsTable createAlias(String alias) {
    return $OutfitItemsTable(attachedDatabase, alias);
  }
}

class OutfitItem extends DataClass implements Insertable<OutfitItem> {
  final String outfitId;
  final String clothingItemId;
  final int position;
  const OutfitItem({
    required this.outfitId,
    required this.clothingItemId,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['outfit_id'] = Variable<String>(outfitId);
    map['clothing_item_id'] = Variable<String>(clothingItemId);
    map['position'] = Variable<int>(position);
    return map;
  }

  OutfitItemsCompanion toCompanion(bool nullToAbsent) {
    return OutfitItemsCompanion(
      outfitId: Value(outfitId),
      clothingItemId: Value(clothingItemId),
      position: Value(position),
    );
  }

  factory OutfitItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutfitItem(
      outfitId: serializer.fromJson<String>(json['outfitId']),
      clothingItemId: serializer.fromJson<String>(json['clothingItemId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'outfitId': serializer.toJson<String>(outfitId),
      'clothingItemId': serializer.toJson<String>(clothingItemId),
      'position': serializer.toJson<int>(position),
    };
  }

  OutfitItem copyWith({
    String? outfitId,
    String? clothingItemId,
    int? position,
  }) => OutfitItem(
    outfitId: outfitId ?? this.outfitId,
    clothingItemId: clothingItemId ?? this.clothingItemId,
    position: position ?? this.position,
  );
  OutfitItem copyWithCompanion(OutfitItemsCompanion data) {
    return OutfitItem(
      outfitId: data.outfitId.present ? data.outfitId.value : this.outfitId,
      clothingItemId: data.clothingItemId.present
          ? data.clothingItemId.value
          : this.clothingItemId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutfitItem(')
          ..write('outfitId: $outfitId, ')
          ..write('clothingItemId: $clothingItemId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(outfitId, clothingItemId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutfitItem &&
          other.outfitId == this.outfitId &&
          other.clothingItemId == this.clothingItemId &&
          other.position == this.position);
}

class OutfitItemsCompanion extends UpdateCompanion<OutfitItem> {
  final Value<String> outfitId;
  final Value<String> clothingItemId;
  final Value<int> position;
  final Value<int> rowid;
  const OutfitItemsCompanion({
    this.outfitId = const Value.absent(),
    this.clothingItemId = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutfitItemsCompanion.insert({
    required String outfitId,
    required String clothingItemId,
    required int position,
    this.rowid = const Value.absent(),
  }) : outfitId = Value(outfitId),
       clothingItemId = Value(clothingItemId),
       position = Value(position);
  static Insertable<OutfitItem> custom({
    Expression<String>? outfitId,
    Expression<String>? clothingItemId,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (outfitId != null) 'outfit_id': outfitId,
      if (clothingItemId != null) 'clothing_item_id': clothingItemId,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutfitItemsCompanion copyWith({
    Value<String>? outfitId,
    Value<String>? clothingItemId,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return OutfitItemsCompanion(
      outfitId: outfitId ?? this.outfitId,
      clothingItemId: clothingItemId ?? this.clothingItemId,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (outfitId.present) {
      map['outfit_id'] = Variable<String>(outfitId.value);
    }
    if (clothingItemId.present) {
      map['clothing_item_id'] = Variable<String>(clothingItemId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutfitItemsCompanion(')
          ..write('outfitId: $outfitId, ')
          ..write('clothingItemId: $clothingItemId, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WishlistItemsTable extends WishlistItems
    with TableInfo<$WishlistItemsTable, WishlistItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WishlistItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ClothingCategory, String>
  category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<ClothingCategory>($WishlistItemsTable.$convertercategory);
  static const VerificationMeta _subcategoryMeta = const VerificationMeta(
    'subcategory',
  );
  @override
  late final GeneratedColumn<String> subcategory = GeneratedColumn<String>(
    'subcategory',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Set<WardrobeColour>, String>
  preferredColours =
      GeneratedColumn<String>(
        'preferred_colours',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<Set<WardrobeColour>>(
        $WishlistItemsTable.$converterpreferredColours,
      );
  @override
  late final GeneratedColumnWithTypeConverter<Set<StyleTag>, String> styleTags =
      GeneratedColumn<String>(
        'style_tags',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<Set<StyleTag>>($WishlistItemsTable.$converterstyleTags);
  @override
  late final GeneratedColumnWithTypeConverter<Formality?, String> formality =
      GeneratedColumn<String>(
        'formality',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Formality?>($WishlistItemsTable.$converterformalityn);
  static const VerificationMeta _targetPriceCentsMeta = const VerificationMeta(
    'targetPriceCents',
  );
  @override
  late final GeneratedColumn<int> targetPriceCents = GeneratedColumn<int>(
    'target_price_cents',
    aliasedName,
    true,
    check: () => ComparableExpr(targetPriceCents).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<WishlistPriority, String>
  priority = GeneratedColumn<String>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(WishlistPriority.medium.name),
  ).withConverter<WishlistPriority>($WishlistItemsTable.$converterpriority);
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<WishlistStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(WishlistStatus.planned.name),
      ).withConverter<WishlistStatus>($WishlistItemsTable.$converterstatus);
  static const VerificationMeta _purchasedItemIdMeta = const VerificationMeta(
    'purchasedItemId',
  );
  @override
  late final GeneratedColumn<String> purchasedItemId = GeneratedColumn<String>(
    'purchased_item_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clothing_items (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    category,
    subcategory,
    preferredColours,
    styleTags,
    formality,
    targetPriceCents,
    priority,
    reason,
    status,
    purchasedItemId,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wishlist_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<WishlistItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('subcategory')) {
      context.handle(
        _subcategoryMeta,
        subcategory.isAcceptableOrUnknown(
          data['subcategory']!,
          _subcategoryMeta,
        ),
      );
    }
    if (data.containsKey('target_price_cents')) {
      context.handle(
        _targetPriceCentsMeta,
        targetPriceCents.isAcceptableOrUnknown(
          data['target_price_cents']!,
          _targetPriceCentsMeta,
        ),
      );
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('purchased_item_id')) {
      context.handle(
        _purchasedItemIdMeta,
        purchasedItemId.isAcceptableOrUnknown(
          data['purchased_item_id']!,
          _purchasedItemIdMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WishlistItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WishlistItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: $WishlistItemsTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}category'],
        )!,
      ),
      subcategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subcategory'],
      ),
      preferredColours: $WishlistItemsTable.$converterpreferredColours.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}preferred_colours'],
        )!,
      ),
      styleTags: $WishlistItemsTable.$converterstyleTags.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}style_tags'],
        )!,
      ),
      formality: $WishlistItemsTable.$converterformalityn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}formality'],
        ),
      ),
      targetPriceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_price_cents'],
      ),
      priority: $WishlistItemsTable.$converterpriority.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}priority'],
        )!,
      ),
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      status: $WishlistItemsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      purchasedItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purchased_item_id'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WishlistItemsTable createAlias(String alias) {
    return $WishlistItemsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ClothingCategory, String, String>
  $convertercategory = const EnumNameConverter<ClothingCategory>(
    ClothingCategory.values,
  );
  static TypeConverter<Set<WardrobeColour>, String> $converterpreferredColours =
      colourSet;
  static TypeConverter<Set<StyleTag>, String> $converterstyleTags = styleSet;
  static JsonTypeConverter2<Formality, String, String> $converterformality =
      const EnumNameConverter<Formality>(Formality.values);
  static JsonTypeConverter2<Formality?, String?, String?> $converterformalityn =
      JsonTypeConverter2.asNullable($converterformality);
  static JsonTypeConverter2<WishlistPriority, String, String>
  $converterpriority = const EnumNameConverter<WishlistPriority>(
    WishlistPriority.values,
  );
  static JsonTypeConverter2<WishlistStatus, String, String> $converterstatus =
      const EnumNameConverter<WishlistStatus>(WishlistStatus.values);
}

class WishlistItem extends DataClass implements Insertable<WishlistItem> {
  final String id;
  final String name;
  final ClothingCategory category;
  final String? subcategory;
  final Set<WardrobeColour> preferredColours;
  final Set<StyleTag> styleTags;
  final Formality? formality;
  final int? targetPriceCents;
  final WishlistPriority priority;
  final String? reason;
  final WishlistStatus status;
  final String? purchasedItemId;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const WishlistItem({
    required this.id,
    required this.name,
    required this.category,
    this.subcategory,
    required this.preferredColours,
    required this.styleTags,
    this.formality,
    this.targetPriceCents,
    required this.priority,
    this.reason,
    required this.status,
    this.purchasedItemId,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    {
      map['category'] = Variable<String>(
        $WishlistItemsTable.$convertercategory.toSql(category),
      );
    }
    if (!nullToAbsent || subcategory != null) {
      map['subcategory'] = Variable<String>(subcategory);
    }
    {
      map['preferred_colours'] = Variable<String>(
        $WishlistItemsTable.$converterpreferredColours.toSql(preferredColours),
      );
    }
    {
      map['style_tags'] = Variable<String>(
        $WishlistItemsTable.$converterstyleTags.toSql(styleTags),
      );
    }
    if (!nullToAbsent || formality != null) {
      map['formality'] = Variable<String>(
        $WishlistItemsTable.$converterformalityn.toSql(formality),
      );
    }
    if (!nullToAbsent || targetPriceCents != null) {
      map['target_price_cents'] = Variable<int>(targetPriceCents);
    }
    {
      map['priority'] = Variable<String>(
        $WishlistItemsTable.$converterpriority.toSql(priority),
      );
    }
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    {
      map['status'] = Variable<String>(
        $WishlistItemsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || purchasedItemId != null) {
      map['purchased_item_id'] = Variable<String>(purchasedItemId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WishlistItemsCompanion toCompanion(bool nullToAbsent) {
    return WishlistItemsCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      subcategory: subcategory == null && nullToAbsent
          ? const Value.absent()
          : Value(subcategory),
      preferredColours: Value(preferredColours),
      styleTags: Value(styleTags),
      formality: formality == null && nullToAbsent
          ? const Value.absent()
          : Value(formality),
      targetPriceCents: targetPriceCents == null && nullToAbsent
          ? const Value.absent()
          : Value(targetPriceCents),
      priority: Value(priority),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      status: Value(status),
      purchasedItemId: purchasedItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(purchasedItemId),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory WishlistItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WishlistItem(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: $WishlistItemsTable.$convertercategory.fromJson(
        serializer.fromJson<String>(json['category']),
      ),
      subcategory: serializer.fromJson<String?>(json['subcategory']),
      preferredColours: serializer.fromJson<Set<WardrobeColour>>(
        json['preferredColours'],
      ),
      styleTags: serializer.fromJson<Set<StyleTag>>(json['styleTags']),
      formality: $WishlistItemsTable.$converterformalityn.fromJson(
        serializer.fromJson<String?>(json['formality']),
      ),
      targetPriceCents: serializer.fromJson<int?>(json['targetPriceCents']),
      priority: $WishlistItemsTable.$converterpriority.fromJson(
        serializer.fromJson<String>(json['priority']),
      ),
      reason: serializer.fromJson<String?>(json['reason']),
      status: $WishlistItemsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      purchasedItemId: serializer.fromJson<String?>(json['purchasedItemId']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(
        $WishlistItemsTable.$convertercategory.toJson(category),
      ),
      'subcategory': serializer.toJson<String?>(subcategory),
      'preferredColours': serializer.toJson<Set<WardrobeColour>>(
        preferredColours,
      ),
      'styleTags': serializer.toJson<Set<StyleTag>>(styleTags),
      'formality': serializer.toJson<String?>(
        $WishlistItemsTable.$converterformalityn.toJson(formality),
      ),
      'targetPriceCents': serializer.toJson<int?>(targetPriceCents),
      'priority': serializer.toJson<String>(
        $WishlistItemsTable.$converterpriority.toJson(priority),
      ),
      'reason': serializer.toJson<String?>(reason),
      'status': serializer.toJson<String>(
        $WishlistItemsTable.$converterstatus.toJson(status),
      ),
      'purchasedItemId': serializer.toJson<String?>(purchasedItemId),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WishlistItem copyWith({
    String? id,
    String? name,
    ClothingCategory? category,
    Value<String?> subcategory = const Value.absent(),
    Set<WardrobeColour>? preferredColours,
    Set<StyleTag>? styleTags,
    Value<Formality?> formality = const Value.absent(),
    Value<int?> targetPriceCents = const Value.absent(),
    WishlistPriority? priority,
    Value<String?> reason = const Value.absent(),
    WishlistStatus? status,
    Value<String?> purchasedItemId = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => WishlistItem(
    id: id ?? this.id,
    name: name ?? this.name,
    category: category ?? this.category,
    subcategory: subcategory.present ? subcategory.value : this.subcategory,
    preferredColours: preferredColours ?? this.preferredColours,
    styleTags: styleTags ?? this.styleTags,
    formality: formality.present ? formality.value : this.formality,
    targetPriceCents: targetPriceCents.present
        ? targetPriceCents.value
        : this.targetPriceCents,
    priority: priority ?? this.priority,
    reason: reason.present ? reason.value : this.reason,
    status: status ?? this.status,
    purchasedItemId: purchasedItemId.present
        ? purchasedItemId.value
        : this.purchasedItemId,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WishlistItem copyWithCompanion(WishlistItemsCompanion data) {
    return WishlistItem(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      subcategory: data.subcategory.present
          ? data.subcategory.value
          : this.subcategory,
      preferredColours: data.preferredColours.present
          ? data.preferredColours.value
          : this.preferredColours,
      styleTags: data.styleTags.present ? data.styleTags.value : this.styleTags,
      formality: data.formality.present ? data.formality.value : this.formality,
      targetPriceCents: data.targetPriceCents.present
          ? data.targetPriceCents.value
          : this.targetPriceCents,
      priority: data.priority.present ? data.priority.value : this.priority,
      reason: data.reason.present ? data.reason.value : this.reason,
      status: data.status.present ? data.status.value : this.status,
      purchasedItemId: data.purchasedItemId.present
          ? data.purchasedItemId.value
          : this.purchasedItemId,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WishlistItem(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('subcategory: $subcategory, ')
          ..write('preferredColours: $preferredColours, ')
          ..write('styleTags: $styleTags, ')
          ..write('formality: $formality, ')
          ..write('targetPriceCents: $targetPriceCents, ')
          ..write('priority: $priority, ')
          ..write('reason: $reason, ')
          ..write('status: $status, ')
          ..write('purchasedItemId: $purchasedItemId, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    category,
    subcategory,
    preferredColours,
    styleTags,
    formality,
    targetPriceCents,
    priority,
    reason,
    status,
    purchasedItemId,
    notes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WishlistItem &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.subcategory == this.subcategory &&
          other.preferredColours == this.preferredColours &&
          other.styleTags == this.styleTags &&
          other.formality == this.formality &&
          other.targetPriceCents == this.targetPriceCents &&
          other.priority == this.priority &&
          other.reason == this.reason &&
          other.status == this.status &&
          other.purchasedItemId == this.purchasedItemId &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WishlistItemsCompanion extends UpdateCompanion<WishlistItem> {
  final Value<String> id;
  final Value<String> name;
  final Value<ClothingCategory> category;
  final Value<String?> subcategory;
  final Value<Set<WardrobeColour>> preferredColours;
  final Value<Set<StyleTag>> styleTags;
  final Value<Formality?> formality;
  final Value<int?> targetPriceCents;
  final Value<WishlistPriority> priority;
  final Value<String?> reason;
  final Value<WishlistStatus> status;
  final Value<String?> purchasedItemId;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WishlistItemsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.subcategory = const Value.absent(),
    this.preferredColours = const Value.absent(),
    this.styleTags = const Value.absent(),
    this.formality = const Value.absent(),
    this.targetPriceCents = const Value.absent(),
    this.priority = const Value.absent(),
    this.reason = const Value.absent(),
    this.status = const Value.absent(),
    this.purchasedItemId = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WishlistItemsCompanion.insert({
    required String id,
    required String name,
    required ClothingCategory category,
    this.subcategory = const Value.absent(),
    this.preferredColours = const Value.absent(),
    this.styleTags = const Value.absent(),
    this.formality = const Value.absent(),
    this.targetPriceCents = const Value.absent(),
    this.priority = const Value.absent(),
    this.reason = const Value.absent(),
    this.status = const Value.absent(),
    this.purchasedItemId = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       category = Value(category),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<WishlistItem> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? subcategory,
    Expression<String>? preferredColours,
    Expression<String>? styleTags,
    Expression<String>? formality,
    Expression<int>? targetPriceCents,
    Expression<String>? priority,
    Expression<String>? reason,
    Expression<String>? status,
    Expression<String>? purchasedItemId,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (subcategory != null) 'subcategory': subcategory,
      if (preferredColours != null) 'preferred_colours': preferredColours,
      if (styleTags != null) 'style_tags': styleTags,
      if (formality != null) 'formality': formality,
      if (targetPriceCents != null) 'target_price_cents': targetPriceCents,
      if (priority != null) 'priority': priority,
      if (reason != null) 'reason': reason,
      if (status != null) 'status': status,
      if (purchasedItemId != null) 'purchased_item_id': purchasedItemId,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WishlistItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<ClothingCategory>? category,
    Value<String?>? subcategory,
    Value<Set<WardrobeColour>>? preferredColours,
    Value<Set<StyleTag>>? styleTags,
    Value<Formality?>? formality,
    Value<int?>? targetPriceCents,
    Value<WishlistPriority>? priority,
    Value<String?>? reason,
    Value<WishlistStatus>? status,
    Value<String?>? purchasedItemId,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return WishlistItemsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      preferredColours: preferredColours ?? this.preferredColours,
      styleTags: styleTags ?? this.styleTags,
      formality: formality ?? this.formality,
      targetPriceCents: targetPriceCents ?? this.targetPriceCents,
      priority: priority ?? this.priority,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      purchasedItemId: purchasedItemId ?? this.purchasedItemId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(
        $WishlistItemsTable.$convertercategory.toSql(category.value),
      );
    }
    if (subcategory.present) {
      map['subcategory'] = Variable<String>(subcategory.value);
    }
    if (preferredColours.present) {
      map['preferred_colours'] = Variable<String>(
        $WishlistItemsTable.$converterpreferredColours.toSql(
          preferredColours.value,
        ),
      );
    }
    if (styleTags.present) {
      map['style_tags'] = Variable<String>(
        $WishlistItemsTable.$converterstyleTags.toSql(styleTags.value),
      );
    }
    if (formality.present) {
      map['formality'] = Variable<String>(
        $WishlistItemsTable.$converterformalityn.toSql(formality.value),
      );
    }
    if (targetPriceCents.present) {
      map['target_price_cents'] = Variable<int>(targetPriceCents.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(
        $WishlistItemsTable.$converterpriority.toSql(priority.value),
      );
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $WishlistItemsTable.$converterstatus.toSql(status.value),
      );
    }
    if (purchasedItemId.present) {
      map['purchased_item_id'] = Variable<String>(purchasedItemId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WishlistItemsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('subcategory: $subcategory, ')
          ..write('preferredColours: $preferredColours, ')
          ..write('styleTags: $styleTags, ')
          ..write('formality: $formality, ')
          ..write('targetPriceCents: $targetPriceCents, ')
          ..write('priority: $priority, ')
          ..write('reason: $reason, ')
          ..write('status: $status, ')
          ..write('purchasedItemId: $purchasedItemId, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserPreferencesTable extends UserPreferences
    with TableInfo<$UserPreferencesTable, UserPreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserPreferencesTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<PreferenceType, String>
  preferenceType =
      GeneratedColumn<String>(
        'preference_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PreferenceType>(
        $UserPreferencesTable.$converterpreferenceType,
      );
  static const VerificationMeta _preferenceValueMeta = const VerificationMeta(
    'preferenceValue',
  );
  @override
  late final GeneratedColumn<String> preferenceValue = GeneratedColumn<String>(
    'preference_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    preferenceType,
    preferenceValue,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserPreference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('preference_value')) {
      context.handle(
        _preferenceValueMeta,
        preferenceValue.isAcceptableOrUnknown(
          data['preference_value']!,
          _preferenceValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_preferenceValueMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {preferenceType, preferenceValue};
  @override
  UserPreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserPreference(
      preferenceType: $UserPreferencesTable.$converterpreferenceType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}preference_type'],
        )!,
      ),
      preferenceValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preference_value'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UserPreferencesTable createAlias(String alias) {
    return $UserPreferencesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PreferenceType, String, String>
  $converterpreferenceType = const EnumNameConverter<PreferenceType>(
    PreferenceType.values,
  );
}

class UserPreference extends DataClass implements Insertable<UserPreference> {
  final PreferenceType preferenceType;
  final String preferenceValue;
  final DateTime createdAt;
  const UserPreference({
    required this.preferenceType,
    required this.preferenceValue,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['preference_type'] = Variable<String>(
        $UserPreferencesTable.$converterpreferenceType.toSql(preferenceType),
      );
    }
    map['preference_value'] = Variable<String>(preferenceValue);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UserPreferencesCompanion toCompanion(bool nullToAbsent) {
    return UserPreferencesCompanion(
      preferenceType: Value(preferenceType),
      preferenceValue: Value(preferenceValue),
      createdAt: Value(createdAt),
    );
  }

  factory UserPreference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserPreference(
      preferenceType: $UserPreferencesTable.$converterpreferenceType.fromJson(
        serializer.fromJson<String>(json['preferenceType']),
      ),
      preferenceValue: serializer.fromJson<String>(json['preferenceValue']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'preferenceType': serializer.toJson<String>(
        $UserPreferencesTable.$converterpreferenceType.toJson(preferenceType),
      ),
      'preferenceValue': serializer.toJson<String>(preferenceValue),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UserPreference copyWith({
    PreferenceType? preferenceType,
    String? preferenceValue,
    DateTime? createdAt,
  }) => UserPreference(
    preferenceType: preferenceType ?? this.preferenceType,
    preferenceValue: preferenceValue ?? this.preferenceValue,
    createdAt: createdAt ?? this.createdAt,
  );
  UserPreference copyWithCompanion(UserPreferencesCompanion data) {
    return UserPreference(
      preferenceType: data.preferenceType.present
          ? data.preferenceType.value
          : this.preferenceType,
      preferenceValue: data.preferenceValue.present
          ? data.preferenceValue.value
          : this.preferenceValue,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserPreference(')
          ..write('preferenceType: $preferenceType, ')
          ..write('preferenceValue: $preferenceValue, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(preferenceType, preferenceValue, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPreference &&
          other.preferenceType == this.preferenceType &&
          other.preferenceValue == this.preferenceValue &&
          other.createdAt == this.createdAt);
}

class UserPreferencesCompanion extends UpdateCompanion<UserPreference> {
  final Value<PreferenceType> preferenceType;
  final Value<String> preferenceValue;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const UserPreferencesCompanion({
    this.preferenceType = const Value.absent(),
    this.preferenceValue = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserPreferencesCompanion.insert({
    required PreferenceType preferenceType,
    required String preferenceValue,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : preferenceType = Value(preferenceType),
       preferenceValue = Value(preferenceValue),
       createdAt = Value(createdAt);
  static Insertable<UserPreference> custom({
    Expression<String>? preferenceType,
    Expression<String>? preferenceValue,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (preferenceType != null) 'preference_type': preferenceType,
      if (preferenceValue != null) 'preference_value': preferenceValue,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserPreferencesCompanion copyWith({
    Value<PreferenceType>? preferenceType,
    Value<String>? preferenceValue,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return UserPreferencesCompanion(
      preferenceType: preferenceType ?? this.preferenceType,
      preferenceValue: preferenceValue ?? this.preferenceValue,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (preferenceType.present) {
      map['preference_type'] = Variable<String>(
        $UserPreferencesTable.$converterpreferenceType.toSql(
          preferenceType.value,
        ),
      );
    }
    if (preferenceValue.present) {
      map['preference_value'] = Variable<String>(preferenceValue.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserPreferencesCompanion(')
          ..write('preferenceType: $preferenceType, ')
          ..write('preferenceValue: $preferenceValue, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecommendationFeedbackTable extends RecommendationFeedback
    with TableInfo<$RecommendationFeedbackTable, FeedbackEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecommendationFeedbackTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _outfitFingerprintMeta = const VerificationMeta(
    'outfitFingerprint',
  );
  @override
  late final GeneratedColumn<String> outfitFingerprint =
      GeneratedColumn<String>(
        'outfit_fingerprint',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<FeedbackType, String>
  feedbackType =
      GeneratedColumn<String>(
        'feedback_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<FeedbackType>(
        $RecommendationFeedbackTable.$converterfeedbackType,
      );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    outfitFingerprint,
    rating,
    feedbackType,
    reason,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recommendation_feedback';
  @override
  VerificationContext validateIntegrity(
    Insertable<FeedbackEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('outfit_fingerprint')) {
      context.handle(
        _outfitFingerprintMeta,
        outfitFingerprint.isAcceptableOrUnknown(
          data['outfit_fingerprint']!,
          _outfitFingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_outfitFingerprintMeta);
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FeedbackEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeedbackEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      outfitFingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outfit_fingerprint'],
      )!,
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      ),
      feedbackType: $RecommendationFeedbackTable.$converterfeedbackType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}feedback_type'],
        )!,
      ),
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RecommendationFeedbackTable createAlias(String alias) {
    return $RecommendationFeedbackTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<FeedbackType, String, String>
  $converterfeedbackType = const EnumNameConverter<FeedbackType>(
    FeedbackType.values,
  );
}

class FeedbackEntry extends DataClass implements Insertable<FeedbackEntry> {
  final String id;
  final String outfitFingerprint;
  final int? rating;
  final FeedbackType feedbackType;
  final String? reason;
  final DateTime createdAt;
  const FeedbackEntry({
    required this.id,
    required this.outfitFingerprint,
    this.rating,
    required this.feedbackType,
    this.reason,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['outfit_fingerprint'] = Variable<String>(outfitFingerprint);
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<int>(rating);
    }
    {
      map['feedback_type'] = Variable<String>(
        $RecommendationFeedbackTable.$converterfeedbackType.toSql(feedbackType),
      );
    }
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RecommendationFeedbackCompanion toCompanion(bool nullToAbsent) {
    return RecommendationFeedbackCompanion(
      id: Value(id),
      outfitFingerprint: Value(outfitFingerprint),
      rating: rating == null && nullToAbsent
          ? const Value.absent()
          : Value(rating),
      feedbackType: Value(feedbackType),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      createdAt: Value(createdAt),
    );
  }

  factory FeedbackEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeedbackEntry(
      id: serializer.fromJson<String>(json['id']),
      outfitFingerprint: serializer.fromJson<String>(json['outfitFingerprint']),
      rating: serializer.fromJson<int?>(json['rating']),
      feedbackType: $RecommendationFeedbackTable.$converterfeedbackType
          .fromJson(serializer.fromJson<String>(json['feedbackType'])),
      reason: serializer.fromJson<String?>(json['reason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'outfitFingerprint': serializer.toJson<String>(outfitFingerprint),
      'rating': serializer.toJson<int?>(rating),
      'feedbackType': serializer.toJson<String>(
        $RecommendationFeedbackTable.$converterfeedbackType.toJson(
          feedbackType,
        ),
      ),
      'reason': serializer.toJson<String?>(reason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FeedbackEntry copyWith({
    String? id,
    String? outfitFingerprint,
    Value<int?> rating = const Value.absent(),
    FeedbackType? feedbackType,
    Value<String?> reason = const Value.absent(),
    DateTime? createdAt,
  }) => FeedbackEntry(
    id: id ?? this.id,
    outfitFingerprint: outfitFingerprint ?? this.outfitFingerprint,
    rating: rating.present ? rating.value : this.rating,
    feedbackType: feedbackType ?? this.feedbackType,
    reason: reason.present ? reason.value : this.reason,
    createdAt: createdAt ?? this.createdAt,
  );
  FeedbackEntry copyWithCompanion(RecommendationFeedbackCompanion data) {
    return FeedbackEntry(
      id: data.id.present ? data.id.value : this.id,
      outfitFingerprint: data.outfitFingerprint.present
          ? data.outfitFingerprint.value
          : this.outfitFingerprint,
      rating: data.rating.present ? data.rating.value : this.rating,
      feedbackType: data.feedbackType.present
          ? data.feedbackType.value
          : this.feedbackType,
      reason: data.reason.present ? data.reason.value : this.reason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeedbackEntry(')
          ..write('id: $id, ')
          ..write('outfitFingerprint: $outfitFingerprint, ')
          ..write('rating: $rating, ')
          ..write('feedbackType: $feedbackType, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    outfitFingerprint,
    rating,
    feedbackType,
    reason,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedbackEntry &&
          other.id == this.id &&
          other.outfitFingerprint == this.outfitFingerprint &&
          other.rating == this.rating &&
          other.feedbackType == this.feedbackType &&
          other.reason == this.reason &&
          other.createdAt == this.createdAt);
}

class RecommendationFeedbackCompanion extends UpdateCompanion<FeedbackEntry> {
  final Value<String> id;
  final Value<String> outfitFingerprint;
  final Value<int?> rating;
  final Value<FeedbackType> feedbackType;
  final Value<String?> reason;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const RecommendationFeedbackCompanion({
    this.id = const Value.absent(),
    this.outfitFingerprint = const Value.absent(),
    this.rating = const Value.absent(),
    this.feedbackType = const Value.absent(),
    this.reason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecommendationFeedbackCompanion.insert({
    required String id,
    required String outfitFingerprint,
    this.rating = const Value.absent(),
    required FeedbackType feedbackType,
    this.reason = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       outfitFingerprint = Value(outfitFingerprint),
       feedbackType = Value(feedbackType),
       createdAt = Value(createdAt);
  static Insertable<FeedbackEntry> custom({
    Expression<String>? id,
    Expression<String>? outfitFingerprint,
    Expression<int>? rating,
    Expression<String>? feedbackType,
    Expression<String>? reason,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (outfitFingerprint != null) 'outfit_fingerprint': outfitFingerprint,
      if (rating != null) 'rating': rating,
      if (feedbackType != null) 'feedback_type': feedbackType,
      if (reason != null) 'reason': reason,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecommendationFeedbackCompanion copyWith({
    Value<String>? id,
    Value<String>? outfitFingerprint,
    Value<int?>? rating,
    Value<FeedbackType>? feedbackType,
    Value<String?>? reason,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return RecommendationFeedbackCompanion(
      id: id ?? this.id,
      outfitFingerprint: outfitFingerprint ?? this.outfitFingerprint,
      rating: rating ?? this.rating,
      feedbackType: feedbackType ?? this.feedbackType,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (outfitFingerprint.present) {
      map['outfit_fingerprint'] = Variable<String>(outfitFingerprint.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (feedbackType.present) {
      map['feedback_type'] = Variable<String>(
        $RecommendationFeedbackTable.$converterfeedbackType.toSql(
          feedbackType.value,
        ),
      );
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecommendationFeedbackCompanion(')
          ..write('id: $id, ')
          ..write('outfitFingerprint: $outfitFingerprint, ')
          ..write('rating: $rating, ')
          ..write('feedbackType: $feedbackType, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ClothingItemsTable clothingItems = $ClothingItemsTable(this);
  late final $OutfitsTable outfits = $OutfitsTable(this);
  late final $OutfitItemsTable outfitItems = $OutfitItemsTable(this);
  late final $WishlistItemsTable wishlistItems = $WishlistItemsTable(this);
  late final $UserPreferencesTable userPreferences = $UserPreferencesTable(
    this,
  );
  late final $RecommendationFeedbackTable recommendationFeedback =
      $RecommendationFeedbackTable(this);
  late final ClothingDao clothingDao = ClothingDao(this as AppDatabase);
  late final OutfitDao outfitDao = OutfitDao(this as AppDatabase);
  late final RecommendationDao recommendationDao = RecommendationDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    clothingItems,
    outfits,
    outfitItems,
    wishlistItems,
    userPreferences,
    recommendationFeedback,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'outfits',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('outfit_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'clothing_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('outfit_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'clothing_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('wishlist_items', kind: UpdateKind.update)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$ClothingItemsTableCreateCompanionBuilder =
    ClothingItemsCompanion Function({
      required String id,
      required String name,
      required ClothingCategory category,
      Value<String?> subcategory,
      Value<WardrobeColour?> primaryColour,
      Value<Set<WardrobeColour>> secondaryColours,
      Value<ClothingPattern?> pattern,
      Value<String?> material,
      Value<ClothingFit?> fit,
      Value<Set<StyleTag>> styleTags,
      Value<Formality?> formality,
      Value<Set<Season>> seasons,
      Value<Set<Occasion>> occasions,
      Value<String?> brand,
      Value<String?> size,
      Value<ItemCondition> condition,
      Value<String?> imagePath,
      Value<bool> isFavourite,
      Value<bool> isArchived,
      Value<String?> notes,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ClothingItemsTableUpdateCompanionBuilder =
    ClothingItemsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<ClothingCategory> category,
      Value<String?> subcategory,
      Value<WardrobeColour?> primaryColour,
      Value<Set<WardrobeColour>> secondaryColours,
      Value<ClothingPattern?> pattern,
      Value<String?> material,
      Value<ClothingFit?> fit,
      Value<Set<StyleTag>> styleTags,
      Value<Formality?> formality,
      Value<Set<Season>> seasons,
      Value<Set<Occasion>> occasions,
      Value<String?> brand,
      Value<String?> size,
      Value<ItemCondition> condition,
      Value<String?> imagePath,
      Value<bool> isFavourite,
      Value<bool> isArchived,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ClothingItemsTableReferences
    extends BaseReferences<_$AppDatabase, $ClothingItemsTable, ClothingItem> {
  $$ClothingItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$OutfitItemsTable, List<OutfitItem>>
  _outfitItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.outfitItems,
    aliasName: 'clothing_items__id__outfit_items__clothing_item_id',
  );

  $$OutfitItemsTableProcessedTableManager get outfitItemsRefs {
    final manager = $$OutfitItemsTableTableManager(
      $_db,
      $_db.outfitItems,
    ).filter((f) => f.clothingItemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_outfitItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WishlistItemsTable, List<WishlistItem>>
  _wishlistItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.wishlistItems,
    aliasName: 'clothing_items__id__wishlist_items__purchased_item_id',
  );

  $$WishlistItemsTableProcessedTableManager get wishlistItemsRefs {
    final manager = $$WishlistItemsTableTableManager($_db, $_db.wishlistItems)
        .filter(
          (f) => f.purchasedItemId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_wishlistItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ClothingItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ClothingItemsTable> {
  $$ClothingItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ClothingCategory, ClothingCategory, String>
  get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get subcategory => $composableBuilder(
    column: $table.subcategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<WardrobeColour?, WardrobeColour, String>
  get primaryColour => $composableBuilder(
    column: $table.primaryColour,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Set<WardrobeColour>,
    Set<WardrobeColour>,
    String
  >
  get secondaryColours => $composableBuilder(
    column: $table.secondaryColours,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<ClothingPattern?, ClothingPattern, String>
  get pattern => $composableBuilder(
    column: $table.pattern,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get material => $composableBuilder(
    column: $table.material,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ClothingFit?, ClothingFit, String> get fit =>
      $composableBuilder(
        column: $table.fit,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Set<StyleTag>, Set<StyleTag>, String>
  get styleTags => $composableBuilder(
    column: $table.styleTags,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Formality?, Formality, String> get formality =>
      $composableBuilder(
        column: $table.formality,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Set<Season>, Set<Season>, String>
  get seasons => $composableBuilder(
    column: $table.seasons,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Set<Occasion>, Set<Occasion>, String>
  get occasions => $composableBuilder(
    column: $table.occasions,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ItemCondition, ItemCondition, String>
  get condition => $composableBuilder(
    column: $table.condition,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavourite => $composableBuilder(
    column: $table.isFavourite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> outfitItemsRefs(
    Expression<bool> Function($$OutfitItemsTableFilterComposer f) f,
  ) {
    final $$OutfitItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.outfitItems,
      getReferencedColumn: (t) => t.clothingItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OutfitItemsTableFilterComposer(
            $db: $db,
            $table: $db.outfitItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> wishlistItemsRefs(
    Expression<bool> Function($$WishlistItemsTableFilterComposer f) f,
  ) {
    final $$WishlistItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wishlistItems,
      getReferencedColumn: (t) => t.purchasedItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WishlistItemsTableFilterComposer(
            $db: $db,
            $table: $db.wishlistItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClothingItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ClothingItemsTable> {
  $$ClothingItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subcategory => $composableBuilder(
    column: $table.subcategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryColour => $composableBuilder(
    column: $table.primaryColour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secondaryColours => $composableBuilder(
    column: $table.secondaryColours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pattern => $composableBuilder(
    column: $table.pattern,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get material => $composableBuilder(
    column: $table.material,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fit => $composableBuilder(
    column: $table.fit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get styleTags => $composableBuilder(
    column: $table.styleTags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get formality => $composableBuilder(
    column: $table.formality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seasons => $composableBuilder(
    column: $table.seasons,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get occasions => $composableBuilder(
    column: $table.occasions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get condition => $composableBuilder(
    column: $table.condition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavourite => $composableBuilder(
    column: $table.isFavourite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClothingItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClothingItemsTable> {
  $$ClothingItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ClothingCategory, String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get subcategory => $composableBuilder(
    column: $table.subcategory,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<WardrobeColour?, String> get primaryColour =>
      $composableBuilder(
        column: $table.primaryColour,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Set<WardrobeColour>, String>
  get secondaryColours => $composableBuilder(
    column: $table.secondaryColours,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ClothingPattern?, String> get pattern =>
      $composableBuilder(column: $table.pattern, builder: (column) => column);

  GeneratedColumn<String> get material =>
      $composableBuilder(column: $table.material, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ClothingFit?, String> get fit =>
      $composableBuilder(column: $table.fit, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Set<StyleTag>, String> get styleTags =>
      $composableBuilder(column: $table.styleTags, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Formality?, String> get formality =>
      $composableBuilder(column: $table.formality, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Set<Season>, String> get seasons =>
      $composableBuilder(column: $table.seasons, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Set<Occasion>, String> get occasions =>
      $composableBuilder(column: $table.occasions, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ItemCondition, String> get condition =>
      $composableBuilder(column: $table.condition, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<bool> get isFavourite => $composableBuilder(
    column: $table.isFavourite,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> outfitItemsRefs<T extends Object>(
    Expression<T> Function($$OutfitItemsTableAnnotationComposer a) f,
  ) {
    final $$OutfitItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.outfitItems,
      getReferencedColumn: (t) => t.clothingItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OutfitItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.outfitItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> wishlistItemsRefs<T extends Object>(
    Expression<T> Function($$WishlistItemsTableAnnotationComposer a) f,
  ) {
    final $$WishlistItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wishlistItems,
      getReferencedColumn: (t) => t.purchasedItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WishlistItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.wishlistItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClothingItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClothingItemsTable,
          ClothingItem,
          $$ClothingItemsTableFilterComposer,
          $$ClothingItemsTableOrderingComposer,
          $$ClothingItemsTableAnnotationComposer,
          $$ClothingItemsTableCreateCompanionBuilder,
          $$ClothingItemsTableUpdateCompanionBuilder,
          (ClothingItem, $$ClothingItemsTableReferences),
          ClothingItem,
          PrefetchHooks Function({bool outfitItemsRefs, bool wishlistItemsRefs})
        > {
  $$ClothingItemsTableTableManager(_$AppDatabase db, $ClothingItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClothingItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClothingItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClothingItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<ClothingCategory> category = const Value.absent(),
                Value<String?> subcategory = const Value.absent(),
                Value<WardrobeColour?> primaryColour = const Value.absent(),
                Value<Set<WardrobeColour>> secondaryColours =
                    const Value.absent(),
                Value<ClothingPattern?> pattern = const Value.absent(),
                Value<String?> material = const Value.absent(),
                Value<ClothingFit?> fit = const Value.absent(),
                Value<Set<StyleTag>> styleTags = const Value.absent(),
                Value<Formality?> formality = const Value.absent(),
                Value<Set<Season>> seasons = const Value.absent(),
                Value<Set<Occasion>> occasions = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<String?> size = const Value.absent(),
                Value<ItemCondition> condition = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<bool> isFavourite = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClothingItemsCompanion(
                id: id,
                name: name,
                category: category,
                subcategory: subcategory,
                primaryColour: primaryColour,
                secondaryColours: secondaryColours,
                pattern: pattern,
                material: material,
                fit: fit,
                styleTags: styleTags,
                formality: formality,
                seasons: seasons,
                occasions: occasions,
                brand: brand,
                size: size,
                condition: condition,
                imagePath: imagePath,
                isFavourite: isFavourite,
                isArchived: isArchived,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required ClothingCategory category,
                Value<String?> subcategory = const Value.absent(),
                Value<WardrobeColour?> primaryColour = const Value.absent(),
                Value<Set<WardrobeColour>> secondaryColours =
                    const Value.absent(),
                Value<ClothingPattern?> pattern = const Value.absent(),
                Value<String?> material = const Value.absent(),
                Value<ClothingFit?> fit = const Value.absent(),
                Value<Set<StyleTag>> styleTags = const Value.absent(),
                Value<Formality?> formality = const Value.absent(),
                Value<Set<Season>> seasons = const Value.absent(),
                Value<Set<Occasion>> occasions = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<String?> size = const Value.absent(),
                Value<ItemCondition> condition = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<bool> isFavourite = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ClothingItemsCompanion.insert(
                id: id,
                name: name,
                category: category,
                subcategory: subcategory,
                primaryColour: primaryColour,
                secondaryColours: secondaryColours,
                pattern: pattern,
                material: material,
                fit: fit,
                styleTags: styleTags,
                formality: formality,
                seasons: seasons,
                occasions: occasions,
                brand: brand,
                size: size,
                condition: condition,
                imagePath: imagePath,
                isFavourite: isFavourite,
                isArchived: isArchived,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ClothingItemsTable, ClothingItem>(table),
                  $$ClothingItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({outfitItemsRefs = false, wishlistItemsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (outfitItemsRefs) db.outfitItems,
                    if (wishlistItemsRefs) db.wishlistItems,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (outfitItemsRefs)
                        await $_getPrefetchedData<
                          ClothingItem,
                          $ClothingItemsTable,
                          OutfitItem
                        >(
                          currentTable: table,
                          referencedTable: $$ClothingItemsTableReferences
                              ._outfitItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClothingItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).outfitItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.clothingItemId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (wishlistItemsRefs)
                        await $_getPrefetchedData<
                          ClothingItem,
                          $ClothingItemsTable,
                          WishlistItem
                        >(
                          currentTable: table,
                          referencedTable: $$ClothingItemsTableReferences
                              ._wishlistItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClothingItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).wishlistItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.purchasedItemId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ClothingItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClothingItemsTable,
      ClothingItem,
      $$ClothingItemsTableFilterComposer,
      $$ClothingItemsTableOrderingComposer,
      $$ClothingItemsTableAnnotationComposer,
      $$ClothingItemsTableCreateCompanionBuilder,
      $$ClothingItemsTableUpdateCompanionBuilder,
      (ClothingItem, $$ClothingItemsTableReferences),
      ClothingItem,
      PrefetchHooks Function({bool outfitItemsRefs, bool wishlistItemsRefs})
    >;
typedef $$OutfitsTableCreateCompanionBuilder =
    OutfitsCompanion Function({
      required String id,
      required String name,
      Value<Occasion?> occasion,
      Value<Season?> season,
      Value<int?> rating,
      Value<bool> isFavourite,
      Value<String?> notes,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$OutfitsTableUpdateCompanionBuilder =
    OutfitsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<Occasion?> occasion,
      Value<Season?> season,
      Value<int?> rating,
      Value<bool> isFavourite,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$OutfitsTableReferences
    extends BaseReferences<_$AppDatabase, $OutfitsTable, Outfit> {
  $$OutfitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$OutfitItemsTable, List<OutfitItem>>
  _outfitItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.outfitItems,
    aliasName: 'outfits__id__outfit_items__outfit_id',
  );

  $$OutfitItemsTableProcessedTableManager get outfitItemsRefs {
    final manager = $$OutfitItemsTableTableManager(
      $_db,
      $_db.outfitItems,
    ).filter((f) => f.outfitId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_outfitItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$OutfitsTableFilterComposer
    extends Composer<_$AppDatabase, $OutfitsTable> {
  $$OutfitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Occasion?, Occasion, String> get occasion =>
      $composableBuilder(
        column: $table.occasion,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Season?, Season, String> get season =>
      $composableBuilder(
        column: $table.season,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavourite => $composableBuilder(
    column: $table.isFavourite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> outfitItemsRefs(
    Expression<bool> Function($$OutfitItemsTableFilterComposer f) f,
  ) {
    final $$OutfitItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.outfitItems,
      getReferencedColumn: (t) => t.outfitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OutfitItemsTableFilterComposer(
            $db: $db,
            $table: $db.outfitItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OutfitsTableOrderingComposer
    extends Composer<_$AppDatabase, $OutfitsTable> {
  $$OutfitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get occasion => $composableBuilder(
    column: $table.occasion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavourite => $composableBuilder(
    column: $table.isFavourite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutfitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutfitsTable> {
  $$OutfitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Occasion?, String> get occasion =>
      $composableBuilder(column: $table.occasion, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Season?, String> get season =>
      $composableBuilder(column: $table.season, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<bool> get isFavourite => $composableBuilder(
    column: $table.isFavourite,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> outfitItemsRefs<T extends Object>(
    Expression<T> Function($$OutfitItemsTableAnnotationComposer a) f,
  ) {
    final $$OutfitItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.outfitItems,
      getReferencedColumn: (t) => t.outfitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OutfitItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.outfitItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OutfitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutfitsTable,
          Outfit,
          $$OutfitsTableFilterComposer,
          $$OutfitsTableOrderingComposer,
          $$OutfitsTableAnnotationComposer,
          $$OutfitsTableCreateCompanionBuilder,
          $$OutfitsTableUpdateCompanionBuilder,
          (Outfit, $$OutfitsTableReferences),
          Outfit,
          PrefetchHooks Function({bool outfitItemsRefs})
        > {
  $$OutfitsTableTableManager(_$AppDatabase db, $OutfitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutfitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutfitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutfitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<Occasion?> occasion = const Value.absent(),
                Value<Season?> season = const Value.absent(),
                Value<int?> rating = const Value.absent(),
                Value<bool> isFavourite = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutfitsCompanion(
                id: id,
                name: name,
                occasion: occasion,
                season: season,
                rating: rating,
                isFavourite: isFavourite,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<Occasion?> occasion = const Value.absent(),
                Value<Season?> season = const Value.absent(),
                Value<int?> rating = const Value.absent(),
                Value<bool> isFavourite = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => OutfitsCompanion.insert(
                id: id,
                name: name,
                occasion: occasion,
                season: season,
                rating: rating,
                isFavourite: isFavourite,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OutfitsTable, Outfit>(table),
                  $$OutfitsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({outfitItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (outfitItemsRefs) db.outfitItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (outfitItemsRefs)
                    await $_getPrefetchedData<
                      Outfit,
                      $OutfitsTable,
                      OutfitItem
                    >(
                      currentTable: table,
                      referencedTable: $$OutfitsTableReferences
                          ._outfitItemsRefsTable(db),
                      managerFromTypedResult: (p0) => $$OutfitsTableReferences(
                        db,
                        table,
                        p0,
                      ).outfitItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.outfitId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$OutfitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutfitsTable,
      Outfit,
      $$OutfitsTableFilterComposer,
      $$OutfitsTableOrderingComposer,
      $$OutfitsTableAnnotationComposer,
      $$OutfitsTableCreateCompanionBuilder,
      $$OutfitsTableUpdateCompanionBuilder,
      (Outfit, $$OutfitsTableReferences),
      Outfit,
      PrefetchHooks Function({bool outfitItemsRefs})
    >;
typedef $$OutfitItemsTableCreateCompanionBuilder =
    OutfitItemsCompanion Function({
      required String outfitId,
      required String clothingItemId,
      required int position,
      Value<int> rowid,
    });
typedef $$OutfitItemsTableUpdateCompanionBuilder =
    OutfitItemsCompanion Function({
      Value<String> outfitId,
      Value<String> clothingItemId,
      Value<int> position,
      Value<int> rowid,
    });

final class $$OutfitItemsTableReferences
    extends BaseReferences<_$AppDatabase, $OutfitItemsTable, OutfitItem> {
  $$OutfitItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $OutfitsTable _outfitIdTable(_$AppDatabase db) =>
      db.outfits.createAlias('outfit_items__outfit_id__outfits__id');

  $$OutfitsTableProcessedTableManager get outfitId {
    final $_column = $_itemColumn<String>('outfit_id')!;

    final manager = $$OutfitsTableTableManager(
      $_db,
      $_db.outfits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_outfitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ClothingItemsTable _clothingItemIdTable(_$AppDatabase db) => db
      .clothingItems
      .createAlias('outfit_items__clothing_item_id__clothing_items__id');

  $$ClothingItemsTableProcessedTableManager get clothingItemId {
    final $_column = $_itemColumn<String>('clothing_item_id')!;

    final manager = $$ClothingItemsTableTableManager(
      $_db,
      $_db.clothingItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clothingItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$OutfitItemsTableFilterComposer
    extends Composer<_$AppDatabase, $OutfitItemsTable> {
  $$OutfitItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$OutfitsTableFilterComposer get outfitId {
    final $$OutfitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.outfitId,
      referencedTable: $db.outfits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OutfitsTableFilterComposer(
            $db: $db,
            $table: $db.outfits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ClothingItemsTableFilterComposer get clothingItemId {
    final $$ClothingItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clothingItemId,
      referencedTable: $db.clothingItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClothingItemsTableFilterComposer(
            $db: $db,
            $table: $db.clothingItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OutfitItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $OutfitItemsTable> {
  $$OutfitItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$OutfitsTableOrderingComposer get outfitId {
    final $$OutfitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.outfitId,
      referencedTable: $db.outfits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OutfitsTableOrderingComposer(
            $db: $db,
            $table: $db.outfits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ClothingItemsTableOrderingComposer get clothingItemId {
    final $$ClothingItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clothingItemId,
      referencedTable: $db.clothingItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClothingItemsTableOrderingComposer(
            $db: $db,
            $table: $db.clothingItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OutfitItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutfitItemsTable> {
  $$OutfitItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$OutfitsTableAnnotationComposer get outfitId {
    final $$OutfitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.outfitId,
      referencedTable: $db.outfits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OutfitsTableAnnotationComposer(
            $db: $db,
            $table: $db.outfits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ClothingItemsTableAnnotationComposer get clothingItemId {
    final $$ClothingItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clothingItemId,
      referencedTable: $db.clothingItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClothingItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.clothingItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OutfitItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutfitItemsTable,
          OutfitItem,
          $$OutfitItemsTableFilterComposer,
          $$OutfitItemsTableOrderingComposer,
          $$OutfitItemsTableAnnotationComposer,
          $$OutfitItemsTableCreateCompanionBuilder,
          $$OutfitItemsTableUpdateCompanionBuilder,
          (OutfitItem, $$OutfitItemsTableReferences),
          OutfitItem,
          PrefetchHooks Function({bool outfitId, bool clothingItemId})
        > {
  $$OutfitItemsTableTableManager(_$AppDatabase db, $OutfitItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutfitItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutfitItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutfitItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> outfitId = const Value.absent(),
                Value<String> clothingItemId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutfitItemsCompanion(
                outfitId: outfitId,
                clothingItemId: clothingItemId,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String outfitId,
                required String clothingItemId,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => OutfitItemsCompanion.insert(
                outfitId: outfitId,
                clothingItemId: clothingItemId,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OutfitItemsTable, OutfitItem>(table),
                  $$OutfitItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({outfitId = false, clothingItemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (outfitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.outfitId,
                                referencedTable: $$OutfitItemsTableReferences
                                    ._outfitIdTable(db),
                                referencedColumn: $$OutfitItemsTableReferences
                                    ._outfitIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (clothingItemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.clothingItemId,
                                referencedTable: $$OutfitItemsTableReferences
                                    ._clothingItemIdTable(db),
                                referencedColumn: $$OutfitItemsTableReferences
                                    ._clothingItemIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$OutfitItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutfitItemsTable,
      OutfitItem,
      $$OutfitItemsTableFilterComposer,
      $$OutfitItemsTableOrderingComposer,
      $$OutfitItemsTableAnnotationComposer,
      $$OutfitItemsTableCreateCompanionBuilder,
      $$OutfitItemsTableUpdateCompanionBuilder,
      (OutfitItem, $$OutfitItemsTableReferences),
      OutfitItem,
      PrefetchHooks Function({bool outfitId, bool clothingItemId})
    >;
typedef $$WishlistItemsTableCreateCompanionBuilder =
    WishlistItemsCompanion Function({
      required String id,
      required String name,
      required ClothingCategory category,
      Value<String?> subcategory,
      Value<Set<WardrobeColour>> preferredColours,
      Value<Set<StyleTag>> styleTags,
      Value<Formality?> formality,
      Value<int?> targetPriceCents,
      Value<WishlistPriority> priority,
      Value<String?> reason,
      Value<WishlistStatus> status,
      Value<String?> purchasedItemId,
      Value<String?> notes,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$WishlistItemsTableUpdateCompanionBuilder =
    WishlistItemsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<ClothingCategory> category,
      Value<String?> subcategory,
      Value<Set<WardrobeColour>> preferredColours,
      Value<Set<StyleTag>> styleTags,
      Value<Formality?> formality,
      Value<int?> targetPriceCents,
      Value<WishlistPriority> priority,
      Value<String?> reason,
      Value<WishlistStatus> status,
      Value<String?> purchasedItemId,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$WishlistItemsTableReferences
    extends BaseReferences<_$AppDatabase, $WishlistItemsTable, WishlistItem> {
  $$WishlistItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ClothingItemsTable _purchasedItemIdTable(_$AppDatabase db) => db
      .clothingItems
      .createAlias('wishlist_items__purchased_item_id__clothing_items__id');

  $$ClothingItemsTableProcessedTableManager? get purchasedItemId {
    final $_column = $_itemColumn<String>('purchased_item_id');
    if ($_column == null) return null;
    final manager = $$ClothingItemsTableTableManager(
      $_db,
      $_db.clothingItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_purchasedItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WishlistItemsTableFilterComposer
    extends Composer<_$AppDatabase, $WishlistItemsTable> {
  $$WishlistItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ClothingCategory, ClothingCategory, String>
  get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get subcategory => $composableBuilder(
    column: $table.subcategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Set<WardrobeColour>,
    Set<WardrobeColour>,
    String
  >
  get preferredColours => $composableBuilder(
    column: $table.preferredColours,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Set<StyleTag>, Set<StyleTag>, String>
  get styleTags => $composableBuilder(
    column: $table.styleTags,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Formality?, Formality, String> get formality =>
      $composableBuilder(
        column: $table.formality,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get targetPriceCents => $composableBuilder(
    column: $table.targetPriceCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<WishlistPriority, WishlistPriority, String>
  get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<WishlistStatus, WishlistStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ClothingItemsTableFilterComposer get purchasedItemId {
    final $$ClothingItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchasedItemId,
      referencedTable: $db.clothingItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClothingItemsTableFilterComposer(
            $db: $db,
            $table: $db.clothingItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WishlistItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $WishlistItemsTable> {
  $$WishlistItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subcategory => $composableBuilder(
    column: $table.subcategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preferredColours => $composableBuilder(
    column: $table.preferredColours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get styleTags => $composableBuilder(
    column: $table.styleTags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get formality => $composableBuilder(
    column: $table.formality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetPriceCents => $composableBuilder(
    column: $table.targetPriceCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClothingItemsTableOrderingComposer get purchasedItemId {
    final $$ClothingItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchasedItemId,
      referencedTable: $db.clothingItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClothingItemsTableOrderingComposer(
            $db: $db,
            $table: $db.clothingItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WishlistItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WishlistItemsTable> {
  $$WishlistItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ClothingCategory, String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get subcategory => $composableBuilder(
    column: $table.subcategory,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Set<WardrobeColour>, String>
  get preferredColours => $composableBuilder(
    column: $table.preferredColours,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Set<StyleTag>, String> get styleTags =>
      $composableBuilder(column: $table.styleTags, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Formality?, String> get formality =>
      $composableBuilder(column: $table.formality, builder: (column) => column);

  GeneratedColumn<int> get targetPriceCents => $composableBuilder(
    column: $table.targetPriceCents,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<WishlistPriority, String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumnWithTypeConverter<WishlistStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ClothingItemsTableAnnotationComposer get purchasedItemId {
    final $$ClothingItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchasedItemId,
      referencedTable: $db.clothingItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClothingItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.clothingItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WishlistItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WishlistItemsTable,
          WishlistItem,
          $$WishlistItemsTableFilterComposer,
          $$WishlistItemsTableOrderingComposer,
          $$WishlistItemsTableAnnotationComposer,
          $$WishlistItemsTableCreateCompanionBuilder,
          $$WishlistItemsTableUpdateCompanionBuilder,
          (WishlistItem, $$WishlistItemsTableReferences),
          WishlistItem,
          PrefetchHooks Function({bool purchasedItemId})
        > {
  $$WishlistItemsTableTableManager(_$AppDatabase db, $WishlistItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WishlistItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WishlistItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WishlistItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<ClothingCategory> category = const Value.absent(),
                Value<String?> subcategory = const Value.absent(),
                Value<Set<WardrobeColour>> preferredColours =
                    const Value.absent(),
                Value<Set<StyleTag>> styleTags = const Value.absent(),
                Value<Formality?> formality = const Value.absent(),
                Value<int?> targetPriceCents = const Value.absent(),
                Value<WishlistPriority> priority = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<WishlistStatus> status = const Value.absent(),
                Value<String?> purchasedItemId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WishlistItemsCompanion(
                id: id,
                name: name,
                category: category,
                subcategory: subcategory,
                preferredColours: preferredColours,
                styleTags: styleTags,
                formality: formality,
                targetPriceCents: targetPriceCents,
                priority: priority,
                reason: reason,
                status: status,
                purchasedItemId: purchasedItemId,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required ClothingCategory category,
                Value<String?> subcategory = const Value.absent(),
                Value<Set<WardrobeColour>> preferredColours =
                    const Value.absent(),
                Value<Set<StyleTag>> styleTags = const Value.absent(),
                Value<Formality?> formality = const Value.absent(),
                Value<int?> targetPriceCents = const Value.absent(),
                Value<WishlistPriority> priority = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<WishlistStatus> status = const Value.absent(),
                Value<String?> purchasedItemId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => WishlistItemsCompanion.insert(
                id: id,
                name: name,
                category: category,
                subcategory: subcategory,
                preferredColours: preferredColours,
                styleTags: styleTags,
                formality: formality,
                targetPriceCents: targetPriceCents,
                priority: priority,
                reason: reason,
                status: status,
                purchasedItemId: purchasedItemId,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WishlistItemsTable, WishlistItem>(table),
                  $$WishlistItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({purchasedItemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (purchasedItemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.purchasedItemId,
                                referencedTable: $$WishlistItemsTableReferences
                                    ._purchasedItemIdTable(db),
                                referencedColumn: $$WishlistItemsTableReferences
                                    ._purchasedItemIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WishlistItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WishlistItemsTable,
      WishlistItem,
      $$WishlistItemsTableFilterComposer,
      $$WishlistItemsTableOrderingComposer,
      $$WishlistItemsTableAnnotationComposer,
      $$WishlistItemsTableCreateCompanionBuilder,
      $$WishlistItemsTableUpdateCompanionBuilder,
      (WishlistItem, $$WishlistItemsTableReferences),
      WishlistItem,
      PrefetchHooks Function({bool purchasedItemId})
    >;
typedef $$UserPreferencesTableCreateCompanionBuilder =
    UserPreferencesCompanion Function({
      required PreferenceType preferenceType,
      required String preferenceValue,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$UserPreferencesTableUpdateCompanionBuilder =
    UserPreferencesCompanion Function({
      Value<PreferenceType> preferenceType,
      Value<String> preferenceValue,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$UserPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<PreferenceType, PreferenceType, String>
  get preferenceType => $composableBuilder(
    column: $table.preferenceType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get preferenceValue => $composableBuilder(
    column: $table.preferenceValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get preferenceType => $composableBuilder(
    column: $table.preferenceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preferenceValue => $composableBuilder(
    column: $table.preferenceValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<PreferenceType, String> get preferenceType =>
      $composableBuilder(
        column: $table.preferenceType,
        builder: (column) => column,
      );

  GeneratedColumn<String> get preferenceValue => $composableBuilder(
    column: $table.preferenceValue,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UserPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserPreferencesTable,
          UserPreference,
          $$UserPreferencesTableFilterComposer,
          $$UserPreferencesTableOrderingComposer,
          $$UserPreferencesTableAnnotationComposer,
          $$UserPreferencesTableCreateCompanionBuilder,
          $$UserPreferencesTableUpdateCompanionBuilder,
          (
            UserPreference,
            BaseReferences<
              _$AppDatabase,
              $UserPreferencesTable,
              UserPreference
            >,
          ),
          UserPreference,
          PrefetchHooks Function()
        > {
  $$UserPreferencesTableTableManager(
    _$AppDatabase db,
    $UserPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserPreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<PreferenceType> preferenceType = const Value.absent(),
                Value<String> preferenceValue = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserPreferencesCompanion(
                preferenceType: preferenceType,
                preferenceValue: preferenceValue,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required PreferenceType preferenceType,
                required String preferenceValue,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => UserPreferencesCompanion.insert(
                preferenceType: preferenceType,
                preferenceValue: preferenceValue,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserPreferencesTable, UserPreference>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $UserPreferencesTable,
                    UserPreference
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserPreferencesTable,
      UserPreference,
      $$UserPreferencesTableFilterComposer,
      $$UserPreferencesTableOrderingComposer,
      $$UserPreferencesTableAnnotationComposer,
      $$UserPreferencesTableCreateCompanionBuilder,
      $$UserPreferencesTableUpdateCompanionBuilder,
      (
        UserPreference,
        BaseReferences<_$AppDatabase, $UserPreferencesTable, UserPreference>,
      ),
      UserPreference,
      PrefetchHooks Function()
    >;
typedef $$RecommendationFeedbackTableCreateCompanionBuilder =
    RecommendationFeedbackCompanion Function({
      required String id,
      required String outfitFingerprint,
      Value<int?> rating,
      required FeedbackType feedbackType,
      Value<String?> reason,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$RecommendationFeedbackTableUpdateCompanionBuilder =
    RecommendationFeedbackCompanion Function({
      Value<String> id,
      Value<String> outfitFingerprint,
      Value<int?> rating,
      Value<FeedbackType> feedbackType,
      Value<String?> reason,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$RecommendationFeedbackTableFilterComposer
    extends Composer<_$AppDatabase, $RecommendationFeedbackTable> {
  $$RecommendationFeedbackTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outfitFingerprint => $composableBuilder(
    column: $table.outfitFingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<FeedbackType, FeedbackType, String>
  get feedbackType => $composableBuilder(
    column: $table.feedbackType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecommendationFeedbackTableOrderingComposer
    extends Composer<_$AppDatabase, $RecommendationFeedbackTable> {
  $$RecommendationFeedbackTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outfitFingerprint => $composableBuilder(
    column: $table.outfitFingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedbackType => $composableBuilder(
    column: $table.feedbackType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecommendationFeedbackTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecommendationFeedbackTable> {
  $$RecommendationFeedbackTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get outfitFingerprint => $composableBuilder(
    column: $table.outfitFingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FeedbackType, String> get feedbackType =>
      $composableBuilder(
        column: $table.feedbackType,
        builder: (column) => column,
      );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$RecommendationFeedbackTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecommendationFeedbackTable,
          FeedbackEntry,
          $$RecommendationFeedbackTableFilterComposer,
          $$RecommendationFeedbackTableOrderingComposer,
          $$RecommendationFeedbackTableAnnotationComposer,
          $$RecommendationFeedbackTableCreateCompanionBuilder,
          $$RecommendationFeedbackTableUpdateCompanionBuilder,
          (
            FeedbackEntry,
            BaseReferences<
              _$AppDatabase,
              $RecommendationFeedbackTable,
              FeedbackEntry
            >,
          ),
          FeedbackEntry,
          PrefetchHooks Function()
        > {
  $$RecommendationFeedbackTableTableManager(
    _$AppDatabase db,
    $RecommendationFeedbackTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecommendationFeedbackTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$RecommendationFeedbackTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RecommendationFeedbackTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> outfitFingerprint = const Value.absent(),
                Value<int?> rating = const Value.absent(),
                Value<FeedbackType> feedbackType = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecommendationFeedbackCompanion(
                id: id,
                outfitFingerprint: outfitFingerprint,
                rating: rating,
                feedbackType: feedbackType,
                reason: reason,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String outfitFingerprint,
                Value<int?> rating = const Value.absent(),
                required FeedbackType feedbackType,
                Value<String?> reason = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => RecommendationFeedbackCompanion.insert(
                id: id,
                outfitFingerprint: outfitFingerprint,
                rating: rating,
                feedbackType: feedbackType,
                reason: reason,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecommendationFeedbackTable, FeedbackEntry>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $RecommendationFeedbackTable,
                    FeedbackEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecommendationFeedbackTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecommendationFeedbackTable,
      FeedbackEntry,
      $$RecommendationFeedbackTableFilterComposer,
      $$RecommendationFeedbackTableOrderingComposer,
      $$RecommendationFeedbackTableAnnotationComposer,
      $$RecommendationFeedbackTableCreateCompanionBuilder,
      $$RecommendationFeedbackTableUpdateCompanionBuilder,
      (
        FeedbackEntry,
        BaseReferences<
          _$AppDatabase,
          $RecommendationFeedbackTable,
          FeedbackEntry
        >,
      ),
      FeedbackEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ClothingItemsTableTableManager get clothingItems =>
      $$ClothingItemsTableTableManager(_db, _db.clothingItems);
  $$OutfitsTableTableManager get outfits =>
      $$OutfitsTableTableManager(_db, _db.outfits);
  $$OutfitItemsTableTableManager get outfitItems =>
      $$OutfitItemsTableTableManager(_db, _db.outfitItems);
  $$WishlistItemsTableTableManager get wishlistItems =>
      $$WishlistItemsTableTableManager(_db, _db.wishlistItems);
  $$UserPreferencesTableTableManager get userPreferences =>
      $$UserPreferencesTableTableManager(_db, _db.userPreferences);
  $$RecommendationFeedbackTableTableManager get recommendationFeedback =>
      $$RecommendationFeedbackTableTableManager(
        _db,
        _db.recommendationFeedback,
      );
}
