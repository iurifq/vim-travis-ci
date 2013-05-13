function travis_callback(builds) {
  for (var i in builds) {
    var commit = query_param('commit');
    var repository = query_param('repository');
    if (builds[i].commit == commit) {
      self.location = 'https://travis-ci.org/' + repository + '/builds/' + builds[i].id;
    }
  }
}

function query_param(name) {
  return decodeURI((RegExp(name + '=' + '(.+?)(&|$)').exec(location.search) || [,null])[1]);
}
