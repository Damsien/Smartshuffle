import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:smartshuffle/Model/Object/Track.dart';



class _EmailSender {

  _EmailSender._privateConstructor();

  static final _EmailSender _instance = _EmailSender._privateConstructor();

  factory _EmailSender() {
    return _instance;
  }

  void sendEmail(BuildContext context, String subject, String htmlMessage) async {

    Message message = Message()
        ..from = Address('dn.smartshuffle@gmail.com', 'User')
        ..recipients.add('dn.smartshuffle@gmail.com')
        ..subject = subject
        ..html = htmlMessage;
    
    try {
      SmtpServer smtpServer = gmail('dn.smartshuffle@gmail.com', 'damiennicolas');
      await send(message, smtpServer);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).formMessageSent)));
    } on SocketException catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).formMessageNotSentNetwork)));
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).formMessageNotSent)));
    }
  }

}



class _SubmitButton extends StatelessWidget {

  Function _sendingFunction;
  MaterialColor _materialColor;

  _SubmitButton(Function sendingFunction, MaterialColor materialColor) {
    _sendingFunction = sendingFunction;
    _materialColor = materialColor;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      color: _materialColor.shade700,
      shape: ContinuousRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
      onPressed: () => _sendingFunction.call(),
      child: Text(AppLocalizations.of(context).formSubmit,
        style: TextStyle(
          fontSize: 17,
          color: Colors.white,
        ),
      ),
    );
  }
  
}




class FormReport extends StatefulWidget {

  final MaterialColor materialColor;
  final Track track;

  FormReport({Key key, @required this.materialColor, @required this.track}) : super(key: key);

  @override
  _FormReport createState() => _FormReport();

}

class _FormReport extends State<FormReport> {

  final _formKey = GlobalKey<FormState>();

  static const String SELECT_NOT_REAL_TRACK = "La musique jouée n'est pas la correcte";
  static const String SELECT_OTHER = "Autre";

  String _select = SELECT_NOT_REAL_TRACK;
  final _reportCtrl = TextEditingController();

  void sendEmail() {
    if (_formKey.currentState.validate()) {
                
      String subject = _select + " 😓";
      String title = this.widget.track.name;
      String artist = this.widget.track.artist;
      String id = this.widget.track.id;
      String service = this.widget.track.serviceName;
      String reportMessage = _reportCtrl.text;
      reportMessage.characters.replaceAll(Characters("\n"), Characters("<br>"));

      String htmlMessage = "<p>Title : $title</p><p>Artist : $artist</p><p>Id : $id</p><p>Service : $service</p><p>Date : ${DateTime.now()}</p>";

      if(_select == SELECT_OTHER)
        htmlMessage += "<p>Report message : $reportMessage</p>";

      _EmailSender().sendEmail(context, subject, htmlMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).globalReport),),
      body: Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButton<String>(
                value: _select,
                onChanged: (String value) {
                  if(value == SELECT_NOT_REAL_TRACK) {
                    setState(() {
                      _select = SELECT_NOT_REAL_TRACK;
                    });
                  } else {
                    setState(() {
                      _select = SELECT_OTHER;
                    });
                  }
                },
                items: <String>[
                  SELECT_NOT_REAL_TRACK,
                  SELECT_OTHER
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              (_select == SELECT_OTHER ? 
                TextFormField(
                  controller: _reportCtrl,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).globalPrecision
                  ),
                  minLines: 5,
                  maxLines: 10,
                )
              : Container()),
              _SubmitButton(sendEmail, this.widget.materialColor)
            ],
          ),
        )
      )
    );
  }
  
}




class FormSuggestion extends StatefulWidget {

  final MaterialColor materialColor;

  FormSuggestion({Key key, this.materialColor}) : super(key: key);

  @override
  _FormSuggestionState createState() {
    return _FormSuggestionState();
  }
}

class _FormSuggestionState extends State<FormSuggestion> {

  final _formKey = GlobalKey<FormState>();
  
  static const String TYPE_UPGRADE = "Suggestion d'amélioration";
  static const String TYPE_BUG = "Repérrage de bug";

  String _type = TYPE_UPGRADE;
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  void sendEmail() {
    if (_formKey.currentState.validate()) {
                
      String subject = _type == TYPE_UPGRADE ? _type + " 😀" : _type + " 😓";
      String name = _nameCtrl.text;
      String email = _emailCtrl.text;
      String message = _messageCtrl.text;
      String description = _descriptionCtrl.text;
      description.characters.replaceAll(Characters("\n"), Characters("<br>"));

      String htmlMessage = "<p>Name : $name</p><p>Email : $email</p><p>Message : $message</p><p>Description : $description</p><p>Date : ${DateTime.now()}</p>";
   
      _EmailSender().sendEmail(context, subject, htmlMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
   
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DropdownButton<String>(
            value: _type,
            onChanged: (String value) {
              if(value == TYPE_UPGRADE) {
                setState(() {
                  _type = TYPE_UPGRADE;
                });
              } else {
                setState(() {
                  _type = TYPE_BUG;
                });
              }
            },
            items: <String>[
              TYPE_UPGRADE,
              TYPE_BUG
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          TextFormField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).formEnterName
            )
          ),
          TextFormField(
            controller: _emailCtrl,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).formEnterEmail
            ),
            validator: (value) {
              if (value != null && (!value.contains('@') || !value.contains('.'))) {
                return AppLocalizations.of(context).formPleaseEnterEmail;
              }
              return null;
            },
          ),
          TextFormField(
            textInputAction: TextInputAction.go,
            controller: _messageCtrl,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).formEnterMessage+"*",
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(context).formPleaseEnterText;
              }
              return null;
            },
            onFieldSubmitted: (String val) => sendEmail(),
          ),
          TextFormField(
            controller: _descriptionCtrl,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).formEnterDescription,
            ),
            minLines: 5,
            maxLines: 10,
          ),
          _SubmitButton(sendEmail, this.widget.materialColor)
        ],
      )
    );

  }
  
}