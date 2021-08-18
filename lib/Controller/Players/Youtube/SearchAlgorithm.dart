import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:smartshuffle/Controller/AppManager/ServicesLister.dart';
import 'package:smartshuffle/Model/Object/Track.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class SearchAlgorithm {

  SearchAlgorithm._singleton();

  static final SearchAlgorithm _instance = SearchAlgorithm._singleton();
  YoutubeExplode _ytbE = YoutubeExplode();

  factory SearchAlgorithm() {
    return _instance;
  }

  // Future<YTB.YouTubeApi> _login() async {
  //   Map<dynamic, dynamic> infos = await APIAuth.loginWithoutAllScopes();
  //   var _httpClient = infos.entries.first.key;
  //   return YTB.YouTubeApi(_httpClient);
  // }


  String _findVideoId(Map json, {String title, String artist}) {

    String videoId;
    String videoTitle;
    String songIdType;
    int arrayNumber;

    try {
      if(json['contents']['sectionListRenderer'] != null) {

        if(json['contents']['sectionListRenderer']['contents'][0]['musicShelfRenderer'] == null) {
          arrayNumber = 1;
        } else {
          arrayNumber = 0;
        }

        songIdType = json['contents']['sectionListRenderer']['contents'][arrayNumber]['musicShelfRenderer']
          ['contents'][0]['musicResponsiveListItemRenderer']
          ['flexColumns'][1]['musicResponsiveListItemFlexColumnRenderer']['text']['runs'][0]['text'];

        if(songIdType == 'Song') {
          videoId
          = json['contents']['sectionListRenderer']['contents'][arrayNumber]['musicShelfRenderer']['contents'][0]['musicResponsiveListItemRenderer']
          ['overlay']['musicItemThumbnailOverlayRenderer']['content']['musicPlayButtonRenderer']['playNavigationEndpoint']['watchEndpoint']
          ['videoId'];
        } else {
          videoTitle
          = json['contents']['sectionListRenderer']['contents'][arrayNumber+1]['musicShelfRenderer']['contents'][0]['musicResponsiveListItemRenderer']
          ['flexColumns'][0]['musicResponsiveListItemFlexColumnRenderer']['text']['runs'][0]['text'];

          if(videoTitle.contains(title) || videoTitle.contains(title.toLowerCase()) || videoTitle.contains(title.toUpperCase())) {
            videoId
            = json['contents']['sectionListRenderer']['contents'][arrayNumber+1]['musicShelfRenderer']['contents'][0]['musicResponsiveListItemRenderer']
            ['overlay']['musicItemThumbnailOverlayRenderer']['content']['musicPlayButtonRenderer']['playNavigationEndpoint']['watchEndpoint']
            ['videoId'];
          } else {
            videoId
            = json['contents']['sectionListRenderer']['contents'][arrayNumber]['musicShelfRenderer']['contents'][0]['musicResponsiveListItemRenderer']
            ['overlay']['musicItemThumbnailOverlayRenderer']['content']['musicPlayButtonRenderer']['playNavigationEndpoint']['watchEndpoint']
            ['videoId'];
          }

        }

      } else {

        if(json['contents']['tabbedSearchResultsRenderer']['tabs'][0]['tabRenderer']['content']['sectionListRenderer']
          ['contents'][0]['musicShelfRenderer'] == null) {
          arrayNumber = 1;
        } else {
          arrayNumber = 0;
        }

        songIdType = json['contents']['tabbedSearchResultsRenderer']['tabs'][0]['tabRenderer']['content']['sectionListRenderer']
          ['contents'][arrayNumber]['musicShelfRenderer']['contents'][0]['musicResponsiveListItemRenderer']
          ['flexColumns'][1]['musicResponsiveListItemFlexColumnRenderer']['text']['runs'][0]['text'];

        if(songIdType == 'Song') {
          videoId
          = json['contents']['tabbedSearchResultsRenderer']['tabs'][0]['tabRenderer']['content']['sectionListRenderer']
          ['contents'][arrayNumber]['musicShelfRenderer']['contents'][0]['musicResponsiveListItemRenderer']
          ['overlay']['musicItemThumbnailOverlayRenderer']['content']['musicPlayButtonRenderer']['playNavigationEndpoint']['watchEndpoint']
          ['videoId'];
        } else {
          videoTitle
          = json['contents']['tabbedSearchResultsRenderer']['tabs'][0]['tabRenderer']['content']['sectionListRenderer']
          ['contents'][1]['musicShelfRenderer']['contents'][0]['musicResponsiveListItemRenderer']
          ['flexColumns'][0]['musicResponsiveListItemFlexColumnRenderer']['text']['runs'][0]['text'];

          if(videoTitle.contains(title) || videoTitle.contains(title.toLowerCase()) || videoTitle.contains(title.toUpperCase())) {
            videoId
            = json['contents']['tabbedSearchResultsRenderer']['tabs'][0]['tabRenderer']['content']['sectionListRenderer']
            ['contents'][arrayNumber+1]['musicShelfRenderer']['contents'][0]['musicResponsiveListItemRenderer']
            ['overlay']['musicItemThumbnailOverlayRenderer']['content']['musicPlayButtonRenderer']['playNavigationEndpoint']['watchEndpoint']
            ['videoId'];
          } else {
            videoId
            = json['contents']['tabbedSearchResultsRenderer']['tabs'][0]['tabRenderer']['content']['sectionListRenderer']
            ['contents'][arrayNumber]['musicShelfRenderer']['contents'][0]['musicResponsiveListItemRenderer']
            ['overlay']['musicItemThumbnailOverlayRenderer']['content']['musicPlayButtonRenderer']['playNavigationEndpoint']['watchEndpoint']
            ['videoId'];
          }

        }
      }
    } catch(e) {
      videoId = null;
    }

    return videoId;

  }



  Future<Track> search({@required String tArtist, @required String tTitle, @required Duration tDuration}) async {
    // _youtubeApi = await login();
    String query = '$tArtist $tTitle';
    print('Query : $query');

    final jsonBody = jsonEncode(
      {
        "context": {
          "client": {
            "hl": 'en', //Platform.localeName.substring(3,5).toLowerCase(),
            "gl": 'FR', //Platform.localeName.substring(3,5),
            "deviceMake":"",
            "deviceModel":"",
            "clientName":"WEB_REMIX",
            "clientVersion":"1.20210712.00.00",
            "originalUrl":"https://music.youtube.com/",
            "clientFormFactor":"UNKNOWN_FORM_FACTOR",
            "screenWidthPoints":623,"screenHeightPoints":722,"screenPixelDensity":1,"screenDensityFloat":1.25,"utcOffsetMinutes":120,
            "userInterfaceTheme":"USER_INTERFACE_THEME_DARK",
            "musicAppInfo": {
              "pwaInstallabilityStatus":"PWA_INSTALLABILITY_STATUS_UNKNOWN",
              "webDisplayMode":"WEB_DISPLAY_MODE_BROWSER",
              "musicActivityMasterSwitch":"MUSIC_ACTIVITY_MASTER_SWITCH_INDETERMINATE",
              "musicLocationMasterSwitch":"MUSIC_LOCATION_MASTER_SWITCH_INDETERMINATE"
            }
          },
          "user": {"lockedSafetyMode":false},
          "request":{
            "useSsl":true,
            "internalExperimentFlags":[{"key":"force_route_music_watch_next_ads_to_ywfe","value":"true"}],
            "consistencyTokenJars":[]
          }
        },
        "query": query,
        "suggestStats": {
          "validationStatus":"VALID",
          "parameterValidationStatus":"VALID_PARAMETERS",
          "clientName":"youtube-music",
          "searchMethod":"ENTER_KEY",
          "inputMethod":"KEYBOARD",
          "originalQuery": query,
          "availableSuggestions":[
            {"index":0,"type":0},
            {"index":1,"type":0},
            {"index":2,"type":0},
            {"index":3,"type":0},
            {"index":4,"type":0},
            {"index":5,"type":0},
            {"index":6,"type":0}
          ],
          "zeroPrefixEnabled":true,"firstEditTimeMsec":5821,"lastEditTimeMsec":14828
        }
      }
    );

    try {
      http.Response response = await http.post(
        Uri.https('music.youtube.com', '/youtubei/v1/search',
          {
            'key': 'AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30'  // Google himself api key
          }
        ),
        body: jsonBody,
        headers: {
          HttpHeaders.refererHeader: 'https://music.youtube.com/',
          HttpHeaders.contentTypeHeader: 'application/json'
        },
      );

      Map jsonResponse = jsonDecode(response.body);

      String videoId = _findVideoId(jsonResponse, title: tTitle, artist: tArtist);
      
      if(videoId != null) {

        Video video = await _ytbE.videos.get(videoId);

        String name = video.title;
        String artist = video.author;
        if(artist.contains(' - Topic')) artist = artist.split(' - Topic')[0];
        // print('Track found : $name $artist');

        String id = videoId;
        String imageUrlLittle = video.thumbnails.highResUrl;
        String imageUrlLarge;
        try {
          imageUrlLarge = video.thumbnails.maxResUrl;
        } catch(e) {
          imageUrlLarge = 'https://source.unsplash.com/random';
        }
        Duration duration = video.duration;

        Track track = Track(
          id: id,
          title: name,
          artist: artist,
          imageUrlLittle: imageUrlLittle,
          imageUrlLarge: imageUrlLarge,
          totalDuration: duration,
          service: ServicesLister.YOUTUBE
        );

        return track;
      }

    } catch(e, trace) {
      print(e);
      print(trace);
    }
    
    return Track(id: null);

  }


}