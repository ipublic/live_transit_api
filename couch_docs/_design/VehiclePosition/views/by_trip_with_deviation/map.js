function(doc) {
  if ((doc['type'] == 'VehiclePosition') && (doc['predicted_deviation'] != 63)) {
    emit(doc['trip_id'], 1);
  }
}
