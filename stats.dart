import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<Map<String, dynamic>>> _loadAllPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  final keys = prefs.getKeys().where((key) => key.startsWith('moodData_')).toList();

  Map<String, Map<String, dynamic>> allDataMap = {};

  for (String key in keys) {
    final dateKey = key.split('_')[1];

    if (!allDataMap.containsKey(dateKey)) {
      allDataMap[dateKey] = {
        'stressLevel': 5.0,
        'selfEsteemLevel': 5.0,
        'notes': '',
        'selected': {}
      };
    }

    if (key.endsWith('_stressLevel')) {
      allDataMap[dateKey]!['stressLevel'] = prefs.getDouble(key) ?? 5.0;
    } else if (key.endsWith('_selfEsteemLevel')) {
      allDataMap[dateKey]!['selfEsteemLevel'] = prefs.getDouble(key) ?? 5.0;
    } else if (key.endsWith('_notes')) {
      allDataMap[dateKey]!['notes'] = prefs.getString(key) ?? '';
    } else if (key.endsWith('_selected')) {
      final selectedJson = prefs.getString(key) ?? '{}';
      final selectedMap = (jsonDecode(selectedJson) as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, List<String>.from(value)),
      );
      allDataMap[dateKey]!['selected'] = selectedMap;
    }
  }
  print(allDataMap);
  return allDataMap.values.toList();
}

double calculateAverage(List<double> values) {
  if (values.isEmpty) return 0.0;
  double sum = values.reduce((a, b) => a + b);
  return sum / values.length;
}
Map<String, int> countEmotionFrequencies(List<Map<String, List<String>>> selectedData) {
  Map<String, int> emotionFrequency = {};

  for (var selected in selectedData) {
    selected.forEach((emotion, details) {
      for (String detail in details) {
        if (emotionFrequency.containsKey(detail)) {
          emotionFrequency[detail] = emotionFrequency[detail]! + 1;
        } else {
          emotionFrequency[detail] = 1;
        }
      }
    });
  }

  return emotionFrequency;
}

List<String> getMostFrequentEmotions(Map<String, int> frequencies) {
  if (frequencies.isEmpty) return [];
  int maxFrequency = frequencies.values.reduce((a, b) => a > b ? a : b);

  return frequencies.entries
      .where((entry) => entry.value == maxFrequency)
      .map((entry) => entry.key)
      .toList();
}



class StatScreen extends StatefulWidget {

  const StatScreen({Key? key}) : super(key: key);

  @override
  _StatScreenState createState() => _StatScreenState();
}

class _StatScreenState extends State<StatScreen> {
  double _averageStressLevel=0;
  double _averageSelfEsteemLevel=0;
  List<String> _mostFrequentEmotions=[];



  @override
  void initState() {
    super.initState();
    _calculateStatistics();
  }
  Future<void> _clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    setState(() {
      _averageStressLevel = 0;
      _averageSelfEsteemLevel = 0;
      _mostFrequentEmotions = [];
    });
  }


  Future<void> _calculateStatistics() async {
    final allData = await _loadAllPreferences();
    print(allData);

    List<double> stressLevels = [];
    List<double> selfEsteemLevels = [];
    List<Map<String, List<String>>> selectedData = [];

    for (var data in allData) {
      stressLevels.add(data['stressLevel']);
      selfEsteemLevels.add(data['selfEsteemLevel']);
      selectedData.add(data['selected']);
    }

    double averageStressLevel = calculateAverage(stressLevels);
    double averageSelfEsteemLevel = calculateAverage(selfEsteemLevels);

    Map<String, int> emotionFrequencies = countEmotionFrequencies(selectedData);
    List<String> mostFrequentEmotions = getMostFrequentEmotions(emotionFrequencies);

    setState(() {
      _averageStressLevel = averageStressLevel;
      _averageSelfEsteemLevel = averageSelfEsteemLevel;
      _mostFrequentEmotions = mostFrequentEmotions;
    });
  }
  

  @override
  Widget build(BuildContext context) {
    // _calculateStatistics();
    // print(averageSelfEsteemLevel);
    return Scaffold(
      appBar: AppBar(title: Text('Статистика')),
      body: Column(
        children: [
          Text('Средний уровень стресса: $_averageStressLevel'),
          Text('Средний уровень самооценки: $_averageSelfEsteemLevel'),
          Text('Часто встречаемые эмоции: $_mostFrequentEmotions'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _clearPreferences, 
            child: Text('Очистить данные'),
          ),
        ],
      ),
    );
  }
}