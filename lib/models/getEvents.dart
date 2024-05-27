import 'package:cloud_firestore/cloud_firestore.dart';

class Event{
  final String title;
  final String? description;
  final DateTime date;
  final String? group;
  final String id;


  Event({
    required this.title,
    this.description,
    required this.date,
    this.group,
    required this.id,

});

  factory Event.fromFireStore(DocumentSnapshot<Map<String,dynamic>> snapshot,[SnapshotOptions? options]){
    final data = snapshot.data()!;

    print("title:"+ data['title']+", date:"+ data['date'].toDate().toString()+", id:"+ snapshot.id+",description: "+data['description']+",group:"+data['group']);
    return Event(
        title: data['title'],
        date: data['date'].toDate(),
        id: snapshot.id,
        group: data['group'],
        description: data['description']);

  }

  Map<String,Object?> toFireStore(){
    return {
      "date":Timestamp.fromDate(date),
      "title":title,
      "description":description,
      "group":group
    };
  }
  factory Event.fromGoogleHolidayApi(Map<String, dynamic> data) {
    return Event(
      title: data['summary'],
      description: data['description'],
      date: DateTime.parse(data['start']['date']),
      id: data['id']);
  }
}