class EntryCounter {
  final List<bool> _entries;

  int _addedEntriesCount = 0;

  EntryCounter._(this._entries);

  bool get hasEntries => _addedEntriesCount > 0;

  factory EntryCounter.from(int count) {
    final entries = List<bool>();
    for (var i = 0; i < count; i++) {
      entries.add(false);
    }
    return EntryCounter._(entries);
  }

  void addEntry(int index) {
    if (_entries[index] == false) {
      _entries[index] = true;
      _addedEntriesCount++;
    }
  }

  void removeEntry(int index) {
    if (_entries[index] == true) {
      _entries[index] = false;
      _addedEntriesCount--;
    }
  }
}
