map = undefined
infowindow = undefined
numberLabels = 0
markers = []

getQ = ->
  $('[map-wrapper]').data('q')

getMarkerUrl = ->
  $('[map-wrapper]').data('icon-url')

initMap = ->
  new (google.maps.Map)(document.getElementById('map'),
  center:
    lat: -34.397
    lng: 150.644
  scrollwheel: true
  zoom: 15)

setMapOnAll = (map) ->
  i = 0
  while i < markers.length
    markers[i].setMap map
    i++

clearTable = ->
  $('.js-sect-view-search-table-tr-listPlace').find('tr:not(:first-child)').remove()
# Removes the markers from the map, but keeps them in the array.

clearMarkers = ->
  setMapOnAll null

FindMyLocation = (map) ->
  clearMarkers()
  numberLabels = 0
  clearTable()
  infoWindow = new (google.maps.InfoWindow)
  if navigator.geolocation
    navigator.geolocation.getCurrentPosition ((position) ->
      pos =
        lat: position.coords.latitude
        lng: position.coords.longitude
      infoWindow.setPosition pos
      map.setCenter pos
      marker = new (google.maps.Marker)(
        map: map
        position: pos
        title: 'Your position'
        icon: 'https://developers.google.com/maps/documentation/javascript/examples/full/images/beachflag.png')
      markers.push(marker)
      infowindow = new google.maps.InfoWindow();
      google.maps.event.addListener marker, 'click', ->
        infowindow.setContent '<div><strong>This Is Your Location</strong><br></div>'
        infowindow.open map, this
      service = new google.maps.places.PlacesService(map);
      service.nearbySearch({
        location: pos,
        radius: 1000,
        type: ['restaurant']
      }, callback);
    ), ->
      handleLocationError true, infoWindow, map.getCenter()
  else
    handleLocationError false, infoWindow, map.getCenter()
handleLocationError = (browserHasGeolocation, infoWindow, pos) ->
  infoWindow.setPosition pos
  infoWindow.setContent if browserHasGeolocation then 'Error: The Geolocation service failed.' else 'Error: Your browser doesn\'t support geolocation.'
  infoWindow.open map

codeAddress = (map) ->
  numberLabels = 0
  geocoder = new (google.maps.Geocoder)
  address = getQ()
  geocoder.geocode { 'address': address }, (results, status) ->
    if status == 'OK'
      map.setCenter results[0].geometry.location
      marker = new (google.maps.Marker)(
        map: map
        position: results[0].geometry.location
        title: 'Your position'
        icon: 'https://developers.google.com/maps/documentation/javascript/examples/full/images/beachflag.png')
      markers.push(marker)
      infowindow = new google.maps.InfoWindow();
      google.maps.event.addListener marker, 'click', ->
        infowindow.setContent '<div><strong>This Is Your Location</strong><br></div>'
        infowindow.open map, this
      service = new google.maps.places.PlacesService(map);
      service.nearbySearch({
        location: results[0].geometry.location,
        radius: 1000,
        type: ['restaurant']
      }, callback);

    else
      alert 'Geocode was not successful for the following reason: ' + status

callback = (results, status , pagination) ->
  if status == google.maps.places.PlacesServiceStatus.OK
    i = 0
    while i < results.length
      createMarker results[i]
      i++
    if pagination.hasNextPage
      moreButton = document.getElementById('js-sect-view-search-more')
      moreButton.disabled = false
      moreButton.addEventListener 'click', ->
        moreButton.disabled = true
        pagination.nextPage()

createMarker = (place) ->
  placeLoc = place.geometry.location
  service = new google.maps.places.PlacesService(map)
  service.getDetails { placeId: place.place_id }, (place, status) ->
    if status == google.maps.places.PlacesServiceStatus.OK
      numberLabels++
      marker = new (google.maps.Marker)(
        map: map
        position: placeLoc
        label: numberLabels.toString()
        icon: place.icon )
      markers.push(marker)
      google.maps.event.addListener marker, 'click', ->
        infowindow.setContent '<div><strong>'+place.name + '</strong><br>' + 'Place Rating: ' + place.rating + '<br>'+place.formatted_address+'</div>'
        infowindow.open map, this
      $('.js-sect-view-search-table-tr-listPlace').append '<tr><td>'+numberLabels+'</td><td>'+place.name+'</td><td>'+place.vicinity+'</td><td>'+place.types+'</td></tr>'



ready =->
  if ($('.js-sect-view-search-table-tr-listPlace').length)
    console.log(getQ())
    q = getQ()
    map = initMap()
    codeAddress(map)
    $('#js-sect-view-search-myLocation').click ->
      FindMyLocation(map)



$(document).on 'turbolinks:load', ready
