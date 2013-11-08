http   = require('http')
ytdl   = require('ytdl')
fs     = require('fs')
url    = require('url')
xml2js = require('xml2js')
child_process = require('child_process')

_playlist = []
_res = null

downloadVideo = (videoObj) ->
  console.log("Downloading #{videoObj.title}...")
  filename = "flv/#{videoObj.title}.flv"
  
  dl = ytdl(videoObj.url, { quality : 18 })

  dl.on(
    'end',
    =>
      console.log('Done.')
      dl.removeAllListeners()
      process.nextTick(global.downloadPlaylist)
  )
  
  dl.on(
    'error', 
    (err) =>
      console.log(err)
      dl.removeAllListeners()
      process.nextTick(global.downloadPlaylist)
  )
  
  dl.pipe(fs.createWriteStream(filename))
  
  
convertVideoToMP3 = ->
  child_process.exec(
    './convert',
    { cwd : './' },
    ->
      console.log('Converted!')
      moveMP3s()
      _res?.end()
  )

moveMP3s = ->
  child_process.exec(
    'mv flv/*.mp3 mp3/',
    { cwd : './' },
    ->
      generateM3U()
  )

generateM3U = ->
  console.log('Generating M3U playlist...')
  child_process.exec(
    './makeM3U',
    { cwd : './' },
    ->
      console.log('Done! Your playlist is ready.');
  )
  
global.downloadPlaylist = ->
  nextVideo = _playlist.shift()
  if nextVideo?
    downloadVideo(nextVideo)
  else
    console.log("Playlist is fully downloaded!")
    console.log('Converting FLV to audio...')
    convertVideoToMP3()
      
handlePlaylistDownloadRequest = (req, res) ->
  # todo: handle queuing up multiple youtube playlists
  _res = res
  
  # CORS
  res.writeHead(200, {
    'Access-Control-Allow-Origin'  : '*'
    'Access-Control-Allow-Methods' : 'GET,PUT,POST,DELETE,OPTIONS'
  })
  
  if !(req.url?)
    res.end()
    return
  
  GET = url.parse(req.url, true).query
  
  console.log("Received request for '#{GET.playlistID}'...")
  
  # http://stackoverflow.com/questions/4607855/getting-videos-from-a-users-playlist-youtube-api
  http.get(
    "http://gdata.youtube.com/feeds/api/playlists/#{GET.playlistID}",
    (getRes) ->
      xmlString = ''
      getRes.on('data', (chunk) -> xmlString += chunk)
      getRes.on('end', ->
        xml2js.parseString(
          xmlString,
          (err, result) ->
            _playlist = []
            (
              url = obj['media:group'][0]['media:player'][0]['$']['url']
              title = obj['media:group'][0]['media:title'][0]['_']
              
              #console.dir(obj)
              
              _playlist.push({
                url
                title
              })
            ) for obj in result.feed.entry
            
            console.log("Found #{_playlist.length} items in this playlist.")
            
            # Defer
            process.nextTick(global.downloadPlaylist)
        )
      )
  )

_port = 8888
  
http
    .createServer()
    .listen(_port, 'localhost')
    .on(
      'request',
      handlePlaylistDownloadRequest
    )

console.log("Audio Harvest Server listening on port #{_port}...")