import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:immolink_mobile/controllers/booking/booking_controller.dart';
import 'package:immolink_mobile/controllers/language/language_controller.dart';
import 'package:table_calendar/table_calendar.dart';

class BookingScreen extends StatefulWidget {
  final String eventType;
  final int articleId;  // Ajout de l'ID de l'article dans le constructeur

  const BookingScreen({
    super.key,
    required this.eventType,
    required this.articleId,  // Nécessaire pour l'ID
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final BookingController bookingController = Get.put(BookingController());
  final List<DateTime> _selectedDays = [];
  String selectedBookingType = 'normal'; // Par défaut, 'normal' est sélectionné

  @override
  void initState() {
    super.initState();
    // Appelle la méthode pour récupérer les dates réservées en passant l'ID de l'article
    bookingController.fetchReservedDates(widget.articleId);
  }

  bool _isReserved(DateTime day) {
    return bookingController.reservedDates.any((reservedDate) =>
    reservedDate.year == day.year &&
        reservedDate.month == day.month &&
        reservedDate.day == day.day);
  }

  bool _isPastDate(DateTime day) {
    DateTime now = DateTime.now();
    return day.isBefore(DateTime(now.year, now.month, now.day));
  }

  void _submitBooking() {
    if (_selectedDays.isEmpty) {
      Get.snackbar(
        'Aucune date sélectionnée',
        'Veuillez sélectionner au moins une date.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
      return;
    }

    // Formatage des dates pour n'inclure que l'année, le mois et le jour
    List<String> formattedDates = _selectedDays.map((day) => "${day.year}-${day.month}-${day.day}").toList();

    // Impression des dates sélectionnées et du type de réservation dans la console
    print('Dates sélectionnées : $formattedDates');
    print('Type de réservation : $selectedBookingType');
  }


  @override
  Widget build(BuildContext context) {
    final LanguageController language = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Réserver'),
      ),
      body: Obx(() {
        // Si le chargement est en cours, afficher un indicateur de chargement
        if (bookingController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Sinon, afficher le calendrier avec les dates et les boutons
        return Column(
          children: [
            TableCalendar(
              focusedDay: DateTime.now(),
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2030, 1, 1),
              calendarFormat: CalendarFormat.month,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Month',
              },
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
                          color: Colors.yellow,
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
                          color: Colors.purple,
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
            const SizedBox(height: 20), // Espace entre le calendrier et les boutons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Bouton pour la réservation normale
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedBookingType = 'normal';
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: selectedBookingType == 'normal'
                        ? Colors.green
                        : Colors.white, // Fond vert si sélectionné, sinon blanc
                    side: const BorderSide(color: Colors.green), // Bordure verte
                  ),
                  child: Text(
                    'Réservation normale',
                    style: TextStyle(
                      color: selectedBookingType == 'normal'
                          ? Colors.white
                          : Colors.green, // Écriture blanche si sélectionné, sinon verte
                    ),
                  ),
                ),
                const SizedBox(width: 10), // Espace entre les deux boutons
                // Bouton pour la réservation événement
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedBookingType = 'event';
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: selectedBookingType == 'event'
                        ? Colors.green
                        : Colors.white, // Fond vert si sélectionné, sinon blanc
                    side: const BorderSide(color: Colors.green), // Bordure verte
                  ),
                  child: Text(
                    'Réservation événement',
                    style: TextStyle(
                      color: selectedBookingType == 'event'
                          ? Colors.white
                          : Colors.green, // Écriture blanche si sélectionné, sinon verte
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40), // Espace entre les boutons et le bouton d'envoi
            ElevatedButton(
              onPressed: _submitBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Couleur du bouton d'envoi
                minimumSize: const Size(200, 50), // Largeur et hauteur minimum du bouton
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Espacement interne
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0), // Arrondir les coins
                ),
              ),
              child: const Text(
                'Envoyer',
                style: TextStyle(color: Colors.white),
              ),
            ),

          ],
        );
      }),
    );
  }
}
