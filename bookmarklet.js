//!
(function(){
    var playlistID = window.location.search;
    playlistID = playlistID.substr(playlistID.indexOf('list=')+5);
    playlistID = playlistID.split('&')[0];
    if(playlistID.indexOf('PL') === 0) {
        playlistID = playlistID.substr(2);
    }
    var xhr = new XMLHttpRequest();
    xhr.open( "GET", 'http://localhost:8888/?playlistID='+playlistID, true );
    xhr.send();
    xhr.onreadystatechange = function(){
        if(xhr.readyState === 4 && xhr.status === 200) {
            console.log('Request was received successfully!');
        }
    };
})();