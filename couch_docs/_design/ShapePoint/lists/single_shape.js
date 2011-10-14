function(head, req) {
  start({
      'headers': {
      'Content-Type': 'application/json'
      }
      });
  var row = null;
  var shape = {
    'shape_id' : null,
    'type' : 'LineString',
    'coordinates' : []
  };
  while (row = getRow()) {
    shape.shape_id = row.key;
    shape.coordinates[row.value.sequence - 1] = row.value.coordinates
  }
  send(toJSON(shape));
}
