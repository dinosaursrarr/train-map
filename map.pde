//trainMap
//February 2013
//Tom Curtis
//
//Released under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported licence
//http://creativecommons.org/licenses/by-nc-sa/3.0/

//map from OS Grid references to screen coordinates
PVector screenCoordinates(float easting, float northing) {
  PVector screen = new PVector();
  //i checked this. now just use it.
  screen.x = (width / 2f) + ((easting - centreOS.x) * zoomFactor.value);
  screen.y = (height / 2f) + ((northing - centreOS.y) * -zoomFactor.value);
  return screen;
}

//helper method -> short cut
PVector screenCoordinates(PVector OSGrid) {
  return screenCoordinates(OSGrid.x, OSGrid.y);
}

//convert from screen back to OSGrid
PVector OSGridCoordinates(PVector screen) {
  float easting = ((screen.x - (width / 2f)) / zoomFactor.value) + centreOS.x;
  float northing = 999999 - (((screen.y - (height / 2f)) / zoomFactor.value) + centreOS.y);
  return new PVector(easting, northing);
}

//helper method - other input
PVector OSGridCoordinates(float x, float y) {
  return OSGridCoordinates(new PVector(x, y));
}

//test if a location is on screen
boolean onScreen(PVector location) {
  if ((location.x < 0) || (location.x > width) || (location.y < 0) || (location.y > height)) {
    return false;
  }
  return true;
}

//test if station is on screen - or shoudl be ignored
boolean onScreen(station station) {
  if ((ignoreZeroLocations.value) && (station.northing == 0) && (station.easting == 0)) { //don't draw the mass in the bottom left corner
    return false;
  }
  return onScreen(station.screen);
}

//test a whole bunch of locations at once
boolean onScreen(ArrayList<station> locations) {
  boolean anyOnScreen = false;
  for (int i = 0; i < locations.size(); i++) {
    station thisLocation = (station)locations.get(i);
    if (thisLocation.onScreen) { //remember, we tagged if it was onscreen or not in the station
      anyOnScreen = true;
      break;
    }
  }
  return anyOnScreen;
}
