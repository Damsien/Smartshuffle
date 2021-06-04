import 'dart:io';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';
import 'package:smartshuffle/View/ViewGetter/Profiles/PlatformsConnection.dart';
import 'package:smartshuffle/View/ViewGetter/Profiles/PlatformsInformation.dart';


enum ProfileViewType {
  PlatformInformation,
  PlatformConnection,
}

class ProfileView {

  static getView({@required ServicesLister service, @required ProfileViewType view, Map parameters}) {
    if(view == ProfileViewType.PlatformConnection) return PlatformsConnection.getView(service, parameters['buttonString']);
    else if(view == ProfileViewType.PlatformInformation) return PlatformsInformation.getView(service);
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

  void sendEmail() async {
    if (_formKey.currentState.validate()) {
                
      String type = _type == TYPE_UPGRADE ? _type + " 😀" : _type + " 😓";
      String name = _nameCtrl.text;
      String email = _emailCtrl.text;
      String message = _messageCtrl.text;
      String description = _descriptionCtrl.text;
      description.characters.replaceAll(Characters("\n"), Characters("<br>"));

      Message finalMessage = Message()
        ..from = Address('dn.smartshuffle@gmail.com', 'User')
        ..recipients.add('dn.smartshuffle@gmail.com')
        ..subject = type
        ..html = "<p>Name : $name</p><p>Email : $email</p><p>Message : $message</p><p>Description : $description</p><p>Date : ${DateTime.now()}</p>";
      
      try {
        SmtpServer smtpServer = gmail('dn.smartshuffle@gmail.com', 'damiennicolas');
        await send(finalMessage, smtpServer);
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
          MaterialButton(
            color: this.widget.materialColor.shade700,
            shape: ContinuousRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
            onPressed: () async => sendEmail(),
            child: Text(AppLocalizations.of(context).formSubmit,
              style: TextStyle(
                fontSize: 17,
                color: Colors.white,
              ),
            ),
          )
        ],
      )
    );

  }
  
}