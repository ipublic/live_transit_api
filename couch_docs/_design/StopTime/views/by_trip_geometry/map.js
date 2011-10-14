function(doc) {
  if (doc.type && doc.type == "StopTime") {
    emit(doc.trip_id, {
        "stop_sequence": doc.stop_sequence,                                                       
        "lat": doc.geometry.coordinates[1],                                                       
        "lon": doc.geometry.coordinates[0]                                                        
      }); 
  }
}
