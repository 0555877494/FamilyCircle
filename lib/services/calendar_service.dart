import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/calendar_event.dart';

class CalendarService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _eventsRef = FirebaseFirestore.instance.collection('calendar_events');

  Future<void> createEvent(CalendarEvent event) async {
    await _eventsRef.doc(event.id).set(event.toMap());
  }

  Future<void> updateEvent(CalendarEvent event) async {
    await _eventsRef.doc(event.id).update(event.toMap());
  }

  Future<void> deleteEvent(String eventId) async {
    await _eventsRef.doc(eventId).delete();
  }

  Stream<List<CalendarEvent>> getEventsStream(String familyId) {
    return _eventsRef
        .where('familyId', isEqualTo: familyId)
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CalendarEvent.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<List<CalendarEvent>> getEventsForDate(String familyId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final snapshot = await _eventsRef
        .where('familyId', isEqualTo: familyId)
        .where('startTime', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where('startTime', isLessThan: endOfDay.toIso8601String())
        .orderBy('startTime')
        .get();
    
    return snapshot.docs
        .map((doc) => CalendarEvent.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<CalendarEvent>> getUpcomingEvents(String familyId, {int limit = 10}) async {
    final now = DateTime.now().toIso8601String();
    final snapshot = await _eventsRef
        .where('familyId', isEqualTo: familyId)
        .where('startTime', isGreaterThanOrEqualTo: now)
        .orderBy('startTime')
        .limit(limit)
        .get();
    
    return snapshot.docs
        .map((doc) => CalendarEvent.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
}