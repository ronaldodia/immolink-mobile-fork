import 'dart:async';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:immolink_mobile/const/chat.dart';
import 'package:immolink_mobile/models/ChatModel.dart';
import 'package:immolink_mobile/utils/t_sizes.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.conversationId});
  final String conversationId;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
   TextEditingController text = TextEditingController();
   String myName = "Diagana";
  Timer? _timer;

  @override
  void dispose() {
    text.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: const Text("Conversation"),
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: Chat.length,
                itemBuilder: (_, index) =>  BubbleSpecialThree(
                  isSender: Chat[Chat.length - (index + 1)].sender_name == myName ? true : false,
                  text: Chat[Chat.length - (index + 1)].text.toString(),
                  color: Chat[Chat.length - (index + 1)].sender_name == myName ? Colors.green : Colors.black45,
                  tail: true,
                  textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 16
                  ),
                ),
              ),
            ),

            Container(
              color: Colors.black12,
              height: 100,
              padding: const EdgeInsets.all(5),
              child: Row(
                children: [
                  IconButton(onPressed: (){

                  }, icon: const Icon(Icons.add, color: Colors.green,)
                  ),
                   Expanded(
                    child: TextField(
                      onTapOutside: (e){
                        FocusScope.of(context).requestFocus(new FocusNode());
                      },
                      cursorColor: Colors.black,
                      controller: text,
                    style: const TextStyle(
                      color: Colors.black
                    ),
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: const BorderSide(color: Colors.black)
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: const BorderSide(color: Colors.green)
                        )
                      ),
                    ),
                  ),
                  IconButton(onPressed: (){
                    setState(() {
                      Chat.add(ChatModel(text.text, 'Demba'));
                      text.text = '';
                    });
                  }, icon: const Icon(Icons.send, color: Colors.green,)
                  )
                ],
              ),
            )

          ],
        ),
      )
    );
  }


  Widget messageItem(ChatModel chat){
    return InkWell(
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        children: [
          BubbleSpecialThree(
            isSender: chat.sender_name == myName ? true : false,
            text: chat.text.toString(),
            color: chat.sender_name == myName ? Colors.green : Colors.black45,
            tail: true,
            textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 16
            ),
          ),
        ],
      ),
    );
  }

}

