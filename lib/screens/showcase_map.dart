import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:minsk8/import.dart';

class ShowcaseMapScreen extends StatelessWidget {
  Route<T> getRoute<T>() {
    return buildRoute<T>(
      '/showcase_map',
      builder: (_) => this,
      fullscreenDialog: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = MapWidget(
      center: LatLng(
        appState['ShowcaseMap.center'][0] as double,
        appState['ShowcaseMap.center'][1] as double,
      ),
      zoom: appState['ShowcaseMap.zoom'] as double,
      saveModes: <MapSaveMode>[MapSaveMode.showcase],
    );
    return Scaffold(
      appBar: PlacesAppBar(),
      body: SafeArea(child: body),
      resizeToAvoidBottomInset: false,
    );
  }
}
