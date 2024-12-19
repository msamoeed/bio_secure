import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'bio_secure_platform_interface.dart';

/// An implementation of [BioSecurePlatform] that uses method channels.
class MethodChannelBioSecure extends BioSecurePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('bio_secure');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
