var http = require('http');


// Rotten tomatoes search API settings
var apikey = '88c6ww77pac55ybxsn5dmhqp'
var itemToSearch = encodeURIComponent(process.argv[2])
var options = {
    host: 'api.rottentomatoes.com',
    path: '/api/public/v1.0/movies.json?q=' + itemToSearch + '&page_limit=9&page=1&apikey=' + apikey
}


var processRatings = function(rating) {

  var critics = ''
  var audience = ''
  if(rating.critics_score <= 0){
    critics = 'Critics: no consensus yet'
    if(rating.audience_score <= 0){
      audience = 'Audience: no consensus yet'
    }
    else audience = 'Audience: ' + rating.audience_score + '% want to see it'  
  } 
  else
  {
    critics = 'Critics: ' + rating.critics_score + '%'
    if(rating.audience_score <= 0){
      audience = 'Audience: no consensus yet'
    }
    else audience = 'Audience: ' + rating.audience_score + '% liked it'  
  }

  return critics + ', ' + audience;
}

var getIcon = function(ratings) {
  if(ratings.critics_score > 90)
    return "fresh.png"
  if(ratings.critics_score > 50)
    return "good.png"
  if(ratings.critics_score > 0)
    return "rotten.png"
  return "noidea.png"
}

// Send a request on to RT and form the results in
// Alfred friendly XML
var request = http.request(options, function (res) {
    var data = '';
    var results = [];
    res.on('data', function (chunk) {
        data += chunk.toString();
    });
    res.on('end', function () {

      results = JSON.parse(data);
        
        
      // Generate the search filter XML
      var xml = '<?xml version="1.0"?>'
      xml += '<items>'
      for(var i=0; i < results.movies.length; i++){
        var movie = results.movies[i]

/*
{ critics_rating: 'Rotten',
  critics_score: 44,
  audience_rating: 'Upright',
  audience_score: 74 }
*/

        var item =   '<item uid="%UID%" arg="%ARG%">\
<title>%TITLE%</title>\
<subtitle>%SUBTITLE%</subtitle>\
<icon>%ICON%</icon>\
</item>'

        item = item.replace('%UID%', movie.id)
        item = item.replace('%ARG%',movie.links.alternate)
        item = item.replace('%TITLE%',movie.title + ' [' + (movie.year == '' ? 'upcoming' : movie.year) + ']')
        item = item.replace('%SUBTITLE%', processRatings( movie.ratings ))
        item = item.replace('%ICON%', getIcon(movie.ratings))

        xml += item
      }

      if(results.movies.length == 0)
      {
         var item =   '<item uid="oops">\
<title>Sorry, no movies found</title>\
<subtitle>Try typing in different or fewer words</subtitle>\
<icon>noidea.png</icon>\
</item>'
        xml += item
      }
      
      xml += '</items>'

      console.log(xml);
    
    });
});


request.on('error', function (e) {
    console.log(e.message);
});

request.end();

