function(doc) {
  if (doc.type && doc.type == "ShapePoint") {
    emit(doc.shape_id, { 
        'sequence': doc.shape_pt_sequence,
        'coordinates' : [doc.shape_pt_lon, doc.shape_pt_lat]
        });
  }
}
