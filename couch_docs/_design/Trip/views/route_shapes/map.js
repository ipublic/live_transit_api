function(doc) {
  if (doc.type && doc.type == 'Trip' && doc.schedules) {
    emit([doc.route_id, doc.shape_id], 1); 
  }
}
