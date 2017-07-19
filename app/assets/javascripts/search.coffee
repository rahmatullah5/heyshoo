map = undefined
infowindow = undefined
numberLabels = 0
markers = []
waypts = []
window.directionsDisplay = new google.maps.DirectionsRenderer()
window.directionsService = new google.maps.DirectionsService()

getQ = ->
  $('[map-wrapper]').data('q')

getMarkerUrl = ->
  $('[map-wrapper]').data('icon-url')

initMap = ->
  window.map = new (google.maps.Map)(document.getElementById('map'),
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
  $('.js-sect-view-search-table-tr-listPlace').find('tr:not(:nth-child(2),:nth-child(1))').remove()

clearMarkers = ->
  setMapOnAll null

FindMyLocation = (map) ->
  directionsDisplay.setMap null
  clearMarkers()
  clearTable()
  numberLabels = 0
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
        )
      markers.push(marker)
      google.maps.event.addListener marker, 'click', ->
        infowindow.setContent '<div><strong>'+place.name + '</strong><br>' + 'Place Rating: ' + place.rating + '<br>'+place.formatted_address+'</div>'
        infowindow.open map, this
      $('.js-sect-view-search-table-tr-listPlace').append '
        <tr>
          <td>'+numberLabels+'</td>
          <td>'+place.name+'</td>
          <td>'+place.formatted_address+'</td>
          <td>'+place.types+'</td>
          <td><button class="js-sect-view-search-start">Start</button>
              <button class="js-sect-view-search-add">Add Destination</button>
              <button class="js-sect-view-search-end">End</button>
          </td>
        </tr>'


calculateAndDisplayRoute = () ->
  clearMarkers()
  directionsDisplay.setMap map
  directionsService.route {
    origin: $(startDestination).parents('tr').find('td')[2].innerHTML
    destination: $(endDestination).parents('tr').find('td')[2].innerHTML
    waypoints: waypts
    optimizeWaypoints: true
    travelMode: 'DRIVING'
  }, (response, status) ->
    if status == 'OK'
      directionsDisplay.setDirections response
      console.log(response)
    else
      window.alert 'Directions request failed due to ' + status
  waypts = []


onStartClick = ->
  window.startDestination = @
  console.log (startDestination)
  # alert($(startDestination).parents('tr').find('td')[2].innerHTML)

onEndClick = ->
  window.endDestination = @
  console.log (endDestination)
  # alert($(endDestination).parents('tr').find('td')[2].innerHTML)

onAddClick = ->
  window.addDestination = @
  i = 0;
  j = waypts.length
  if waypts.length > 1
    while i < waypts.length
      if waypts[i].location==$(addDestination).parents('tr').find('td')[2].innerHTML
        return
      else
      i++
    waypts.push
      location: $(addDestination).parents('tr').find('td')[2].innerHTML
      stopover: true
  else
    waypts.push
      location: $(addDestination).parents('tr').find('td')[2].innerHTML
      stopover: true
  console.log(waypts)
ready =->
  if ($('.js-sect-view-search-table-tr-listPlace').length)
    console.log(getQ())
    q = getQ()
    # $(document).on 'click', '.js-sect-view-search-start', calculateAndDisplayRoute
    $(document).on 'click', '.js-sect-view-search-start', onStartClick
    $(document).on 'click', '.js-sect-view-search-end', onEndClick
    $(document).on 'click', '.js-sect-view-search-add', onAddClick
    $(document).on 'click', '.js-sect-view-search-setNavigation', calculateAndDisplayRoute
    map = initMap()
    codeAddress(map)
    $('#js-sect-view-search-myLocation').click ->
      FindMyLocation(map)



$(document).on 'turbolinks:load', ready
