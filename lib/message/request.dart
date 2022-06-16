part of redisfordart;


class RequestForRedis {
  List<int> _body = List.empty(growable: true);

  /*
  RequestForRedis(int size) {
    _body.length = size;
  }
  */


  Future<void> serialize(args) async {
    if(!(args is List)) {
      return;
    }

    if(args.length == 0) {
      return;
    }

    _body.addAll(args[0].codeUnits);

    for(var i = 1; i < args.length; i++) {
    }
  }


  Uint8List toBytes() {
    return Uint8List(2);
  }
}
