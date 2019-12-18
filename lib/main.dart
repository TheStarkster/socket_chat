import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DefaultPage(),
    );
  }
}

class DefaultPage extends StatefulWidget {
  @override
  _DefaultPageState createState() => _DefaultPageState();
}

class _DefaultPageState extends State<DefaultPage>{
  TextStyle style = new TextStyle(fontFamily: 'Raleway-Light', fontSize: 18.0, color: Colors.white);
  TextEditingController emailController;
  WebSocketChannel channel;
  @override
  void initState(){
    super.initState();
    emailController = TextEditingController();
  }
  @override
  Widget build(BuildContext context) {
    final phoneField = TextField(
      controller: emailController,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(30.0, 15.0, 5.0, 5.0),
        hintText: "Mobile Number",
        hintStyle: TextStyle(
            fontSize: 16.0, color: Colors.white60, fontFamily: 'Raleway-Light'),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32.0),
          borderSide: BorderSide(color: Color(0xFF0097e6), width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32.0),
          borderSide: BorderSide(color: Colors.white60, width: 1.4),
        ),
      ),
    );
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(50),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.lightBlue,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            phoneField,
            MaterialButton(
              shape: StadiumBorder(side: BorderSide(color: Colors.black)),
              onPressed: () {
                Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyHomePage(phone: emailController.text,title: "WS",))//MyHomePage(phoneNumber: emailController.text)),
                );
              },
              child: Text('Go'),
            )
          ],
        ),
      ),
    );
  }
}


class MyHomePage extends StatefulWidget {
  final String title;
  final String phone;
  MyHomePage({Key key, @required this.title, @required this.phone})
      : super(key: key);
  // WebSocketChannel channel = 
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _controller, _receiver;
  WebSocketChannel channel;
  int value;
  List<Container> _messageList;
  @override
  void initState(){
    super.initState();
    channel = IOWebSocketChannel.connect('ws://18.219.197.206:8080/'+ widget.phone);
    _controller = TextEditingController();
    _messageList = [];
    _receiver = TextEditingController();
    value = 0;
    channel.stream.listen((message){
        setState(() {
          _messageList.insert(_messageList.length, 
            Container(
              child: Bubble(isMe: false,message: message)
          ));
        });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Form(
              child: TextFormField(
                controller: _receiver,
                decoration: InputDecoration(labelText: 'Enter Receiver'),
              ),
            ),
            Form(
              child: TextFormField(
                controller: _controller,
                decoration: InputDecoration(labelText: 'Enter message'),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height/2,
              child: ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  final message = _messageList[index];
                  return message;
                },
                itemCount: _messageList.length,

              )
            )
            // StreamBuilder(
            //   stream: channel.stream,
            //   builder: (context, snapshot) {
            //     return Padding(
            //       padding: const EdgeInsets.symmetric(vertical: 24.0),
            //       child: Text(snapshot.hasData ? '${snapshot.data}' : ''),
            //     );
            //   },
            // ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendMessage,
        tooltip: 'Send message',
        child: Icon(Icons.send),
      ),
    );
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      channel.sink.add(jsonEncode({
        "message":_controller.text,
        "receiver":"/"+ _receiver.text
      }));
      setState(() {
          _messageList.insert(_messageList.length, 
            Container(
              child: Bubble(isMe: true,message: _controller.text)
          ));
        });
      _controller.text = "";
    }
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}
Widget getTextWidgets(List<String> strings)
  {
    return new Row(children: strings.map((item) => new Text(item)).toList());
  }

  class Bubble extends StatelessWidget {
  final bool isMe;

  final String message;

  Bubble({this.message, this.isMe});

  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      padding: isMe ? EdgeInsets.only(left: 40) : EdgeInsets.only(right: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Column(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  gradient: isMe
                      ? LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          stops: [
                              0.1,
                              1
                            ],
                          colors: [
                              Color(0xFFF6D365),
                              Color(0xFFFDA085),
                            ])
                      : LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          stops: [
                              0.1,
                              1
                            ],
                          colors: [
                              Color(0xFFEBF5FC),
                              Color(0xFFEBF5FC),
                            ]),
                  borderRadius: isMe
                      ? BorderRadius.only(
                          topRight: Radius.circular(15),
                          topLeft: Radius.circular(15),
                          bottomRight: Radius.circular(0),
                          bottomLeft: Radius.circular(15),
                        )
                      : BorderRadius.only(
                          topRight: Radius.circular(15),
                          topLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                          bottomLeft: Radius.circular(0),
                        ),
                ),
                child: Column(
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      message,
                      textAlign: isMe ? TextAlign.end : TextAlign.start,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.grey,
                      ),
                    )
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}