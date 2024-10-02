import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:immolink_mobile/controllers/language/language_controller.dart';
import 'package:table_calendar/table_calendar.dart';

class BookingScreen extends StatefulWidget {
  final List<DateTime> reservedDates;
  final String eventType;

  const BookingScreen({
    super.key,
    required this.reservedDates,
    required this.eventType,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  List<DateTime> _selectedDays = [];

  bool _isReserved(DateTime day) {
    // Vérifie si la date est réservée
    return widget.reservedDates.any((reservedDate) =>
    reservedDate.year == day.year &&
        reservedDate.month == day.month &&
        reservedDate.day == day.day);
  }

  bool _isPastDate(DateTime day) {
    // Vérifie si la date est passée
    DateTime now = DateTime.now();
    return day.isBefore(DateTime(now.year, now.month, now.day)); // Compare sans l'heure
  }

  bool _isToday(DateTime day) {
    // Vérifie si la date est aujourd'hui
    DateTime now = DateTime.now();
    return day.year == now.year && day.month == now.month && day.day == now.day;
  }

  @override
  Widget build(BuildContext context) {

    final LanguageController language = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: Text('Réserver - ${widget.eventType}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              if (_selectedDays.isEmpty) {
                Get.snackbar(
                  'Aucune date sélectionnée',
                  'Veuillez sélectionner au moins une date pour réserver.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                );
              } else {
                Get.snackbar(
                  'Réservation',
                  'Vous avez réservé pour les dates: ${_selectedDays.map((d) => '${d.day}/${d.month}/${d.year}').join(', ')}.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: DateTime.now(),
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 1, 1),
            selectedDayPredicate: (day) {
              return _selectedDays.contains(day);
            },
            locale: language.locale.languageCode,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                if (_isReserved(selectedDay)) {
                  Get.snackbar(
                    'Date réservée',
                    'Une réservation est déjà disponible pour cette date.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.orange,
                  );
                } else if (_isPastDate(selectedDay)) {
                  Get.snackbar(
                    'Date passée',
                    'Vous ne pouvez pas réserver une date passée.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                  );
                } else if (_selectedDays.contains(selectedDay)) {
                  _selectedDays.remove(selectedDay);
                } else {
                  _selectedDays.add(selectedDay);
                }
              });
            },
            calendarBuilders: CalendarBuilders(
              todayBuilder: (context, day, focusedDay) {
                if (_isReserved(day)) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.yellow, // Réservée en jaune
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  );
                } else {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.purple, // Date actuelle en violet
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }
              },
              defaultBuilder: (context, day, focusedDay) {
                if (_isReserved(day)) {
                  // Dates réservées en jaune
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.yellow,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  );
                }
                if (_isPastDate(day)) {
                  // Dates passées en gris
                  return Center(
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return null;
              },
              selectedBuilder: (context, day, focusedDay) {
                // Date sélectionnée en bleu
                return Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
