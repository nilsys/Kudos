import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kudosapp/models/entry_counter.dart';
import 'package:kudosapp/models/item_change.dart';
import 'package:kudosapp/models/item_change_type.dart';
import 'package:mutex/mutex.dart';

abstract class CachedDataService<TDto, TModel> {
  final int _inputStreamsCount;
  final _itemCounts = new Map<String, EntryCounter>();
  final List<StreamSubscription> _streamSubscriptions;
  final _dataStreamUpdatedMutex = Mutex();

  @protected
  final cachedData = new Map<String, TModel>();

  bool _dataLoaded = false;

  CachedDataService(this._inputStreamsCount)
      : _streamSubscriptions = new List(_inputStreamsCount);

  void _onDataStreamUpdated(
    Iterable<ItemChange<TDto>> dataChanges,
    int streamId,
  ) async {
    await _dataStreamUpdatedMutex.protect(
      () {
        for (var achievementChange in dataChanges) {
          var model = convert(achievementChange.item);

          switch (achievementChange.changeType) {
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
      },
    );
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
      _itemCounts[key] = new EntryCounter(_inputStreamsCount);
    }
    _itemCounts[key].addEntry(streamIndex);
    cachedData[key] = item;
  }

  void _updateSubscriptions() {
    for (int i = 0; i < _inputStreamsCount; i++) {
      if (_streamSubscriptions[i] == null) {
        _streamSubscriptions[i] =
            getInputStream(i).listen((data) => _onDataStreamUpdated(data, 0));
      }
    }
  }

  @protected
  Future<void> loadData() async {
    _updateSubscriptions();

    if (!_dataLoaded) {
      for (int i = 0; i < _inputStreamsCount; i++) {
        var data = await getDataFromInputStream(i);
        for (var item in data) {
          _incrementItemCount(convert(item), 0);
        }
      }
      _dataLoaded = true;
    }
  }

  @protected
  TModel convert(TDto item);

  @protected
  String getItemId(TModel item);

  @protected
  Stream<Iterable<ItemChange<TDto>>> getInputStream(int index);

  @protected
  Future<Iterable<TDto>> getDataFromInputStream(int index);

  void closeSubscriptions() {
    _dataLoaded = false;

    for (int i = 0; i < _inputStreamsCount; i++) {
      _streamSubscriptions[i]?.cancel();
      _streamSubscriptions[i] = null;
    }
  }
}
