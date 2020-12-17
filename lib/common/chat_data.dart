import 'package:graphql/client.dart';
import 'package:minsk8/import.dart';

class ChatData extends SourceList<ChatModel> {
  // ChatData(GraphQLClient client) : super(client);

  @override
  QueryOptions get options {
    // final variables = {'next_date': nextDate};
    return QueryOptions(
      document: addFragments(Queries.getChats),
      // variables: variables,
      fetchPolicy: FetchPolicy.noCache,
    );
  }

  @override
  List<ChatModel> getItems(Map<String, dynamic> data) {
    final dataItems = <Map<String, dynamic>>[...data['chats']];
    // сначала наполняю буфер items, если есть ошибки в ChatModel.fromJson
    final items = <ChatModel>[];
    hasMore = false;
    // final hasMore = dataItems.length == kGraphQLUnitsLimit;
    // this.hasMore = hasMore;
    // if (hasMore) {
    //   final item = ChatModel.fromJson(dataItems.removeLast());
    //   nextDate = item.updatedAt.toUtc().toIso8601String();
    // }
    for (final dataItem in dataItems) {
      items.add(ChatModel.fromJson(dataItem));
    }
    return items;
  }
}
