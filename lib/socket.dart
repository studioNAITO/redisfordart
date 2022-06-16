part of redisfordart;


class SocketForRedis {
  // Socket or SecureSocket
  Socket? _socket;
  Stream? stream;
  var _queue = Queue<Completer<ResponseForRedis>>();

  //var _uuid = Uuid();


  Socket? get real {
    return _socket;
  }


  Future<bool> connect(host, port) async {
    try {
      _socket = await Socket.connect(host, port);

      stream = _socket!.asBroadcastStream(
        onListen: broadcastOnListen, onCancel: broadcastOnCancel
      );

      stream!.listen(onData, onError: onError, onDone: onDone);

      setNoDelay(true);

      return true;
    } catch(connectErr) {
      // Log error from connection
      print("[connect error]: ${connectErr}");

      return false;
    }
  }


  Future<bool> connectTls(host, port) async {
    try {
      _socket = await SecureSocket.connect(host, port);
      stream = _socket!.asBroadcastStream(
        onListen: broadcastOnListen, onCancel: broadcastOnCancel
      );

      stream!.listen(onData, onError: onError, onDone: onDone);

      setNoDelay(true);

      return true;
    } catch(connectErr) {
      // Log error from connection
      print("[connectTls error]: ${connectErr}");

      return false;
    }
  }


  Future close() async {
    try {
      return await _socket!.close();
    } catch(closeErr) {
    }
  }


  bool setNoDelay(bool value) {
    try {
      return _socket!.setOption(SocketOption.tcpNoDelay, value);
    } catch(err) {
      return false;
    }
  }


  /*
   */


  void onData(packet) {
    print("socket.onData: (${packet.runtimeType.toString()}) ${packet}");
    var comp = _queue.removeFirst();
    ResponseForRedis res = ResponseForRedis();

    //res.parse(packet);

    comp.complete(res);
  }


  void onError(sockErr) {
    close();
  }


  void onDone() {
    onError("Stream closed");
  }


  /*
   */


  void broadcastOnListen(subscription) {
  }


  void broadcastOnCancel(subscription) {
  }


  /*
   */


  Future<ResponseForRedis> request(args) async {
    var req = RequestForRedis();
    var comp = Completer<ResponseForRedis>();

    _queue.addLast(comp);

    await req.serialize(args);

    _socket!.add(req.toBytes());

    //await _socket.flush();

    return comp.future;
  }
}
