import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:googleapis/youtube/v3.dart' as YTB;
import 'package:smartshuffle/Controller/ServicesLister.dart';
import 'package:smartshuffle/Model/Object/Track.dart';
import 'package:smartshuffle/Services/youtube/api_auth.dart';
import 'package:smartshuffle/Services/youtube/api_controller.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class SearchAlgorithm {

  SearchAlgorithm._singleton();

  static final SearchAlgorithm _instance = SearchAlgorithm._singleton();
  YTB.YouTubeApi _youtubeApi;
  YoutubeExplode _ytbE = YoutubeExplode();

  factory SearchAlgorithm() {
    return _instance;
  }

  Future<YTB.YouTubeApi> login() async {
    Map<dynamic, dynamic> infos = await APIAuth.loginWithoutAllScopes();
    var _httpClient = infos.entries.first.key;
    return YTB.YouTubeApi(_httpClient);
  }

  int _parseTime(String duration, String timeUnit) {
    final timeMatch = RegExp(r"\d+" + timeUnit).firstMatch(duration);

    if (timeMatch == null) {
      return 0;
    }
    final timeString = timeMatch.group(0);
    return int.parse(timeString.substring(0, timeString.length - 1));
  }
  Duration _toDuration(String isoString) {
    if (!RegExp(
            r"^(-|\+)?P(?:([-+]?[0-9,.]*)Y)?(?:([-+]?[0-9,.]*)M)?(?:([-+]?[0-9,.]*)W)?(?:([-+]?[0-9,.]*)D)?(?:T(?:([-+]?[0-9,.]*)H)?(?:([-+]?[0-9,.]*)M)?(?:([-+]?[0-9,.]*)S)?)?$")
        .hasMatch(isoString)) {
      throw ArgumentError("String does not follow correct format");
    }

    final weeks = _parseTime(isoString, "W");
    final days = _parseTime(isoString, "D");
    final hours = _parseTime(isoString, "H");
    final minutes = _parseTime(isoString, "M");
    final seconds = _parseTime(isoString, "S");

    return Duration(
      days: days + (weeks * 7),
      hours: hours,
      minutes: minutes,
      seconds: seconds,
    );
  }

  Future<Track> search({@required String tArtist, @required String tTitle, @required Duration tDuration}) async {
    // _youtubeApi = await login();
    String query = '$tArtist $tTitle';
    // print('Query : $query');

    http.Response response = await http.get(
      Uri.https('youtube.googleapis.com', '/youtube/v3/search',
        {
          'part': 'snippet',
          'maxResults': '10',
          'q': query,
          'key': 'AIzaSyAa8yy0GdcGPHdtD083HiGGx_S0vMPScDM'  // Google himself api key
        }
      ),
      headers: {
        HttpHeaders.refererHeader: 'https://explorer.apis.google.com',
      },
    );
    
    YTB.SearchListResponse searchList = YTB.SearchListResponse.fromJson(jsonDecode(response.body));

    // YTB.SearchListResponse searchList = await _youtubeApi.search.list(
    //   ['snippet'],
    //   maxResults: 10,
      // eventType: 'completed',
      // safeSearch: 'none',
      // order: 'viewCount',
      // topicId: '/m/04rlf',
      // type: ['video, channel, playlist'],
    //   q: query
    // );

    List<YTB.SearchResult> asr = searchList.items;
    YTB.SearchResult rsr = asr[0];
    
    Duration lastSrDuration;
    Duration srDuration;
    Duration finalDuration;

    int i = 0;
    for(YTB.SearchResult sr in asr) {

      if(i < 3 || (
        sr.snippet.title.contains(tTitle) ||
        sr.snippet.title.contains(tTitle.toLowerCase()) ||
        sr.snippet.title.contains(tTitle.toUpperCase())
       ))
      {
        if(sr.id.videoId != null) {

          // http.Response response = await http.get(
          //   Uri.https('youtube.googleapis.com', '/youtube/v3/videos',
          //     {
          //       'part': 'contentDetails',
          //       'id': sr.id.videoId,
          //       'key': 'AIzaSyAa8yy0GdcGPHdtD083HiGGx_S0vMPScDM'  // Google himself api key
          //     }
          //   ),
          //   headers: {
          //     HttpHeaders.refererHeader: 'https://explorer.apis.google.com',
          //   },
          // );
          
          // YTB.VideoListResponse videoList = YTB.VideoListResponse.fromJson(jsonDecode(response.body));

          // srDuration = _toDuration(videoList.items[0].contentDetails.duration);

          Video video = await _ytbE.videos.get(VideoId(sr.id.videoId));
          srDuration = video.duration;

          if(srDuration.compareTo(tDuration) == 0)
          {
            rsr = sr;
            finalDuration = srDuration;
            break;
          }

          if(lastSrDuration != null) {
            if((srDuration.inSeconds-tDuration.inSeconds).abs() < (lastSrDuration.inSeconds-tDuration.inSeconds).abs()) {
              rsr = sr;
              finalDuration = srDuration;
              lastSrDuration = video.duration;
            }
          } else {
            lastSrDuration = video.duration;
          }
        }
      }

      i++;
    }


    if(finalDuration == null) {
      Video video = await _ytbE.videos.get(asr[0].id.videoId);
      finalDuration = video.duration;
    }



    String name = rsr.snippet.title;
    String artist = rsr.snippet.channelTitle;
    if(artist.contains(' - Topic')) artist = artist.split(' - Topic')[0];
    // print('Track found : $name $artist');

    String id = rsr.id.videoId;
    String imageUrlLittle = rsr.snippet.thumbnails.high.url;
    String imageUrlLarge;
    try {
      imageUrlLarge = rsr.snippet.thumbnails.maxres.url;
    } catch(e) {
      imageUrlLarge = 'https://source.unsplash.com/random';
    }

    Duration duration = finalDuration;

    Track track = Track(
      id: id,
      name: name,
      artist: artist,
      imageUrlLittle: imageUrlLittle,
      imageUrlLarge: imageUrlLarge,
      totalDuration: duration,
      service: ServicesLister.YOUTUBE
    );

    return track;

  }


}