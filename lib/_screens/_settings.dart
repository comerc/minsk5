import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:minsk8/import.dart';

// TODO: теги https://github.com/Dn-a/flutter_tags

class SettingsScreen extends StatefulWidget {
  Route<T> getRoute<T>() {
    return buildRoute<T>(
      '/settings',
      builder: (_) => this,
      fullscreenDialog: true,
    );
  }

  @override
  _SettingsScreenState createState() {
    return _SettingsScreenState();
  }
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final panelChildWidth = size.width - 32.0; // for padding
    final child = Column(
      children: <Widget>[
        SizedBox(height: 16),
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Местоположение лотов',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(0.8),
            ),
          ),
        ),
        SizedBox(height: 8),
        Container(
          constraints: BoxConstraints(minHeight: 40),
          child: SelectButton(
            tooltip: 'Местоположение',
            text:
                "${appState['ShowcaseMap.address']} — ${appState['ShowcaseMap.radius']} км",
            onTap: _selectLocation,
          ),
        ),
        Spacer(),
        SizedBox(
          height: kBigButtonHeight,
          width: panelChildWidth,
          child: ReadyButton(onTap: _handleOK),
        ),
        SizedBox(
          height: 16,
        ),
      ],
    );
    return Scaffold(
      appBar: ExtendedAppBar(
        title: Text('Настройки'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Подтвердить',
            icon: Icon(Icons.check),
            onPressed: _handleOK,
          ),
        ],
        withModel: true,
      ),
      body: SafeArea(
        child: ScrollBody(child: child),
      ),
    );
  }

  void _selectLocation() {
    navigator.push(ShowcaseMapScreen().getRoute()).then((value) {
      if (value == null) return;
      setState(() {});
    });
  }

  void _handleOK() {
    navigator.pop(true);
  }
}
