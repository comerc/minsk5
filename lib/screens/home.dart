import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong/latlong.dart';

// import '../widgets/drawer.dart';

class Home extends StatelessWidget {
  static const String route = '/';

  @override
  Widget build(BuildContext context) {
    var markers = <Marker>[
      Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(51.5, -0.09),
        builder: (ctx) => Container(
          child: FlutterLogo(
            colors: Colors.blue,
            key: ObjectKey(Colors.blue),
          ),
        ),
      ),
      Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(53.3498, -6.2603),
        builder: (ctx) => Container(
          child: FlutterLogo(
            colors: Colors.green,
            key: ObjectKey(Colors.green),
          ),
        ),
      ),
      Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(48.8566, 2.3522),
        builder: (ctx) => Container(
          child: FlutterLogo(
            colors: Colors.purple,
            key: ObjectKey(Colors.purple),
          ),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      // drawer: buildDrawer(context, route),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(53.9, 27.56667),
          zoom: 8.0,
          minZoom: 4.0,
          plugins: [
            AreaPlugin(),
          ],
        ),
        layers: [
          TileLayerOptions(
            urlTemplate: 'https://tilessputnik.ru/{z}/{x}/{y}.png',
            tileProvider: CachedNetworkTileProvider(),
          ),
          MarkerLayerOptions(markers: markers),
          AreaPluginOptions(text: "I'm a plugin!"),
        ],
      ),
    );
  }
}

class AreaPluginOptions extends LayerOptions {
  final String text;
  AreaPluginOptions({this.text = ''});
}

class AreaPlugin implements MapPlugin {
  @override
  Widget createLayer(
      LayerOptions options, MapState mapState, Stream<Null> stream) {
    if (options is AreaPluginOptions) {
      return _Area(mapState: mapState);
    }
    throw Exception('Unknown options type for Area'
        'plugin: $options');
  }

  @override
  bool supportsLayer(LayerOptions options) {
    return options is AreaPluginOptions;
  }
}

class _Area extends StatefulWidget {
  final MapState mapState;

  _Area({Key key, this.mapState}) : super(key: key);

  @override
  _AreaState createState() => _AreaState();
}

class _AreaState extends State<_Area> {
  double _value = 0.0;

  @override
  Widget build(BuildContext context) {
    print(widget);
    return Stack(
      children: [
        Center(
          child: CustomPaint(
            painter: _AreaPainter(),
          ),
        ),
        Container(
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.all(8.0),
          child: Container(
            child: Slider(
              value: _value,
              // child: Text('1234'),
              // onPressed: () {},
              // color: Colors.blue,
              onChanged: (value) => setState(() => _value = value),
            ),
            alignment: Alignment.center,
            height: 100.0,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
          ),
        ),
        kReleaseMode
            ? null
            : ButtonBar(
                children: [
                  IconButton(
                    tooltip: 'Increase',
                    iconSize: 32.0,
                    icon: Icon(
                      Icons.zoom_in,
                    ),
                    onPressed: widget.mapState.zoom <
                            (widget.mapState.options.maxZoom ?? 17.0)
                        ? _increaseZoom
                        : null,
                  ),
                  IconButton(
                    tooltip: 'Decrease',
                    iconSize: 32.0,
                    icon: Icon(
                      Icons.zoom_out,
                    ),
                    onPressed: widget.mapState.zoom >
                            (widget.mapState.options.minZoom ?? 0.0)
                        ? _decreaseZoom
                        : null,
                  ),
                ],
              ),
      ].where((child) => child != null).toList(),
    );
  }

  _increaseZoom() {
    final zoom = widget.mapState.zoom + 1;
    widget.mapState.move(widget.mapState.center, zoom);
  }

  _decreaseZoom() {
    final zoom = widget.mapState.zoom - 1;
    widget.mapState.move(widget.mapState.center, zoom);
  }
}

class _AreaPainter extends CustomPainter {
  Paint _paintFill;
  Paint _paintStroke;
  TextPainter _textPainter;

  _AreaPainter() {
    _paintFill = Paint()
      ..color = Colors.blue.withOpacity(0.2)
      ..strokeWidth = 0.0
      ..style = PaintingStyle.fill;
    _paintStroke = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    final icon = Icons.location_on;
    _textPainter = TextPainter(textDirection: TextDirection.rtl);
    _textPainter.text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
            fontSize: 48.0, fontFamily: icon.fontFamily, color: Colors.pink));
    _textPainter.layout();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(0.0, 0.0), 100.0, _paintFill);
    canvas.drawCircle(Offset(0.0, 0.0), 100.0, _paintStroke);
    _textPainter.paint(canvas, Offset(-24.0, -44.0));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
