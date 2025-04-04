import 'dart:ui';

import 'package:flutter_hue/flutter_hue.dart';

class HueActions {
  final HueNetwork network;
  static HueActions? _instance;

  HueActions._(this.network);

  //TODO: Implement the correct way to handle reconnecting to the bridge after app close, without having to re-discover the bridge.
  static Future<HueActions> create() async {
    if (_instance != null) {
      return _instance!;
    }

    // Find the Hue bridges on the network
    print("Looking for Hue bridges...");
    List<DiscoveredBridge> bridges = await BridgeDiscoveryRepo.discoverBridges(
      writeToLocal: false,
    );
    if (bridges.isEmpty) {
      throw Exception('No Hue bridges found');
    }
    print("Found ${bridges.length} Hue bridges.");

    // Use the first discovered bridge
    String bridgeIp = bridges.first.ipAddress;
    print("Using bridge at IP: $bridgeIp");

    // Need to press the hue button within 30 seconds.
    final DiscoveryTimeoutController controller = DiscoveryTimeoutController(
      timeoutSeconds: 30,
    );

    // Attempt to connect to the bridge using the discovered IP address
    print("Attempting to connect to bridge...");
    Bridge? bridge = await BridgeDiscoveryRepo.firstContact(
      bridgeIpAddr: bridgeIp,
      controller: controller,
    );

    if (bridge == null) {
      throw Exception('Failed to connect to Hue bridge');
    }
    print("Connected to bridge at IP: $bridgeIp");

    // Create a HueNetwork instance with the discovered bridge
    print("Creating HueNetwork instance...");
    HueNetwork network = HueNetwork(bridges: [bridge]);
    print("HueNetwork instance created.");
    print("Fetching all data from the network...");
    await network.fetchAll();
    print("Data fetched successfully.");

    _instance = HueActions._(network);
    return _instance!;
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
      await network.put();
    } catch (e) {
      throw Exception('Failed to set light state: $e');
    }
  }

  Future<void> setLightColor(Light light, Color color) async {
    try {
      ColorXy colorXy = color.toColorXy();
      light = light.copyWith(
        color: light.color.copyWith(xy: LightColorXy(
          x: colorXy.x,
          y: colorXy.y,
        )),
      );
      await network.bridges.first.put(light);
    } catch (e) {
      throw Exception('Failed to set light color: $e');
    }
  }
}
