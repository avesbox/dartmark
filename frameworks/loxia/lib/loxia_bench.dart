import 'package:loxia/loxia.dart';
part 'loxia_bench.g.dart';

@EntityMeta(table: 'users')
class User extends Entity {
  @PrimaryKey(autoIncrement: true)
  final int id;

  @Column()
  final String name;

  User({required this.id, required this.name});

  static EntityDescriptor<User, UserPartial> get entity => $UserEntityDescriptor;
}