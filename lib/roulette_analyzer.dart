import 'dart:io';
import 'dart:math';
import 'package:path_provider/path_provider.dart';

class RouletteAnalyzer {
  List<int> history = [];
  Set<int> allNumbers = Set<int>.from(List<int>.generate(37, (i) => i));
  static const String _historyFileName = 'history.txt';

  RouletteAnalyzer() {
    _loadHistory();
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_historyFileName');
  }

  Future<void> _loadHistory() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        List<String> lines = await file.readAsLines();
        history = lines.map(int.parse).toList();
      }
    } catch (e) {
      // Error reading file, history remains empty
      print("Error loading history: $e");
    }
  }

  Future<void> _saveHistory() async {
    try {
      final file = await _localFile;
      await file.writeAsString(history.map((e) => e.toString()).join("\n"));
    } catch (e) {
      print("Error saving history: $e");
    }
  }

  Future<void> addNumber(int number) async {
    if (number >= 0 && number <= 36) {
      history.add(number);
      await _saveHistory();
    } else {
      print("Invalid number. Please enter a number between 0 and 36.");
    }
  }

  List<int> getPredictions() {
    List<int> predictions = [0];
    List<List<int>> streets = [
      [1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12],
      [13, 14, 15], [16, 17, 18], [19, 20, 21], [22, 23, 24],
      [25, 26, 27], [28, 29, 30], [31, 32, 33], [34, 35, 36]
    ];
    Map<int, int> counts = {for (var num in allNumbers) num: 0};
    for (var num in history) {
      if (counts.containsKey(num)) {
        counts[num] = (counts[num] ?? 0) + 1;
      }
    }
    for (var street in streets) {
      // Sort numbers in the street by frequency (coldest first)
      List<int> sortedStreet = List<int>.from(street);
      sortedStreet.sort((a, b) => counts[a]!.compareTo(counts[b]!));
      // Add the two coldest numbers from the street to predictions
      predictions.addAll(sortedStreet.sublist(0, min(2, sortedStreet.length)));
    }
    // Ensure predictions list has exactly 25 unique numbers
    // This handles cases where history is very short or some streets are empty
    Set<int> uniquePredictions = predictions.toSet();
    if (uniquePredictions.length < 25) {
      List<int> remainingNumbers = List<int>.from(allNumbers.difference(uniquePredictions));
      remainingNumbers.sort((a, b) => counts[a]!.compareTo(counts[b]!)); // Add coldest remaining numbers
      uniquePredictions.addAll(remainingNumbers.sublist(0, min(25 - uniquePredictions.length, remainingNumbers.length)));
    }
        return uniquePredictions.take(25).toList();
  }

  Future<void> resetHistory() async {
    history.clear();
    final file = await _localFile;
    if (await file.exists()) {
      await file.delete();
    }
  }
}
