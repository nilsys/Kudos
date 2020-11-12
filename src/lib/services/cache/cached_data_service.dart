import 'dart:async';

import 'package:kudosapp/services/cache/entry_counter.dart';
import 'package:kudosapp/services/cache/item_change.dart';
import 'package:kudosapp/services/cache/item_change_type.dart';
import 'package:semaphore/semaphore.dart';

abstract class CachedDataService<TDto, TModel> {
  final int _inputStreamsCount;
  final List<StreamSubscription> _streamSubscriptions;
  final _itemCounts = Map<String, EntryCounter>();
  final _semaphore = LocalSemaphore(1);
  bool _dataLoaded = false;

  final Map<String, TModel> cachedData = Map<String, TModel>();

  CachedDataService(this._inputStreamsCount)
      : _streamSubscriptions = List(_inputStreamsCount);

  void _onDataStreamUpdated(
    Iterable<ItemChange<TDto>> dataChanges,
    int streamId,
  ) async {
    await _semaphore.acquire();

    for (var change in dataChanges) {
      var model = convert(change.item);

      switch (change.changeType) {
        case ItemChangeType.remove:
          _decrementItemCount(model, streamId);
          break;
        case ItemChangeType.add:
          _incrementItemCount(model, streamId);
          break;
        case ItemChangeType.change:
        default:
          cachedData[getItemId(model)] = model;
          break;
      }
    }

    _semaphore.release();
  }

  void _decrementItemCount(
    TModel item,
    int streamIndex,
  ) {
    var key = getItemId(item);
    if (_itemCounts.containsKey(key)) {
      _itemCounts[key].removeEntry(streamIndex);
    }

    if (_itemCounts[key] == null || !_itemCounts[key].hasEntries) {
      cachedData.remove(key);
    }
  }

  void _incrementItemCount(
    TModel item,
    int streamIndex,
  ) {
    var key = getItemId(item);
    if (!_itemCounts.containsKey(key)) {
      _itemCounts[key] = EntryCounter.from(_inputStreamsCount);
    }
    _itemCounts[key].addEntry(streamIndex);
    cachedData[key] = item;
  }

  void _updateSubscriptions() {
    for (int i = 0; i < _inputStreamsCount; i++) {
      if (_streamSubscriptions[i] == null) {
        _streamSubscriptions[i] =
            getInputStream(i).listen((data) => _onDataStreamUpdated(data, i));
      }
    }
  }

  Future<void> loadData() async {
    _updateSubscriptions();

    if (!_dataLoaded) {
      for (int i = 0; i < _inputStreamsCount; i++) {
        var data = await getDataFromInputStream(i);
        for (var item in data) {
          _incrementItemCount(convert(item), i);
        }
      }
      _dataLoaded = true;
    }
  }

  TModel convert(TDto item);

  String getItemId(TModel item);

  Stream<Iterable<ItemChange<TDto>>> getInputStream(int index);

  Future<Iterable<TDto>> getDataFromInputStream(int index);

  void closeSubscriptions() {
    _dataLoaded = false;

    for (int i = 0; i < _inputStreamsCount; i++) {
      _streamSubscriptions[i]?.cancel();
      _streamSubscriptions[i] = null;
    }
  }
}
