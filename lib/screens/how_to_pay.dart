import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:minsk8/import.dart';

class HowToPayScreen extends StatelessWidget {
  Route<T> getRoute<T>() {
    return buildRoute<T>(
      '/how_to_pay',
      builder: (_) => this,
      fullscreenDialog: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _BigLogo(),
                _Title(),
                _Menu(),
              ],
            ),
          ),
          FlatButton(
            onLongPress: () {}, // чтобы сократить время для splashColor
            onPressed: () {
              navigator.push(
                ContentScreen('how_it_works.md').getRoute(),
              );
            },
            child: Text(
              'КАК ЭТО РАБОТАЕТ?',
              style: TextStyle(
                fontSize: kFontSize,
                color: Colors.black.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
    return Scaffold(
      appBar: ExtendedAppBar(
        withModel: true,
      ),
      body: SafeArea(
        child: ScrollBody(child: child),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: 16,
        ),
        Text(
          'Повысить Карму',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black.withOpacity(0.8),
          ),
        ),
        SizedBox(
          height: 8,
        ),
        Text(
          'чтобы забирать нужные вещи',
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 16,
        ),
      ],
    );
  }
}

class _BigLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final height = 150.0;
    final width = 200.0;
    return SizedBox(
      height: height,
      width: width,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: height / 2 - kLogoSize / 2 + 10,
            left: width / 2 - kLogoSize / 2,
            child: Logo(),
          ),
          Positioned(
            bottom: 0,
            left: 20,
            child: Transform.rotate(
              angle: -.4,
              child: Icon(
                FontAwesomeIcons.cat,
                color: Colors.deepOrangeAccent,
                size: kLogoSize / kGoldenRatio,
              ),
            ),
          ),
          Positioned(
            top: 30,
            left: 0,
            child: Transform.rotate(
              angle: -.4,
              child: Icon(
                FontAwesomeIcons.bicycle,
                color: Colors.deepOrangeAccent,
                size: kLogoSize / kGoldenRatio,
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 100,
            child: Transform.rotate(
              angle: .4,
              child: Icon(
                FontAwesomeIcons.chair,
                color: Colors.deepOrangeAccent,
                size: kLogoSize / kGoldenRatio,
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 0,
            child: Transform.rotate(
              angle: -.4,
              child: Icon(
                FontAwesomeIcons.mobileAlt,
                color: Colors.deepOrangeAccent,
                size: kLogoSize / kGoldenRatio,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 20,
            child: Transform.rotate(
              angle: -.4,
              child: Icon(
                FontAwesomeIcons.wineBottle,
                color: Colors.deepOrangeAccent,
                size: kLogoSize / kGoldenRatio,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Menu extends StatelessWidget {
  final _menu = {
    'add_unit': ['ОТДАЙТЕ ЛИШНИЕ ВЕЩИ', 'Получите за них Карму от забирающих'],
    'invite': ['ПРИГЛАСИТЕ ДРУЗЕЙ', 'Получите Карму за новых участников'],
    'payment': ['ПОЛУЧИТЕ КАРМУ БЫСТРО', 'Поддержите развитие проекта'],
  }.entries.toList();

  @override
  Widget build(BuildContext context) {
    return ListBox(
      itemCount: _menu.length,
      itemBuilder: (BuildContext context, int index) {
        final entry = _menu[index];
        final isLast = index == _menu.length - 1;
        return Material(
          color: isLast ? Colors.green : Colors.white,
          child: InkWell(
            onLongPress: () {}, // чтобы сократить время для splashColor
            onTap: () async {
              if (entry.key == 'add_unit') {
                try {
                  final kind = await navigator.push<KindValue>(
                    KindsScreen().getRoute(),
                  ); // as KindValue; // workaround for typecast
                  if (kind == null) return;
                  await navigator.push(
                    AddUnitScreen(
                      kind: kind,
                      tabIndex: AddUnitTabIndex(),
                    ).getRoute(),
                  );
                } finally {
                  navigator.pop();
                }
                return;
              }
              final routes = {
                'invite': () => InviteScreen().getRoute(),
                'payment': () => PaymentScreen().getRoute(),
              };
              // ignore: unawaited_futures
              navigator.pushReplacement(routes[entry.key]());
            },
            child: ListTile(
              dense: true,
              title: isLast
                  ? Text(
                      entry.value[0],
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    )
                  : Text(entry.value[0]),
              subtitle: isLast
                  ? Text(
                      entry.value[1],
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    )
                  : Text(entry.value[1]),
              trailing: Icon(
                Icons.navigate_next,
                color: isLast ? Colors.white : Colors.black.withOpacity(0.3),
                size: kButtonIconSize,
              ),
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return SizedBox(height: 8);
      },
    );
  }
}
