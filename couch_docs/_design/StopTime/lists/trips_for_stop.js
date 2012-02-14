function (head, req) {
  start({
      'headers': {
      'Content-Type': 'application/json'
      }
      });
  var row = null;
  var trip_collection = [];
  while (row = getRow()) {
    if (trip_collection.indexOf(row.value['trip_id']) == -1) {
      trip_collection.push(row.value['trip_id']);
    }
  }
  send(toJSON(trip_collection));
}
