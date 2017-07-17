map = undefined
infowindow = undefined

getQ = ->
  $('[map-wrapper]').data('q')

initMap = ->
  new (google.maps.Map)(document.getElementById('map'),
  center:
    lat: -34.397
    lng: 150.644
  scrollwheel: false
  zoom: 8)

codeAddress = (map) ->
  geocoder = new (google.maps.Geocoder)
  address = getQ()
  geocoder.geocode { 'address': address }, (results, status) ->
    if status == 'OK'
      map.setCenter results[0].geometry.location
      marker = new (google.maps.Marker)(
        map: map
        position: results[0].geometry.location)
    else
      alert 'Geocode was not successful for the following reason: ' + status

callback = (results, status) ->
  if status == google.maps.places.PlacesServiceStatus.OK
    i = 0
    while i < results.length
      createMarker results[i]
      i++

createMarker = (place) ->
  placeLoc = place.geometry.location
  marker = new (google.maps.Marker)(
    map: map
    position: place.geometry.location)
  google.maps.event.addListener marker, 'click', ->
    infowindow.setContent place.name
    infowindow.open map, this


# requestPlace = ->
#       # response = HTTP.get("https://maps.googleapis.com/maps/api/place/textsearch/json?query=restaurant+in+"+getQ()+"&key=AIzaSyAXqvCTXPvZc5xNHQcRm4jqyLPsuw3JA_0")
#       response = HTTP.get("https://maps.googleapis.com/maps/api/place/textsearch/json?query="+getQ()+"&key=AIzaSyAXqvCTXPvZc5xNHQcRm4jqyLPsuw3JA_0")
#       parsed_response = JSON.parse(response.body)
ready =->
  if ($('.js-sect-view-search').length)
    console.log(getQ())
    q = getQ()
    map = initMap()
    codeAddress(map)
    callback()
    createMarker(map)
$(document).on 'turbolinks:load', ready
