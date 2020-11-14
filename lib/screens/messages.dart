import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:minsk8/import.dart';

class MessagesScreen extends StatefulWidget {
  Route<T> getRoute<T>() {
    return buildRoute<T>(
      '/messages',
      builder: (_) => this,
    );
  }

  MessagesScreen({this.chat});

  final ChatModel chat;

  @override
  _MessagesScreenState createState() {
    return _MessagesScreenState();
  }
}

class _MessagesScreenState extends State<MessagesScreen> {
  TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chat = widget.chat;
    final unit = chat.unit;
    final avatar = Avatar(unit.avatarUrl);

    // final memberId = getMemberId(context);
    // final chat = widget.chat;
    // final                     (chat.unit.member.id == memberId
    //                         ? item.unitOwnerReadCount
    //                         : item.companionReadCount);

    final companion = chat.companion;
    final child = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: CustomScrollView(
            // anchor: 0.5,
            reverse: true,
            // floatHeaderSlivers: true,
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildListDelegate(
                  List.generate(
                    3,
                    (index) => Container(
                      height: 100,
                      color: Colors.lightBlue[100 * (index % 9)],
                      child: Text('$index'),
                    ),
                  ),
                ),
              ),
              // TODO: прикреплять блок сверху
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Договоритесь о встрече',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black.withOpacity(0.8),
                        ),
                      ),
                      SizedBox(height: 8),
                      Divider(),
                      // TODO: [MVP] переход на страницу участника
                      ListTile(
                        leading: Avatar(companion.avatarUrl),
                        title: Text(companion.displayName),
                        subtitle: Text(
                          DateFormat.yMMMMd('ru_RU').format(
                            companion.lastActivityAt,
                          ),
                        ), // TODO: [MVP] 'Был 8 часов назад'
                        // dense: true,
                      ),
                      Divider(),
                      SizedBox(height: 8),
                      Content('make_an_appointment.md'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1),
        Container(
          color: Colors.white,
          // child: Text(widget.chat.unit.id),
          child: TextField(
            enableSuggestions: false,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            controller: _textController,
            // focusNode: _textFocusNode,
            decoration: InputDecoration(
              hintText: 'Напишите сообщение...',
              contentPadding: EdgeInsets.all(16),
              // TODO: Vertical Alignment https://github.com/flutter/flutter/issues/42651
              suffixIcon: ClipRRect(
                borderRadius: BorderRadius.circular(kDefaultIconSize),
                child: Material(
                  color: Colors.white,
                  child: InkWell(
                    // TODO: в телеге onLongPress > menu > "отправить позже", "отправить без звука"
                    onLongPress:
                        () {}, // без этой заглушки показывает системное меню "paste"
                    onTap: () {},
                    child: Icon(
                      Icons.send,
                      size: kDefaultIconSize,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
    return Scaffold(
      appBar: ExtendedAppBar(
        title: Tooltip(
          message: 'Go To Unit',
          // TODO: отсутствует InkWell - что с этим делать?
          child: GestureDetector(
            onTap: () {
              navigator.push(
                UnitScreen(
                  unit,
                  member: unit.member,
                ).getRoute(),
              );
            },
            child: Row(
              children: <Widget>[
                avatar,
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    unit.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: kButtonFontSize,
                      fontWeight: FontWeight.normal,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (String value) async {
              if (value == 'complaint') {
                final memberId = getMemberId(context);
                if (unit.member.id != memberId) {
                  launchFeedback(
                    subject:
                        'Жалоба на отдающего transactionId=${chat.transactionId}',
                    body: 'Здравствуйте! Столкнулся с проблемой ',
                  );
                  return;
                }
                final myBlocks =
                    Provider.of<MyBlocksModel>(context, listen: false);
                final isBlocked = myBlocks.has(unit.win.member.id);
                // ignore: unawaited_futures
                showDialog<String>(
                  context: context,
                  child: _BlockDialog(isBlocked: isBlocked),
                ).then((String value) {
                  if (value == null) return;
                  final cases = {
                    'block': () {
                      _optimisticUpdateBlock(
                        myBlocks,
                        member: unit.win.member,
                        value: true,
                      );
                    },
                    'unblock': () {
                      _optimisticUpdateBlock(
                        myBlocks,
                        member: unit.win.member,
                        value: false,
                      );
                    },
                    'feedback': () {
                      launchFeedback(
                        subject:
                            'Жалоба на победителя transactionId=${chat.transactionId}',
                        body: 'Здравствуйте! Столкнулся с проблемой ',
                      );
                    },
                  };
                  cases[value]();
                });
              }
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                PopupMenuItem(
                  value: 'complaint',
                  child: Row(
                    children: <Widget>[
                      Icon(
                        FontAwesomeIcons.flag,
                        size: kBigButtonIconSize,
                        color: Colors.red,
                      ),
                      SizedBox(width: 8),
                      Text('ПОЖАЛОВАТЬСЯ'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: SafeArea(
        child: child,
      ),
    );
  }
}

Future<void> _queueUpdateBlock = Future.value();

void _optimisticUpdateBlock(MyBlocksModel myBlocks,
    {MemberModel member, bool value}) {
  final oldUpdatedAt = myBlocks.updateBlock(
    memberId: member.id,
    value: value,
  );
  // final client = GraphQLProvider.of(context).value;
  final options = MutationOptions(
    documentNode: Mutations.upsertBlock,
    variables: {
      'member_id': member.id,
      'value': value,
    },
    fetchPolicy: FetchPolicy.noCache,
  );
  _queueUpdateBlock = _queueUpdateBlock.then((_) {
    return client
        .mutate(options)
        .timeout(kGraphQLMutationTimeoutDuration)
        .then((QueryResult result) {
      if (result.hasException) {
        throw result.exception;
      }
      final json = result.data['insert_block_one'];
      myBlocks.updateBlock(
        memberId: member.id,
        value: value,
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
    });
  }).catchError((error) {
    out(error);
    myBlocks.updateBlock(
      memberId: member.id,
      value: oldUpdatedAt != null,
      updatedAt: oldUpdatedAt,
    );
    BotToast.showNotification(
      title: (_) => Text(
        value
            ? 'Не удалось заблокировать "${member.displayName}"'
            : 'Не удалось разблокировать "${member.displayName}"',
        overflow: TextOverflow.fade,
        softWrap: false,
      ),
      trailing: (Function close) => FlatButton(
        onLongPress: () {}, // чтобы сократить время для splashColor
        onPressed: () {
          close();
          _optimisticUpdateBlock(myBlocks, member: member, value: value);
        },
        child: Text(
          'ПОВТОРИТЬ',
          style: TextStyle(
            fontSize: kFontSize,
            color: Colors.black.withOpacity(0.6),
          ),
        ),
      ),
    );
  });
}

// class BlockDialog extends StatefulWidget {
//   @override
//   BlockDialogState createState() {
//     return BlockDialogState();
//   }
// }

// class BlockDialogState extends State<BlockDialog> {
//   @override
//   void initState() {
//     super.initState();
//     analytics.setCurrentScreen(screenName: '/block_dialog');
//   }
class _BlockDialog extends StatelessWidget {
  _BlockDialog({this.isBlocked});

  final bool isBlocked;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: <Widget>[
        Container(
          constraints: BoxConstraints(
            maxWidth: 200,
          ),
          child: Text(
            'Если победитель повёл себя некорректно\u00A0— заблокируйте его, чтобы он больше не\u00A0мог делать ставки на\u00A0Ваши\u00A0лоты. В\u00A0случае крайней необходимости\u00A0— напишите в\u00A0службу\u00A0поддержки.',
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          height: 8,
        ),
        FlatButton(
          onLongPress: () {}, // чтобы сократить время для splashColor
          onPressed: () {
            navigator.pop(isBlocked ? 'unblock' : 'block');
          },
          color: Colors.green,
          textColor: Colors.white,
          child: Text(isBlocked
              ? 'Разблокировать участника'
              : 'Заблокировать участника'),
        ),
        OutlineButton(
          onLongPress: () {}, // чтобы сократить время для splashColor
          onPressed: () {
            navigator.pop('feedback');
          },
          textColor: Colors.green,
          child: Text('Написать в поддержку'),
        ),
      ],
    );
  }
}
