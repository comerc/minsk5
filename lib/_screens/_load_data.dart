import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:minsk8/import.dart';

var _hasMore = true;

class LoadDataScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Load Data'),
      ),
      drawer: MainDrawer('/_load_data'),
      body: Center(
        child: Query(
          options: QueryOptions(
            document: addFragments(Queries.getUnits),
            variables: {
              'next_date': '2100-01-01',
            },
          ),
          builder: withGenericHandling(
            (
              QueryResult result, {
              Refetch refetch,
              FetchMore fetchMore,
            }) {
              // if (result.loading) {
              //   return Center(
              //     child: buildProgressIndicator(context),
              //   );
              // }
              // return ListView.separated(
              //   padding: EdgeInsets.all(8),
              //   itemCount: result.data['units'].length,
              //   itemBuilder: (BuildContext context, int index) {
              //     final unit = UnitModel.fromJson(result.data['units'][index]);
              //     return Container(
              //       child: Center(child: Text('${unit.id}\n${unit.text}')),
              //     );
              //   },
              //   separatorBuilder: (BuildContext context, int index) =>
              //       const Divider(),
              // );
              final units = result.data['units'] as List<Map<String, dynamic>>;
              final minusOne = _hasMore ? 1 : 0;
              return Container(
                child: ListView(
                  children: <Widget>[
                    ...List.generate(
                        units.isNotEmpty ? units.length - minusOne : 0,
                        (int index) => _buildUnit(
                            result.loading, UnitModel.fromJson(units[index]))),
                    // for (var index = 0;
                    //     index < units.length - minusOne;
                    //     index++)
                    //   _buildUnit(result.loading,
                    //       UnitModel.fromJson(units[index])),
                    if (result.loading)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          buildProgressIndicator(context),
                        ],
                      ),
                    if (_hasMore)
                      RaisedButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text('Load More'),
                          ],
                        ),
                        onPressed: () {
                          // final client = GraphQLProvider.of(context)?.value;
                          // return GraphQLConsumer(
                          //     builder: (GraphQLClient client) {
                          //       // do something with the client
                          //       return Container(
                          //         child: Text('Hello world'),
                          //       );
                          //     },
                          final nextUnit = UnitModel.fromJson(units.last);
                          fetchMore(
                            FetchMoreOptions(
                              variables: {
                                'next_date':
                                    nextUnit.createdAt.toUtc().toIso8601String()
                              },
                              updateQuery: (
                                previousResultData,
                                fetchMoreResultData,
                              ) {
                                final previousUnits =
                                    previousResultData['units'] as List;
                                previousUnits.removeLast();
                                final fetchMoreUnits =
                                    fetchMoreResultData['units'] as List;
                                _hasMore =
                                    fetchMoreUnits.length == kGraphQLUnitsLimit;
                                return {
                                  'units': [
                                    ...previousUnits,
                                    ...fetchMoreUnits,
                                  ]
                                };
                              },
                            ),
                          );
                        },
                      )
                  ],
                ),
              );

              // return Text('Hello world!');
              // (result.loading)
              //     ? Center(
              //         child: buildProgressIndicator(context),
              //       )
              //     : RaisedButton(
              //         onPressed: () {
              //           fetchMore(
              //             FetchMoreOptions(
              //               variables: {'page': nextPage},
              //               updateQuery: (existing, newReviews) => ({
              //                 'reviews': {
              //                   'page': newReviews['reviews']['page'],
              //                   'reviews': [
              //                     ...existing['reviews']['reviews'],
              //                     ...newReviews['reviews']['reviews']
              //                   ],
              //                 }
              //               }),
              //             ),
              //           );
              //         },
              //         child: Text('LOAD PAGE $nextPage'),
              //       ),
            },
          ),
        ),
      ),
    );
  }

  Widget _buildUnit(bool isLoading, UnitModel unit) {
    // out('$isLoading - ${unit.id}');
    return ListTile(
      title: Text(unit.text),
      subtitle: Text(unit.id),
    );
  }
}

/// boilerplate `result.loading` and `result.hasException` handling
///
/// ```dart
/// if (result.hasException) {
///   return Text(result.exception.toString());
/// }
/// if (result.loading) {
///   return Center(
///     child: CircularProgressIndicator(),
///   );
/// }
/// ```
QueryBuilder withGenericHandling(QueryBuilder builder) {
  return (QueryResult result, {Refetch refetch, FetchMore fetchMore}) {
    if (result.hasException) {
      return Text(result.exception.toString());
    }
    if (result.source == QueryResultSource.loading && result.data == null) {
      return Center(
        child: CircularProgressIndicator(), // buildProgressIndicator(context),
      );
    }
    if (result.data == null && !result.hasException) {
      return Text(
          'Both data and errors are null, this is a known bug after refactoring');
    }
    return builder(result, fetchMore: fetchMore, refetch: refetch);
  };
}
