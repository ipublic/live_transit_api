function (head, req) {
  start({
      'headers': {
      'Content-Type': 'application/json'
      }
      });
  var row = null;
  var stop_collection = {};
  while (row = getRow()) {
    if (!stop_collection[row.key]) {
      stop_collection[row.key] = [];
    }
    stop_collection[row.key].push(row.value);
  }
  send(toJSON(stop_collection));
}
