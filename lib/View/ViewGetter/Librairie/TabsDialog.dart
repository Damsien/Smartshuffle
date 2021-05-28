


import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:smartshuffle/Controller/Platforms/PlatformsController.dart';
import 'package:smartshuffle/Controller/ServicesLister.dart';
import 'package:smartshuffle/Model/Object/Track.dart';

class TrackInformationDialog extends StatelessWidget {

  final PlatformsController ctrl;
  final Track track;
  final BuildContext dialogContext;

  TrackInformationDialog(this.ctrl, this.track, this.dialogContext);

  @override
  Widget build(BuildContext context) {
    String name = track.name;
    String artist = track.artist;
    String artist_string = AppLocalizations.of(context).globalArtist;
    if(artist.contains(',')) artist_string = AppLocalizations.of(context).globalArtists;
    String album;
    if(track.album != null) album = track.album;
    else album = AppLocalizations.of(context).nothing;
    String service = track.serviceName.toString();

    return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          content: Wrap(
            children: [
              Column(
                children: [
                  Container(
                    width: MediaQuery.of(dialogContext).size.width,
                    height: MediaQuery.of(dialogContext).size.width*0.7,
                    child: Image(image: NetworkImage(track.imageUrlLarge), fit: BoxFit.cover)
                  ),
                  Container(
                    width: MediaQuery.of(dialogContext).size.width,
                    padding: EdgeInsets.all(10),
                    child: Text(AppLocalizations.of(context).popupItemTitle+": $name", style: TextStyle(fontSize: 25))
                  ),
                  Container(
                    width: MediaQuery.of(dialogContext).size.width,
                    padding: EdgeInsets.only(left: 10, top: 5, bottom: 5),
                    child: Text("$artist_string: $artist", style: TextStyle(fontSize: 17))
                  ),
                  Container(
                    width: MediaQuery.of(dialogContext).size.width,
                    padding: EdgeInsets.only(left: 10, top: 5, bottom: 5),
                    child: Text(AppLocalizations.of(context).globalAlbum+": $album", style: TextStyle(fontSize: 17))
                  ),
                  Container(
                    width: MediaQuery.of(dialogContext).size.width,
                    padding: EdgeInsets.only(left: 10, top: 5, bottom: 5),
                    child: Text(AppLocalizations.of(context).globalService+": $service", style: TextStyle(fontSize: 17))
                  ),
                ]
              )
            ]
          ),
          actions: [
            FlatButton(
              child: Text(AppLocalizations.of(context).ok, style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pop(dialogContext),
            ),
          ],
        );
  }

}

class TrackRemoveFromPlaylistDialog extends StatelessWidget {

  final PlatformsController ctrl;
  final Track track;
  final int playlistIndex;
  final Function refresh;
  final Function stateRemoveFromPlaylist;
  final BuildContext dialogContext;

  TrackRemoveFromPlaylistDialog(this.ctrl, this.track, this.playlistIndex, this.refresh, this.stateRemoveFromPlaylist, this.dialogContext);

  @override
  Widget build(BuildContext context) {
    String name = track.name;
    String playlistName = ctrl.platform.playlists.value[playlistIndex].name;

    return AlertDialog(
          title: Text(AppLocalizations.of(context).tabsViewAlreadyExists+" $name "+AppLocalizations.of(context).from+" $playlistName ?", style: TextStyle(color: Colors.white)),
          actions: [
            FlatButton(
              child: Text(AppLocalizations.of(context).cancel, style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pop(dialogContext),
            ),
            FlatButton(
              child: Text(AppLocalizations.of(context).confirm, style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.pop(dialogContext);
                int trackIndex = ctrl.platform.playlists.value[playlistIndex].getTracks().indexOf(track);
                this.stateRemoveFromPlaylist(ctrl, playlistIndex, trackIndex, refresh);
              },
            ),
          ],
          backgroundColor: Colors.grey[800],
        );
  }

}

class TrackAddToPlaylistDialog extends StatelessWidget {

  final PlatformsController ctrl;
  final Track track;
  final Function addToPlaylist;
  final BuildContext dialogContext;

  TrackAddToPlaylistDialog(this.ctrl, this.track, this.addToPlaylist, this.dialogContext);

  @override
  Widget build(BuildContext context) {
    String name = track.name;
    String ctrlName = ctrl.platform.name;

    return AlertDialog(
      title: Text('$name', style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            child: FlatButton(
              child: Text(AppLocalizations.of(context).tabsViewAddToService+" SmartShuffle", style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.pop(dialogContext);
                addToPlaylist(PlatformsLister.platforms[ServicesLister.DEFAULT], track);
              },
            ),
          ),
          () {
            if(ctrl.platform.name != PlatformsLister.platforms[ServicesLister.DEFAULT].platform.name) {
              return Container(
                child: FlatButton(
                  child: Text(AppLocalizations.of(context).tabsViewAddToService+" $ctrlName", style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    addToPlaylist(ctrl, track);
                  },
                ),
              );
            }
            return Container();
          }.call(),
          Container(
            child: FlatButton(
              child: Text(AppLocalizations.of(context).cancel, style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pop(dialogContext),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[800],
    );
  }

}

// ignore: must_be_immutable
class TrackChoosePlaylistDialog extends StatelessWidget {

  final PlatformsController ctrl;
  List<Widget> allCards;
  final Track track;
  final Function addToPlaylist;
  final BuildContext dialogContext;

  TrackChoosePlaylistDialog(this.ctrl, this.allCards, this.track, this.addToPlaylist, this.dialogContext);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).tabsViewChooseAPlaylist, style: TextStyle(color: Colors.white)),
      contentPadding: EdgeInsets.all(0),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: () {
            allCards = List.generate(
              ctrl.platform.playlists.value.length,
              (index) {

                if(ctrl.platform.playlists.value[index].ownerId == ctrl.getUserInformations()['ownerId']) {
                  return ListTile(
                            title: Text(ctrl.platform.playlists.value[index].name),
                            leading: FractionallySizedBox(
                              heightFactor: 0.8,
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Container(
                                  decoration: new BoxDecoration(
                                    image: new DecorationImage(
                                      fit: BoxFit.cover,
                                      alignment: FractionalOffset.center,
                                      image: NetworkImage(ctrl.platform.playlists.value[index].imageUrl),
                                    )
                                  ),
                                ),
                              )
                            ),
                            subtitle: Text(ctrl.platform.playlists.value[index].getTracks().length.toString() + " "+AppLocalizations.of(context).globalTracks),
                            onTap: () {
                              Navigator.pop(dialogContext);
                              String id = ctrl.addTrackToPlaylist(index, track, false);
                              if(id == null) {
                                showDialog(
                                  context: context,
                                  builder: (dialogContext1) {
                                    return AlertDialog(
                                      title: Text(AppLocalizations.of(context).tabsViewTrackAlreadyExists, style: TextStyle(color: Colors.white)),
                                      actions: [
                                        FlatButton(
                                          child: Text(AppLocalizations.of(context).no, style: TextStyle(color: Colors.white)),
                                          onPressed: () => Navigator.pop(dialogContext1),
                                        ),
                                        FlatButton(
                                          child: Text(AppLocalizations.of(context).yes, style: TextStyle(color: Colors.white)),
                                          onPressed: () {
                                            Navigator.pop(dialogContext1);
                                            addToPlaylist(ctrl, index, track);
                                          },
                                        )
                                      ],
                                      backgroundColor: Colors.grey[800],
                                    );
                                  }
                                );
                              }
                            },
                  );
                }
                return Container();
              }
            );
            allCards.add(
              Container(
                child: FlatButton(
                  child: Text(AppLocalizations.of(context).cancel, style: TextStyle(color: Colors.white)),
                  onPressed: () => Navigator.pop(dialogContext),
                ),
              ),
            );
            return allCards;
          }.call()
        )
      ),
      backgroundColor: Colors.grey[900],
    );
  }
  
}