import 'package:flutter_test/flutter_test.dart';
import 'package:bio_secure/bio_secure.dart';
import 'package:bio_secure/bio_secure_platform_interface.dart';
import 'package:bio_secure/bio_secure_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBioSecurePlatform
    with MockPlatformInterfaceMixin
    implements BioSecurePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final BioSecurePlatform initialPlatform = BioSecurePlatform.instance;

  test('$MethodChannelBioSecure is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelBioSecure>());
  });

  test('getPlatformVersion', () async {
    BioSecure bioSecurePlugin = BioSecure();
    MockBioSecurePlatform fakePlatform = MockBioSecurePlatform();
    BioSecurePlatform.instance = fakePlatform;

    expect(await bioSecurePlugin.getPlatformVersion(), '42');
  });
}
