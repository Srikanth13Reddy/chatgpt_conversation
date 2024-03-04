import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:intl/intl.dart';



void main() => runApp(MyApp());





class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SmsQuery _query = SmsQuery();
  List<SmsMessage> _messages = [];
  List<SmsMessage> _sentMessages = [];
  List<SmsMessage> _receivedMessages = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter SMS Inbox App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('SMS Inbox Example'),
        ),
        body: Container(
          padding: const EdgeInsets.all(10.0),
          child: _messages.isNotEmpty
              ? _MessagesListView(
            messages: _messages,
          )
              : Center(
            child: Text(
              'No messages to show.\n Tap refresh button...',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            var permission = await Permission.sms.status;
            if (permission.isGranted) {
              final messages = await _query.querySms(
                kinds: [
                  SmsQueryKind.inbox,
                  SmsQueryKind.sent,
                ],
                // address: '+254712345789',
                count: 10000,
              );
               _sentMessages = await _query.querySms(
                kinds: [
                  SmsQueryKind.sent,
                ],
                // address: '+254712345789',
                count: 10000,
              );
              _receivedMessages = await _query.querySms(
                kinds: [
                  SmsQueryKind.inbox,
                ],
                // address: '+254712345789',
                count: 10000,
              );
              debugPrint('sms inbox messages: ${messages.length}');

              setState(() => _messages = messages);
              List<Receiver> list=[];
              List<Sender> list2=[];
              List<Sender> converSation=[];
              for(var data in _messages)
                {
                  if((data.address).toString().contains("9948129720"))
                    {
                      list.add(Receiver(userid: data.address,text: data.body,date: data.date));
                    }
                }

            
              list.sort((a,b) => a.date!.compareTo(b.date!));

               for(var data in list)
              {
                if((data.userid).toString().contains("9948129720"))
                {
                  list2.add(Sender(userid: data.userid,text: data.text,date: currentDate(data.date!)));
                }
              }
              SmsList smsList=SmsList(sender: list2.toList(),receiver: []);
              print(jsonEncode(smsList.toJson()));

            } else {
              await Permission.sms.request();
            }
          },
          child: const Icon(Icons.refresh),
        ),
      ),
    );
  }

  String? currentDate(DateTime now)
  {
    try{
      //var now = DateTime.now().toUtc();
      var outputFormat = DateFormat('dd MMM yyyy  hh:mm a');
      var outputDate = outputFormat.format(now);
      return outputDate;
    }catch(e){
      return null;
    }
  }
}

class _MessagesListView extends StatelessWidget {
  const _MessagesListView({
    Key? key,
    required this.messages,
  }) : super(key: key);

  final List<SmsMessage> messages;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: messages.length,
      itemBuilder: (BuildContext context, int i) {
        var message = messages[i];
        return ListTile(
          title: Text('${message.address} [${message.date}]'),
          subtitle: Text('${message.body}'),
        );
      },
    );
  }
}

class SmsResponse {
  SmsList? smsList;

  SmsResponse({this.smsList});

  SmsResponse.fromJson(Map<String, dynamic> json) {
    smsList =
    json['smsList'] != null ? new SmsList.fromJson(json['smsList']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.smsList != null) {
      data['smsList'] = this.smsList!.toJson();
    }
    return data;
  }
}

class SmsList {
  List<Sender>? sender;
  List<Receiver>? receiver;

  SmsList({this.sender, this.receiver});

  SmsList.fromJson(Map<String, dynamic> json) {
    if (json['sender'] != null) {
      sender = <Sender>[];
      json['sender'].forEach((v) {
        sender!.add(new Sender.fromJson(v));
      });
    }
    if (json['receiver'] != null) {
      receiver = <Receiver>[];
      json['receiver'].forEach((v) {
        receiver!.add(new Receiver.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.sender != null) {
      data['sender'] = this.sender!.map((v) => v.toJson()).toList();
    }
    if (this.receiver != null) {
      data['receiver'] = this.receiver!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Sender {
  String? userid;
  String? text;
  String? date;

  Sender({this.userid, this.text,this.date});

  Sender.fromJson(Map<String, dynamic> json) {
    userid = json['userid'];
    text = json['text'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userid'] = this.userid;
    data['text'] = this.text;
    data['date'] = this.date;
    return data;
  }
}

class Receiver {
  String? userid;
  String? text;
  DateTime? date;

  Receiver({this.userid, this.text,this.date});

  Receiver.fromJson(Map<String, dynamic> json) {
    userid = json['userid'];
    text = json['text'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userid'] = this.userid;
    data['text'] = this.text;
    data['date'] = this.date;
    return data;
  }
}