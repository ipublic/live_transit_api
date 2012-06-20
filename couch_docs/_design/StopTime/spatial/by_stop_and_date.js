function(doc) {
  if (doc['type'] == 'StopTime' && doc.schedules && doc.arrival_time && doc.departure_time) {       
    for (var i = 0; i < doc.schedules.length; i++) {
      var startd = parseFloat(doc.schedules[i].day_type.toString() + "." + doc.schedules[i].start_date.replace(/-/g, ""));
      var endd = parseFloat(doc.schedules[i].day_type.toString() + "." + doc.schedules[i].end_date.replace(/-/g, ""));
      var stop_val = doc.stop_id.replace(/[^0-9]+/g, "000");
      var start_time = parseFloat(stop_val + "." + doc.arrival_time.replace(/:/g, ""));      
      var end_time = parseFloat(stop_val + "." + doc.departure_time.replace(/:/g, ""));      

      emit(                                                                                         
          {
            type : 'LineString',                                                                         
            coordinates : [
              [start_time, startd],                                                                       
              [end_time, endd]                                                                            
            ]                                                                                            
          },
        null);                                                                                        
    }                                                                                               
  }                                                                                                 
}
