function(doc) {
  if (doc.type && doc.type == "StopTime") {
    emit(doc.trip_id, {
        "stop_sequence": doc.stop_sequence,                                                       
        "lat": doc.stop_geometry.coordinates[1],                                                       
        "lon": doc.stop_geometry.coordinates[0]                                                        
      }); 
  }
}
