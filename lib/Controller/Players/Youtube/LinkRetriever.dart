import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class TestHtml {


  static String urlToId(platform, id) {
    
    var id;

    //Checking platform
    if(platform == "youtube") {
      //Check if it's an id or an url
      if(id.contains("youtube") || id.contains("youtu.be")) {
        //Checking what type of url
        if(id.contains("youtu.be")) {
          id = id.split("be/")[1].split("?")[0];
        } else {
          id = id.split("v=")[1].split("?")[1];
        }
      }
    }

    return id;
  }

  static Future retrieve(platform, id) async {

    var link = '';

    //Checking platform
    if(platform == "youtube") {
      
      //Get the right id
      var newId = urlToId(platform, id);
      var getResponse = await http.get(Uri.https("yt-download.org", "/api/button/mp3/" + newId));
      
      //Manage html document to get the right final mp3 url
      var globalDoc = parse(getResponse.body);
      var bbody = globalDoc.body.children[0];
      var divs = bbody.children[0].children[0].children[0];
      divs.children[0].attributes.entries.forEach((elem) => {
        if(elem.key == 'href') link = elem.value
      });

    }

    return link;
  }



}