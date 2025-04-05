import 'dart:ui';

import 'package:flutter_hue/flutter_hue.dart';

class HueActions {
  final HueNetwork network;
  static HueActions? _instance;

  HueActions._(this.network);

  factory HueActions.getInstance() {
    if (_instance == null) {
      throw Exception('HueActions must be initialized with create() first');
    }
    return _instance!;
  }

  static Future<HueActions> create({bool forceRediscovery = false}) async {
    if (_instance != null && !forceRediscovery) return _instance!;

    List<Bridge> savedBridges = await BridgeDiscoveryRepo.fetchSavedBridges();
    Bridge? bridge;

    // Try to use saved bridges first
    if (savedBridges.isNotEmpty && !forceRediscovery) {
      print("Using saved bridge: ${savedBridges.first.ipAddress}");
      bridge = savedBridges.first;
    } else {
      // Discover new bridges if no saved ones found
      print("Discovering new bridges...");
      final bridges = await BridgeDiscoveryRepo.discoverBridges(
        writeToLocal: true,
      );
      if (bridges.isEmpty) throw Exception('No Hue bridges found');

      final controller = DiscoveryTimeoutController(timeoutSeconds: 30);
      final bridgeIp = bridges.first.ipAddress;

      print("Attempting connection to $bridgeIp");
      bridge = await BridgeDiscoveryRepo.firstContact(
        bridgeIpAddr: bridgeIp,
        controller: controller,
      );

      if (bridge == null) throw Exception('Failed to connect to bridge');
    }

    final network = HueNetwork(bridges: [bridge!]);
    await network.fetchAll();

    return _instance = HueActions._(network);
  }

  Future<void> refreshNetwork() async {
    try {
      await network.fetchAll();
    } catch (e) {
      throw Exception('Network refresh failed: $e');
    }
  }

  Future<List<Light>> getLights({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) await refreshNetwork();
      return network.lights;
    } catch (e) {
      throw Exception('Failed to fetch lights: $e');
    }
  }

  Future<void> updateLightState(Light light, {bool? on, Color? color}) async {
    try {
      Light updatedLight = light;

      if (on != null) {
        updatedLight = updatedLight.copyWith(
          on: updatedLight.on.copyWith(isOn: on),
        );
      }

      if (color != null) {
        final colorXy = color.toColorXy();
        updatedLight = updatedLight.copyWith(
          color: updatedLight.color.copyWith(
            xy: LightColorXy(x: colorXy.x, y: colorXy.y),
          ),
        );
      }

      await network.bridges.first.put(updatedLight);
      await refreshNetwork();
    } catch (e) {
      throw Exception('Light update failed: $e');
    }
  }
}
