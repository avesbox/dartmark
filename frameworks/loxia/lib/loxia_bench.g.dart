// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loxia_bench.dart';

// **************************************************************************
// LoxiaEntityGenerator
// **************************************************************************

final EntityDescriptor<User, UserPartial> $UserEntityDescriptor = () {
  $initUserJsonCodec();
  return EntityDescriptor(
    entityType: User,
    tableName: 'users',
    columns: [
      ColumnDescriptor(
        name: 'id',
        propertyName: 'id',
        type: ColumnType.integer,
        nullable: false,
        unique: false,
        isPrimaryKey: true,
        autoIncrement: true,
        uuid: false,
        isDeletedAt: false,
      ),
      ColumnDescriptor(
        name: 'name',
        propertyName: 'name',
        type: ColumnType.text,
        nullable: false,
        unique: false,
        isPrimaryKey: false,
        autoIncrement: false,
        uuid: false,
        isDeletedAt: false,
      ),
    ],
    relations: const [],
    fromRow: (row) =>
        User(id: (row['id'] as int), name: (row['name'] as String)),
    toRow: (e) => {'id': e.id, 'name': e.name},
    fieldsContext: const UserFieldsContext(),
    repositoryFactory: (EngineAdapter engine) => UserRepository(engine),
    defaultSelect: () => UserSelect(),
  );
}();

class UserFieldsContext extends QueryFieldsContext<User> {
  const UserFieldsContext([super.runtimeContext, super.alias]);

  @override
  UserFieldsContext bind(QueryRuntimeContext runtimeContext, String alias) =>
      UserFieldsContext(runtimeContext, alias);

  QueryField<int> get id => field<int>('id');

  QueryField<String> get name => field<String>('name');
}

class UserQuery extends QueryBuilder<User> {
  const UserQuery(this._builder);

  final WhereExpression Function(UserFieldsContext) _builder;

  @override
  WhereExpression build(QueryFieldsContext<User> context) {
    if (context is! UserFieldsContext) {
      throw ArgumentError('Expected UserFieldsContext for UserQuery');
    }
    return _builder(context);
  }
}

class UserSelect extends SelectOptions<User, UserPartial> {
  const UserSelect({this.id = true, this.name = true, this.relations});

  final bool id;

  final bool name;

  final UserRelations? relations;

  @override
  bool get hasSelections => id || name || (relations?.hasSelections ?? false);

  @override
  SelectOptions<User, UserPartial> withRelations(
    RelationsOptions<User, UserPartial>? relations,
  ) {
    return UserSelect(
      id: id,
      name: name,
      relations: relations as UserRelations?,
    );
  }

  @override
  void collect(
    QueryFieldsContext<User> context,
    List<SelectField> out, {
    String? path,
  }) {
    if (context is! UserFieldsContext) {
      throw ArgumentError('Expected UserFieldsContext for UserSelect');
    }
    final UserFieldsContext scoped = context;
    String? aliasFor(String column) {
      final current = path;
      if (current == null || current.isEmpty) return null;
      return '${current}_$column';
    }

    final tableAlias = scoped.currentAlias;
    if (id) {
      out.add(SelectField('id', tableAlias: tableAlias, alias: aliasFor('id')));
    }
    if (name) {
      out.add(
        SelectField('name', tableAlias: tableAlias, alias: aliasFor('name')),
      );
    }
    final rels = relations;
    if (rels != null && rels.hasSelections) {
      rels.collect(scoped, out, path: path);
    }
  }

  @override
  UserPartial hydrate(Map<String, dynamic> row, {String? path}) {
    return UserPartial(
      id: id ? readValue(row, 'id', path: path) as int : null,
      name: name ? readValue(row, 'name', path: path) as String : null,
    );
  }

  @override
  bool get hasCollectionRelations => false;

  @override
  String? get primaryKeyColumn => 'id';
}

class UserRelations extends RelationsOptions<User, UserPartial> {
  const UserRelations();

  @override
  bool get hasSelections => false;

  @override
  void collect(
    QueryFieldsContext<User> context,
    List<SelectField> out, {
    String? path,
  }) {
    if (context is! UserFieldsContext) {
      throw ArgumentError('Expected UserFieldsContext for UserRelations');
    }
  }
}

class UserPartial extends PartialEntity<User> {
  const UserPartial({this.id, this.name});

  final int? id;

  final String? name;

  @override
  Object? get primaryKeyValue {
    return id;
  }

  @override
  UserInsertDto toInsertDto() {
    final missing = <String>[];
    if (name == null) missing.add('name');
    if (missing.isNotEmpty) {
      throw StateError(
        'Cannot convert UserPartial to UserInsertDto: missing required fields: ${missing.join(', ')}',
      );
    }
    return UserInsertDto(name: name!);
  }

  @override
  UserUpdateDto toUpdateDto() {
    return UserUpdateDto(name: name);
  }

  @override
  User toEntity() {
    final missing = <String>[];
    if (id == null) missing.add('id');
    if (name == null) missing.add('name');
    if (missing.isNotEmpty) {
      throw StateError(
        'Cannot convert UserPartial to User: missing required fields: ${missing.join(', ')}',
      );
    }
    return User(id: id!, name: name!);
  }

  @override
  Map<String, dynamic> toJson() {
    return {if (id != null) 'id': id, if (name != null) 'name': name};
  }
}

class UserInsertDto implements InsertDto<User> {
  const UserInsertDto({required this.name});

  final String name;

  @override
  Map<String, dynamic> toMap() {
    return {'name': name};
  }

  Map<String, dynamic> get cascades {
    return const {};
  }

  UserInsertDto copyWith({String? name}) {
    return UserInsertDto(name: name ?? this.name);
  }
}

class UserUpdateDto implements UpdateDto<User> {
  const UserUpdateDto({this.name});

  final String? name;

  @override
  Map<String, dynamic> toMap() {
    return {if (name != null) 'name': name};
  }

  Map<String, dynamic> get cascades {
    return const {};
  }
}

class UserRepository extends EntityRepository<User, UserPartial> {
  UserRepository(EngineAdapter engine)
    : super($UserEntityDescriptor, engine, $UserEntityDescriptor.fieldsContext);
}

extension UserJson on User {
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

extension UserCodec on User {
  Object? toEncodable() {
    return toJson();
  }

  String toJsonString() {
    return encodeJsonColumn(toJson()) as String;
  }
}

extension UserPartialCodec on UserPartial {
  Object? toEncodable() {
    return toJson();
  }

  String toJsonString() {
    return encodeJsonColumn(toJson()) as String;
  }
}

var $isUserJsonCodecInitialized = false;
void $initUserJsonCodec() {
  if ($isUserJsonCodecInitialized) return;
  EntityJsonRegistry.register<User>((value) => UserJson(value).toJson());
  $isUserJsonCodecInitialized = true;
}

extension UserRepositoryExtensions
    on EntityRepository<User, PartialEntity<User>> {}
