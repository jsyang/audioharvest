audioharvest
============
Grab YouTube playlists and turn them into MP3 playlists for my ancient Blackberry Bold 9700

0.  *Requirements*  
    node  
    coffeescript  
    ffmpeg (within $PATH)

1. `./runServer`

2. Use the bookmarklet:  
    
    `javascript:!(function(){var e=window.location.search;e=e.substr(e.indexOf("list=")+5);e=e.split("&")[0];if(e.indexOf("PL")===0){e=e.substr(2)}var t=new XMLHttpRequest;t.open("GET","http://localhost:8888/?playlistID="+e,true);t.send();t.onreadystatechange=function(){if(t.readyState===4&&t.status===200){console.log("Request was received successfully!")}}})()`

3. Navigate to your playlist. Then click the bookmarklet to send the playlist info to the server.

4. Server begins fetching FLVs ~ 192 kbps bitrate audio (with itag 18).

5. Converts FLVs into MP3s with `ffmpeg`.

6. MP3s end up inside MP3 folder.

7. .M3U MP3 playlist is created with relative path.

8. Move these into the SD card for Blackberry.  
   Play them on shuffle and voila: offline playlist!