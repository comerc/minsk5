import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:minsk8/import.dart';

class PlacesAppBar extends StatefulWidget implements PreferredSizeWidget {
  PlacesAppBar() : preferredSize = Size.fromHeight(kToolbarHeight);

  @override
  final Size preferredSize;

  @override
  PlacesAppBarState createState() {
    return PlacesAppBarState();
  }
}

class PlacesAppBarState extends State<PlacesAppBar> {
  bool _isPlaces = false;
  final _formFieldKey = GlobalKey<FormFieldState>();

  @override
  Widget build(context) {
    return _isPlaces
        ? AppBar(
            backgroundColor: Colors.white,
            leading: IconButton(
              tooltip: 'Назад',
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black.withOpacity(0.8),
              ),
              onPressed: () {
                setState(() {
                  _isPlaces = false;
                });
              },
            ),
            title: Places(
                formFieldKey: _formFieldKey,
                onSuggestionSelected: _onSuggestionSelected),
            actions: [
              IconButton(
                tooltip: 'Отменить',
                icon: Icon(
                  Icons.close,
                  color: Colors.black.withOpacity(0.8),
                ),
                onPressed: () {
                  _formFieldKey.currentState.reset();
                },
              )
            ],
          )
        : AppBar(
            title: Text('Местоположение'),
            actions: [
              IconButton(
                tooltip: 'Искать',
                icon: Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    _isPlaces = true;
                  });
                },
              ),
            ],
          );
  }

  _onSuggestionSelected(suggestion) {
    // TODO: неверно рисует радиус при переходе после поиска 'qwer'
    mapKey.currentState.animatedMapMove(
      destCenter: LatLng(
        suggestion['_geoloc']['lat'],
        suggestion['_geoloc']['lng'],
      ),
      destZoom: 13,
    );
    setState(() {
      _isPlaces = false;
    });
  }
}