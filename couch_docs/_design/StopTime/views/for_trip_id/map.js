function (doc) {
  if (doc.type && doc.type == "StopTime") {
    emit(doc.trip_id, {
        'stop_name' : doc.stop_name,
        'stop_code' : doc.stop_code,
        'stop_id' : doc.stop_id,
        'arrival_time' : doc.arrival_time,
        'departure_time' : doc.departure_time,
        'stop_sequence' : doc.stop_sequence
        });
  }
}
