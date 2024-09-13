import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'saving.dart';
import 'calendarScreen.dart';
class MoodJournalScreen extends StatefulWidget {
  final DateTime date;

  const MoodJournalScreen({Key? key, required this.date}) : super(key: key);

  @override
  _MoodJournalScreenState createState() => _MoodJournalScreenState();
}

class _MoodJournalScreenState extends State<MoodJournalScreen> {
  bool isMoodJournalSelected = true;
  double stressLevel = 5;
  double selfEsteemLevel = 5;

  String? curSelectedEmotion;
  Map<String, List<String>> emotionDetails = {
    'Радость': ['Возбуждение', 'Восторг', 'Игривость', 'Наслаждение', 'Очарование', 'Осознанность', 'Смелость', 'Удовольствие', 'Чувственность', 'Энергичность', 'Экстравагантность'],
    'Страх': ['Тревога', 'Неуверенность', 'Ужас', 'Опасение'],
    'Бешенство': ['Ярость', 'Гнев'],
    'Грусть': ["Печаль",'Негатив', 'Тревожность', 'Уныние', 'Отвращение'],
    "Спокойствие":['чил'],
    'Сила':['Решительность']
  };

  Map<String,List<String>> selected ={
    'Радость': [],
    'Страх': [],
    'Бешенство': [],
    'Грусть': [],
    "Спокойствие":[],
    'Сила':[]
  };

  String notes = "";  
  TextEditingController notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          style: const TextStyle(fontWeight: FontWeight.bold),
          '${widget.date.day}.${widget.date.month}.${widget.date.year}',
        ),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.calendar),
            onPressed: () {
              Navigator.push(context,
               MaterialPageRoute(builder: (context)=>CalendarScreen()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Toggle between "Дневник настроения" and "Статистика"
          ToggleSwitch(
            minWidth: 200.0,
            cornerRadius: 20.0,
            activeBgColors: [[Colors.orange[800]!], [Colors.orange[800]!]],
            activeFgColor: Colors.white,
            inactiveBgColor: Colors.grey,
            inactiveFgColor: Colors.white,
            initialLabelIndex: isMoodJournalSelected ? 0 :1,
            totalSwitches: 2,
            icons: const [FontAwesomeIcons.book,FontAwesomeIcons.chartBar],
            labels: const ['Дневник настроения', 'Статистика'],
            radiusStyle: true,
            onToggle: (index) {
              print(index);
              isMoodJournalSelected = index==0 ? true : false;
              setState(() {});
            },
          ),
          Expanded(
            child: isMoodJournalSelected ? _buildMoodJournal() : _buildStatistics(),
          ),
        ],
      ),
    );
  }
  

  Widget _buildMoodJournal() {
    return SingleChildScrollView(
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          const Text(
            "Что чувствуешь?",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          
          SizedBox(
            height: 170,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                  _buildEmotionButton('Радость', Icons.sentiment_very_satisfied),
                  _buildEmotionButton('Страх', Icons.sentiment_dissatisfied),
                  _buildEmotionButton('Бешенство', Icons.sentiment_very_dissatisfied),
                  _buildEmotionButton('Грусть', Icons.sentiment_satisfied),
                  _buildEmotionButton('Спокойствие', Icons.sentiment_neutral),
                  _buildEmotionButton('Сила', Icons.fitness_center),
              ],
            ),
          ),
          _buildDetailedEmotionList(),
          _buildSlider("Уровень Стресса", stressLevel,['Низкий','Высокий'] ,(newValue) {
            setState(() {
              stressLevel = newValue;
            });
          }),
          _buildSlider("Самооценка", selfEsteemLevel,['Неуверенность','Уверенность'] ,(newValue) {
            setState(() {
              selfEsteemLevel = newValue;
            });
          }),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Заметки", style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  TextField(
                    controller: notesController,
                    onChanged: (value) {
                      setState(() {
                        notes = value;  // Сохраняем введенный текст
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Введите ваши заметки здесь...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    maxLines: 3,  // Текстовое поле с несколькими строками
                  ),
                ],
              ),
            ),
          
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Add save functionality
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                backgroundColor: Colors.orange,
              ),
              child: const Text("Сохранить"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionButton(String emotion, IconData icon) {
    final isSelected = selected[emotion]!.isNotEmpty;
    return GestureDetector(
      onTap: () {
        setState(() {          
          curSelectedEmotion = emotion;
          // selectedDetails = []; 
        });
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.symmetric(horizontal: 8),  
        // padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromARGB(255, 253, 245, 232) : Colors.white70,
          borderRadius: BorderRadius.circular(30),
          
          border: curSelectedEmotion == emotion ? Border.all(color: Colors.orange, width: 3) : null,  
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30),
            const SizedBox(height: 5),
            Text(emotion),
          ],
        ),
      ),
    );
  }
   Widget _buildDetailedEmotionList() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 10.0, 
        runSpacing: 10.0, 
        children: curSelectedEmotion!=null ? emotionDetails[curSelectedEmotion]!.map((detail) {
          final isSelected = selected[curSelectedEmotion]!=null 
            ? selected[curSelectedEmotion]!.contains(detail)
            : false;
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected!) {
                  selected[curSelectedEmotion]?.remove(detail);
                } else {
                  selected[curSelectedEmotion]?.add(detail);
                }
                print(isSelected);
                print(selected);
              });
            },
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: isSelected ? Colors.orange : const Color.fromARGB(255, 230, 230, 230),
                // borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                detail,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ),
          );
        }).toList() :  [],
      ),
    );
  }
  Widget _buildSlider(String label,double currentValue, List<String> t, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) => Container(
                width: 2,
                height: 12,
                color: const Color.fromARGB(102, 76, 61, 41),
              )),
            ),
          ),
          Slider(
            activeColor: Colors.orange,
            value: currentValue, 
            min: 0,
            max: 10,
            onChanged: onChanged,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t[0]),
              Text(t[1]),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return const Center(
      child: Text(
        'Статистика пока недоступна',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
