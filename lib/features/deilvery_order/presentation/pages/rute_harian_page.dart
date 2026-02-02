import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/do_provider.dart';

class RuteHarianPage extends StatefulWidget {
  final String token;

  const RuteHarianPage({super.key, required this.token});

  @override
  State<RuteHarianPage> createState() => _RuteHarianPageState();
}

class _RuteHarianPageState extends State<RuteHarianPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DoProvider>().fetchTodayTracking(token: widget.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rute Harian'),
        backgroundColor: const Color(0xFFFFB703),
      ),
      body: Consumer<DoProvider>(
        builder: (context, doProvider, child) {
          if (doProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (doProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${doProvider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      doProvider.fetchTodayTracking(token: widget.token);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final trackingList = doProvider.trackingList;

          if (trackingList.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Tidak ada data tracking hari ini'),
                ],
              ),
            );
          }

          // Calculate center point from all tracking locations
          double centerLat = 0;
          double centerLong = 0;
          for (var tracking in trackingList) {
            centerLat += tracking.lat;
            centerLong += tracking.long;
          }
          centerLat /= trackingList.length;
          centerLong /= trackingList.length;

          return FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(centerLat, centerLong),
              initialZoom: 12.0,
              maxZoom: 18.0,
              minZoom: 5.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.bbs_driver',
              ),
              MarkerLayer(
                markers: trackingList.map((tracking) {
                  return Marker(
                    point: LatLng(tracking.lat, tracking.long),
                    child: Container(
                      decoration: BoxDecoration(
                        color: tracking.isCompleted
                            ? Colors.green
                            : Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
