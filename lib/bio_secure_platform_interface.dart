import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'bio_secure_method_channel.dart';

abstract class BioSecurePlatform extends PlatformInterface {
  /// Constructs a BioSecurePlatform.
  BioSecurePlatform() : super(token: _token);

  static final Object _token = Object();

  static BioSecurePlatform _instance = MethodChannelBioSecure();

  /// The default instance of [BioSecurePlatform] to use.
  ///
  /// Defaults to [MethodChannelBioSecure].
  static BioSecurePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BioSecurePlatform] when
  /// they register themselves.
  static set instance(BioSecurePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
