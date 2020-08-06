class EntryCounter {
  final List<bool> _entries;

  int _addedEntriesCount;
  bool get hasEntries => _addedEntriesCount > 0;

  EntryCounter(int count) : _entries = new List<bool>(count);

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
