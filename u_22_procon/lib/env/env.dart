import 'package:envied/envied.dart';

part 'env.g.dart';

//参考サイトと最後の行は違う
@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'key', obfuscate: true)
  static final String api_key = _Env.api_key;
}
