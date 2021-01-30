abstract class PlayersController {

    static getCurrentPlayer() {
      
    }

    static getPreviousPlayer() {

    }

    static getNextPlayer() {
      
    }


    /*  PLAYER CONTROLLER */

    //Play and resume
    play({String url});
    //Pause
    pause();

    //Add url's track to queue
    static queue(String url) {}
    //Skip to the next track in the app's playlist
    static skipNext() {}
    //Skip to the previous track in the app's playlist
    static skipPrevious() {}

    //Seeks to the given position
    seekTo(int milliseconds);
    //Adds to the current position
    seekToRelative(int milliseconds);

    //Toggle shuffle inside the app's playlist
    toggleShuffle();
    //Toggle repeat to the current track
    toggleRepeat();


}