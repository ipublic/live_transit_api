function (head, req) {
  start({
      'headers': {
      'Content-Type': 'application/json'
      }
      });
  var row = null;
  var isFirst = true;
  while (row = getRow()) {
    if (isFirst) {
      send("[");
      isFirst = false;
    } else {
      send(",");
    }
    send(toJSON(row.value));
  }
  send("]");
}
