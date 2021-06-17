import 'package:flutter/cupertino.dart';
import 'package:googleapis/youtube/v3.dart' as YTB;
import 'package:smartshuffle/Controller/ServicesLister.dart';
import 'package:smartshuffle/Model/Object/Track.dart';
import 'package:smartshuffle/Services/youtube/api_auth.dart';
import 'package:smartshuffle/Services/youtube/api_controller.dart';

class SearchAlgorithm {

  SearchAlgorithm._singleton();

  static final SearchAlgorithm _instance = SearchAlgorithm._singleton();
  YTB.YouTubeApi _youtubeApi;

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
    _youtubeApi = await login();
    String query = '$tArtist $tTitle';
    print(query);
    YTB.SearchListResponse searchList = await _youtubeApi.search.list(
      ['snippet'],
      maxResults: 10,
      // eventType: 'completed',
      // safeSearch: 'none',
      // order: 'viewCount',
      // topicId: '/m/04rlf',
      // type: ['video, channel, playlist'],
      q: query
    );

    List<YTB.SearchResult> asr = searchList.items;
    YTB.SearchResult rsr = asr[0];
    
    Duration lastSrDuration;
    Duration srDuration;

    int i = 0;
    for(YTB.SearchResult sr in asr) {

      if(i < 3 || (
        sr.snippet.title.contains(tTitle) ||
        sr.snippet.title.contains(tTitle.toLowerCase()) ||
        sr.snippet.title.contains(tTitle.toUpperCase())
       ))
      {
        if(sr.id.videoId != null) {
          YTB.VideoListResponse response = await _youtubeApi.videos.list(
            ['contentDetails'],
            id: [sr.id.videoId]
          );
          srDuration = _toDuration(response.items[0].contentDetails.duration);

          if(srDuration.compareTo(tDuration) == 0)
          {
            rsr = sr;
            break;
          }

          if(lastSrDuration != null) {
            if((srDuration.inSeconds-tDuration.inSeconds).abs() < (lastSrDuration.inSeconds-tDuration.inSeconds).abs()) {
              rsr = sr;
              lastSrDuration = _toDuration(response.items[0].contentDetails.duration);
            }
          } else {
            lastSrDuration = _toDuration(response.items[0].contentDetails.duration);
          }
        }
      }

      i++;
    }
    
    String name = rsr.snippet.title;
    String artist = rsr.snippet.channelTitle;
    if(artist.contains(' - Topic')) artist = artist.split(' - Topic')[0];

    String id = rsr.id.videoId;
    String imageUrlLittle = rsr.snippet.thumbnails.high.url;
    String imageUrlLarge;
    try {
      imageUrlLarge = rsr.snippet.thumbnails.maxres.url;
    } catch(e) {
      imageUrlLarge = 'https://source.unsplash.com/random';
    }

    YTB.VideoListResponse response = await _youtubeApi.videos.list(
      ['contentDetails'],
      id: [id]
    );
    Duration duration = _toDuration(response.items[0].contentDetails.duration);

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