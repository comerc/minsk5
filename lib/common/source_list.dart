import 'package:graphql/client.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:minsk8/import.dart';

abstract class SourceList<T> extends LoadingMoreBase<T> {
  // SourceList(this.client);

  // final GraphQLClient client;

  static bool _isStart = true;

  bool get isInfinite => true;

  String get startDate => DateTime.now().toUtc().toIso8601String();

  String nextDate;
  bool _hasMore;
  bool _forceRefresh;

  bool _isHandleRefresh = false;
  bool _isLoadDataByTabChange = false;
  bool get isLoadDataByTabChange => _isLoadDataByTabChange;
  void resetIsLoadDataByTabChange() {
    _isLoadDataByTabChange = false;
  }

  QueryOptions get options; // abstract

  @override
  bool get hasMore => _forceRefresh || _hasMore && (isInfinite || length < 40);

  set hasMore(bool value) {
    _hasMore = value;
  }

  List<T> getItems(Map<String, dynamic> data); // abstract

  @override
  Future<bool> refresh([bool clearBeforeRequest = false]) async {
    nextDate = startDate;
    _hasMore = true;
    //force to refresh list when you don't want clear list before request
    //for the case, if your list already has 20 units.
    _forceRefresh = !clearBeforeRequest;
    final result = await super.refresh(clearBeforeRequest);
    _forceRefresh = false;
    return result;
  }

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    var clearAfterRequest = false;
    if (_isHandleRefresh) {
      _isHandleRefresh = false;
      clearAfterRequest = true;
    } else if (_isStart) {
      _isStart = false;
    } else if (!isLoadMoreAction) {
      // отсек флагами все другие случаи,
      // это флаг включается при смене таба
      _isLoadDataByTabChange = true;
    }
    assert(nextDate != null);
    var isSuccess = false;
    try {
      // TODO: may be WatchQueryOptions?
      // to show loading more clearly, in your app,remove this
      if (!clearAfterRequest) {
        await Future.delayed(Duration(milliseconds: 400));
      }
      final result =
          await client.query(options).timeout(kGraphQLQueryTimeoutDuration);
      if (result.hasException) {
        throw result.exception;
      }
      final items = getItems(result.data);
      if (length > 0 && clearAfterRequest) {
        // TODO: как отменить IndicatorStatus.loadingMoreBusying?
        // indicatorStatus = IndicatorStatus.none;
        clear();
        onStateChanged(this);
        // TODO: по аналогии с JS, как в Dart реализуется SetTimeout(0) для event loop?
        await Future.delayed(Duration(milliseconds: 400));
      }
      addAll(items);
      isSuccess = true;
    } catch (error) {
      hasMore = false;
      // TODO: показывать сообщение пользователю;
      // беда в том, что тут IndicatorStatus.none
      out(error);
    }
    return isSuccess;
  }

  Future<bool> handleRefresh() async {
    _isHandleRefresh = true;
    return refresh();
  }
}
