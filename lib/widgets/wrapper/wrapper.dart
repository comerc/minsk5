import 'package:flutter/material.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart'
    as extended;
import 'package:minsk8/import.dart';

// TODO: RefreshIndicator https://github.com/flutter/flutter/blob/v1.15.22/examples/flutter_gallery/lib/demo/material/overscroll_demo.dart

class Wrapper extends StatefulWidget {
  Wrapper({
    Key key,
    this.tabModels,
    this.dataPool,
    this.buildList,
    this.pullToRefreshNotificationKey,
    this.poolForReloadTabs,
    this.hasAppBar = false,
  }) : super(key: key);

  final List<EnumModel> tabModels;
  final List<SourceList> dataPool;
  final Widget Function(int tabIndex, SourceList sourceList) buildList;
  final GlobalKey<PullToRefreshNotificationState> pullToRefreshNotificationKey;
  final Set<int> poolForReloadTabs;
  final bool hasAppBar;

  @override
  WrapperState createState() => WrapperState();
}

class WrapperState extends State<Wrapper> with SingleTickerProviderStateMixin {
  TabController _tabController;
  int get tabIndex => _tabController.index;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.tabModels.length,
      vsync: this,
    );
    _tabController.addListener(() {
      final sourceList = widget.dataPool[_tabController.index];
      if (!_tabController.indexIsChanging) {
        // print(
        //     'indexIsChanging ${sourceList.isLoadDataByTabChange} ${widget.tabModels[_tabController.index].value}');
        // если для категории еще не было загрузки (переходом по tab-у),
        // то добавление нового unit-а в /add_unit зря добавит tab в widget.poolForReloadTabs,
        // а потому удаление выполняю в любом случае, без оглядки на sourceList.isLoadDataByTabChange
        final isContaintsInPool =
            widget.poolForReloadTabs.remove(_tabController.index);
        if (sourceList.isLoadDataByTabChange) {
          if (_tabController.index > 0) {
            final sourceListBefore = widget.dataPool[_tabController.index - 1];
            sourceListBefore.resetIsLoadDataByTabChange();
          }
          sourceList.resetIsLoadDataByTabChange();
        } else if (isContaintsInPool) {
          // print('pullToRefreshNotificationKey');
          widget.pullToRefreshNotificationKey.currentState.show();
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabBar = TabBar(
      controller: _tabController,
      labelColor: Colors.blue,
      indicatorColor: Colors.blue,
      indicatorSize: TabBarIndicatorSize.label,
      indicatorWeight: 2,
      unselectedLabelColor: Colors.grey,
      isScrollable: true,
      tabs: widget.tabModels
          .map((EnumModel element) => Tab(text: element.name))
          .toList(),
    );
    final tabBarHeight = tabBar.preferredSize.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final pinnedHeaderHeight =
        // pinned statusBar height
        statusBarHeight +
            // pinned SliverAppBar height in header
            // kToolbarHeight +
            // pinned tabbar height in header
            tabBarHeight;
    final child = extended.NestedScrollView(
      floatHeaderSlivers: widget.hasAppBar,
      physics: ClampingScrollPhysics(),
      pinnedHeaderSliverHeightBuilder: () => pinnedHeaderHeight,
      innerScrollPositionKeyBuilder: () => Key('${_tabController.index}'),
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) => [
        if (widget.hasAppBar)
          SliverPersistentHeader(
            delegate: CommonSliverPersistentHeaderDelegate(
              builder: (BuildContext context, double shrinkOffset,
                  bool overlapsContent) {
                return WrapperAppBar();
              },
              height: kToolbarHeight,
            ),
          ),
        PullToRefreshContainer(
          (PullToRefreshScrollNotificationInfo info) {
            return SliverPersistentHeader(
              pinned: true,
              delegate: CommonSliverPersistentHeaderDelegate(
                builder: (BuildContext context, double shrinkOffset,
                    bool overlapsContent) {
                  return WrapperTabBar(
                    info: info,
                    shrinkOffset: shrinkOffset,
                    // overlapsContent: overlapsContent,
                    tabBar: tabBar,
                  );
                },
                height: tabBarHeight,
              ),
            );
          },
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: List.generate(
          widget.tabModels.length,
          (int index) => widget.buildList(index, widget.dataPool[index]),
        ),
      ),
    );
    return PullToRefreshNotification(
      key: widget.pullToRefreshNotificationKey,
      onRefresh: _onRefresh,
      maxDragOffset: kMaxDragOffset,
      child: child,
    );
  }

  Future<bool> _onRefresh() async {
    // print('onRefresh');
    final sourceList = widget.dataPool[_tabController.index];
    final result = await sourceList.handleRefresh();
    if (!result) {
      final snackBar = SnackBar(
          content:
              Text('Не удалось выполнить обновление. Попробуйте ещё раз.'));
      Scaffold.of(context).showSnackBar(snackBar);
    }
    return result;
  }
}