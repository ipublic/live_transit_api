function (doc) {
  if (doc.type && doc.type == "StopTime") {
    emit(doc.stop_id, {
        'route_id' : doc.route_id,
        'trip_id' : doc.trip_id,
        'arrival_time' : doc.arrival_time,
        'departure_time' : doc.departure_time,
        'stop_sequence' : doc.stop_sequence
        });
  }
}
