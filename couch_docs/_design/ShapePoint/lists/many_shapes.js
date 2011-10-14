function(head, req) {
      start({
        'headers': {
          'Content-Type': 'application/json'
        }
      });
      var row = null;
      var shapes = {};
      while (row = getRow()) {
        if (!shapes[row.key]) {
          shapes[row.key] = {
            'shape_id': row.key,
            'type': 'LineString',
            'coordinates': []
          };
        }
        shapes[row.key].coordinates[row.value.sequence - 1] = row.value.coordinates
      }
      var isFirst = true;
      for (var i in shapes) {
        if (isFirst) {
          send("[");
          isFirst = false;
        } else {
          send(",");
        }
        send(toJSON(shapes[i]));
      }
      send("]");
}
