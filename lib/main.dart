import 'the_one_odd_predictor.dart';
import 'package:flutter/material.dart';
import 'roulette_analyzer.dart';
import 'loading_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roulette Predictor AI by Agien',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: const LoadingScreen(),
    );
  }
}

class RoulettePredictorScreen extends StatefulWidget {
  const RoulettePredictorScreen({super.key});

  @override
State<RoulettePredictorScreen> createState() => _RoulettePredictorScreenState();
}

class _RoulettePredictorScreenState extends State<RoulettePredictorScreen> {
  late RouletteAnalyzer _analyzer;
  List<int> _predictions = [];
  List<int> _history = [];
  String _hitMissStatus = '';
  int _hitCount = 0;
  int _missCount = 0;

  @override
  void initState() {
    super.initState();
    _analyzer = RouletteAnalyzer();
    _initializeAnalyzer();
  }

  Future<void> _initializeAnalyzer() async {
  setState(() {
    _predictions = _analyzer.getPredictions();
    _history = List.from(_analyzer.history);
  });
}

  Future<void> _onNumberPressed(int number) async {
    if (_predictions.isNotEmpty) {
      if (_predictions.contains(number)) {
        _hitMissStatus = 'HIT!';
        _hitCount++;
      } else {
        _hitMissStatus = 'MISS.';
        _missCount++;
      }
    }
    await _analyzer.addNumber(number);
    setState(() {
      _predictions = _analyzer.getPredictions();
      _history = List.from(_analyzer.history);
    });
  }

  Future<void> _resetHistory() async {
    await _analyzer.resetHistory();
    setState(() {
      _history = [];
      _predictions = _analyzer.getPredictions();
      _hitMissStatus = '';
      _hitCount = 0;
      _missCount = 0;
    });
  }

  Color _getRouletteNumberColor(int number) {
    if (number == 0) {
      return Colors.green;
    }
    final redNumbers = {1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36};
    if (redNumbers.contains(number)) {
      return Colors.red;
    }
    return Colors.black;
  }

  List<Widget> _buildBest25Layout(List<int> predictions) {
    List<Widget> rows = [];

    if (predictions.isNotEmpty && predictions[0] == 0) {
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Center(
            child: Chip(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.all(1.0),
              label: SizedBox(
                width: 18, // Smaller width
                child: Text(
                  '0',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 10), // Smaller font
                ),
              ),
              backgroundColor: _getRouletteNumberColor(0),
            ),
          ),
        ),
      );
      predictions = predictions.sublist(1);
    }

    predictions = predictions.take(24).toList();

    for (int i = 0; i < predictions.length; i += 8) {
      final rowNumbers = predictions.skip(i).take(8).toList();
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: rowNumbers.map((number) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Chip(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.all(1.0),
                label: SizedBox(
                  width: 18, // Same smaller width
                  child: Text(
                    number.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 10), // Smaller font
                  ),
                ),
                backgroundColor: _getRouletteNumberColor(number),
              ),
            )).toList(),
          ),
        ),
      );
    }

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roulette Predictor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetHistory,
            tooltip: 'Reset History',
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2, // Number of tabs
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hit/Miss Status
              Container(
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: _hitMissStatus == 'HIT!' ? Colors.green.withAlpha((255 * 0.2).round()) : Colors.red.withAlpha((255 * 0.2).round()),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Center(
                  child: Text(
                    _hitMissStatus,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _hitMissStatus == 'HIT!' ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ),

              // TabBar
              const TabBar(
                tabs: [
                  Tab(text: 'Best 25'),
                  Tab(text: 'The One Odd'),
                ],
              ),
              const SizedBox(height: 16),

              // TabBarView
              Expanded(
                child: TabBarView(
                  children: [
                    // Content for "Best 25" tab
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Card(
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _buildBest25Layout(_predictions),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Content for "The One Odd" tab
                    TheOneOddPredictor(history: _history),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Number Input Grid
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Center(
                          child: SizedBox(
                            width: 50, // Adjust size as needed
                            height: 50, // Adjust size as needed
                            child: ElevatedButton(
                              onPressed: () => _onNumberPressed(0),
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(8),
                                backgroundColor: _getRouletteNumberColor(0),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text(
                                '0',
                                style: TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverGrid.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: 36, // Numbers 1 to 36
                      itemBuilder: (context, index) {
                        final number = index + 1; // Start from 1
                        return ElevatedButton(
                          onPressed: () => _onNumberPressed(number),
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(8),
                            backgroundColor: _getRouletteNumberColor(number),
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            number.toString(),
                            style: const TextStyle(fontSize: 24),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // History
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('History:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 50, // Adjusted height for single line
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            spacing: 6.0,
                            children: _history.reversed.map((number) => Chip(
                              label: Text(
                                number.toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: _getRouletteNumberColor(number),
                            )).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Hit/Miss Counters
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('Hits: $_hitCount', style: const TextStyle(fontSize: 18, color: Colors.green)),
                  Text('Misses: $_missCount', style: const TextStyle(fontSize: 18, color: Colors.red)),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}