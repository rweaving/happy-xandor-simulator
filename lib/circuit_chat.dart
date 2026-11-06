//fb.DatabaseReference chatRef;

//  final UListElement messages;
//  final InputElement newMessage;
//  final InputElement submit;
//  final FormElement newMessageForm;
//
//  messages = querySelector("#messages"),
//  newMessage = querySelector("#new_message"),
//  submit = querySelector('#submit'),
//  newMessageForm = querySelector("#new_message_form")

//chatRef = fb.database().ref("logicSimulator/circuits/" + circuitName + "/chat");

//    this.chatRef.onChildAdded.listen(_newChatMessage);
//    this.chatRef.onChildRemoved.listen(_chatMessageRemoved);
//    this.chatRef.onChildChanged.listen(_chatMessageChanged);

//    newMessage.disabled = false;
//
//    submit.disabled = false;
//
//    this.newMessageForm.onSubmit.listen((e) async {
//      e.preventDefault();
//
//      if (newMessage.value.trim().isNotEmpty) {
//        var map = {"text": newMessage.value};
//
//        try {
//          await chatRef.push(map).future;
//          newMessage.value = "";
//        } catch (e) {
//          print("Error while writing to db, $e");
//        }
//      }
//    });

//
//  _newChatMessage(fb.QueryEvent event){
//    fb.DataSnapshot datasnapshot = event.snapshot;
//    var spanElement = new SpanElement()..text = datasnapshot.val()["text"];
//    var element = new LIElement()
//      ..id = datasnapshot.key
//      ..append(spanElement);
//    messages.append(element);
//  }
//
//  _chatMessageRemoved(fb.QueryEvent event){
//    fb.DataSnapshot datasnapshot = event.snapshot;
//    var element = querySelector("#${datasnapshot.key}");
//    if (element != null) {
//      element.remove();
//    }
//  }
//
//  _chatMessageChanged(fb.QueryEvent event){
//    fb.DataSnapshot datasnapshot = event.snapshot;
//    var element = querySelector("#${datasnapshot.key} span");
//
//    if (element != null) {
//      element.text = datasnapshot.val()["text"];
//    }
//  }
