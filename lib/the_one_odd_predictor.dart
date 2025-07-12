import 'package:flutter/material.dart';

class TheOneOddPredictor extends StatelessWidget {
  final List<int> history;

  const TheOneOddPredictor({Key? key, required this.history}) : super(key: key);

  // Helper to get roulette number color
  String _getRouletteNumberColor(int number) {
    if (number == 0) {
      return 'Green';
    } else if ([1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36].contains(number)) {
      return 'Red';
    } else {
      return 'Black';
    }
  }

  // Helper to determine if number is 1-18 or 19-36
  String _getHighLow(int number) {
    if (number == 0) {
      return 'Zero';
    } else if (number >= 1 && number <= 18) {
      return '1-18';
    } else {
      return '19-36';
    }
  }

  // Helper to determine if number is Odd or Even
  String _getOddEven(int number) {
    if (number == 0) {
      return 'Zero';
    } else if (number % 2 == 0) {
      return 'Even';
    } else {
      return 'Odd';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate predictions based on history
    Map<String, int> colorCounts = {};
    Map<String, int> highLowCounts = {};
    Map<String, int> oddEvenCounts = {};

    for (int number in history) {
      String color = _getRouletteNumberColor(number);
      colorCounts[color] = (colorCounts[color] ?? 0) + 1;

      String highLow = _getHighLow(number);
      highLowCounts[highLow] = (highLowCounts[highLow] ?? 0) + 1;

      String oddEven = _getOddEven(number);
      oddEvenCounts[oddEven] = (oddEvenCounts[oddEven] ?? 0) + 1;
    }

    // Get most frequent for each category
    String mostFrequentColor = colorCounts.entries.fold('', (prev, e) => e.value > (colorCounts[prev] ?? 0) ? e.key : prev);
    String mostFrequentHighLow = highLowCounts.entries.fold('', (prev, e) => e.value > (highLowCounts[prev] ?? 0) ? e.key : prev);
    String mostFrequentOddEven = oddEvenCounts.entries.fold('', (prev, e) => e.value > (oddEvenCounts[prev] ?? 0) ? e.key : prev);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [ // ✅ Add `const` here
        Text('Colour Prediction: $mostFrequentColor', style: TextStyle(fontSize: 16)),
        Text('1-18/19-36 Prediction: $mostFrequentHighLow', style: TextStyle(fontSize: 16)),
        Text('Odd/Even Prediction: $mostFrequentOddEven', style: TextStyle(fontSize: 16)),
      ],
    );
  }
}
