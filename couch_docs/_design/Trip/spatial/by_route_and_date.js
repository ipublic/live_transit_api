function(doc) {
  if (doc['type'] == 'Trip' && doc.schedules) {
    for (var i = 0; i < doc.schedules.length; i++) {
      var startd = parseFloat(doc.schedules[i].day_type.toString() + "." + doc.schedules[i].start_date.replace(/-/g, ""));
      var endd = parseFloat(doc.schedules[i].day_type.toString() + "." + doc.schedules[i].end_date.replace(/-/g, ""));
      var start_t = parseFloat(doc.route_id + "." + doc.start_time.replace(/:/g, ""));
      var end_t = parseFloat(doc.route_id + "." + doc.end_time.replace(/:/g, ""));

      emit(
         {
            type : 'LineString',
            coordinates : [
              [start_t, startd],
              [end_t, endd]
            ]
         },
         null);
     }
  }
}
