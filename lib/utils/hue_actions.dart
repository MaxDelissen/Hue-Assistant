import 'package:flutter_hue/flutter_hue.dart';

class HueActions {
  final HueNetwork network;

  HueActions._(this.network);


  static Future<HueActions> create() async {
    // Find the Hue bridges on the network
    List<DiscoveredBridge> bridges = await BridgeDiscoveryRepo.discoverBridges();
    if (bridges.isEmpty) {
      throw Exception('No Hue bridges found');
    }

    // Use the first discovered bridge
    String bridgeIp = bridges.first.ipAddress;

    //Need to press the hue button within 30 seconds.
    final DiscoveryTimeoutController controller = DiscoveryTimeoutController(timeoutSeconds: 30);

    // Attempt to connect to the bridge using the discovered IP address
    Bridge? bridge = await BridgeDiscoveryRepo.firstContact(
      bridgeIpAddr: bridgeIp,
      controller: controller,
    );

    if (bridge == null) {
      throw Exception('Failed to connect to Hue bridge');
    }

    // Create a HueNetwork instance with the discovered bridge
    HueNetwork network = HueNetwork(bridges: [bridge]);
    await network.fetchAll();
    return HueActions._(network);
  }

  Future<void> updateNetwork() async {
    try {
      await network.fetchAll();
    } catch (e) {
      throw Exception('Failed to update network: $e');
    }
  }

  Future<List<Light>> getLights() async {
    try {
      List<Light> lights = network.lights;
      return lights;
    } catch (e) {
      throw Exception('Failed to get lights: $e');
    }
  }

  Future<void> setLightState(Light light, bool on) async {
    try {
      light.on.isOn = on;
      network.put();
    } catch (e) {
      throw Exception('Failed to set light state: $e');
    }
  }
}