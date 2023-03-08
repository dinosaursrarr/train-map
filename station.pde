//trainMap
//February 2013
//Tom Curtis
//
//Released under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported licence
//http://creativecommons.org/licenses/by-nc-sa/3.0/

//imported from an .MSN file 
class station {
  ArrayList<String> names; //can have more than one name, so store them all
  String displayName;
  char cate; //0= not an interchange, 1 = small interchange, 2=medium interchange, 3=large interchange, 9=subsidiary tiploc at a bigger station
  ArrayList<String> tiplocs; //can have more than one timing point location code per station
  String subsidiaryCRS; // can have more than one subsidiary CRS code per station
  String mainCRS; //principal crs code for the location
  int easting; //OS Grid location
  int northing; //OS Grid location
  PVector screen; //store screen coordinates so you don't have to work it out each frame
  boolean onScreen; //is it on screen or not? only update when changed
  stationLabel label; //reference to the label (if any) to speed things up
  int trainCount; //how many trains stop there?
  float scale; //how big to draw the circle, in that mode
  
  station (String MSN) {
    //extract info from various substrings in the line
    String firstName = trim(MSN.substring(4, 35));
    names = new ArrayList();
    names.add(firstName);
    cate = MSN.charAt(35);
    tiplocs = new ArrayList<String>();
    String firstTiploc = trim(MSN.substring(36, 43));
    tiplocs.add(firstTiploc);
    subsidiaryCRS = trim(MSN.substring(43, 47));
    mainCRS = trim(MSN.substring(49, 52));
    easting = 100 * int(MSN.substring(53, 57));
    northing = 100 * int(MSN.substring(59, 63));
    screen = screenCoordinates(easting, northing);
    onScreen = onScreen(this);
    trainCount = 0;
    displayName = titleCase(firstName).replace("<", "(").replace(">", ")");
    
    station crsStation = stations.getCRS(mainCRS);
    if (crsStation == null) {
      stations.putCRS(mainCRS, this);
      stations.putTiploc(firstTiploc, this);
    }
    else {
      crsStation.names.add(firstName);
      crsStation.tiplocs.add(firstTiploc);
      if (crsStation.mainCRS.equals(subsidiaryCRS)) {
        if (displayName.length() < crsStation.displayName.length()) {
          crsStation.displayName = displayName;
        }
      }
      stations.putTiploc(firstTiploc, crsStation);
    }
  }
  
  //add a label for the station
  void addLabel(String tooltip) {
    //if there isn't already a label, add one
    if (label == null) {
      label = new stationLabel(this);
    }
    else {
      //if there's already a label, update its start time so it hangs around
      label.creationTime = millis();
    }
  }
  
  //helper function so we can call a default
  void addLabel() {
    addLabel("");
  }
}

//make a class that's basically just a hashmap, so we can call methods on it
class stationList {
  private HashMap<String, station> crsIndex;
  private HashMap<String, station> tiplocIndex;
  int busiest;
  
  stationList(int capacity) {
    crsIndex = new HashMap<String, station>(capacity);
    tiplocIndex = new HashMap<String, station>(capacity);
    busiest = 1;
  }

  stationList() {
    crsIndex = new HashMap<String, station>();
    tiplocIndex = new HashMap<String, station>();
    busiest = 1;
  }
  
  void putCRS(String k, station v) {
    crsIndex.put(k, v);
  }
  
  void putTiploc(String k, station v) {
    tiplocIndex.put(k, v);
  }
  
  int crsSize() {
    return crsIndex.size();
  }
  
  int tiplocSize() {
    return tiplocIndex.size();
  }
  
  station getTiploc(String searchTiploc) {
    station result = (station)tiplocIndex.get(searchTiploc);
    if (result != null) {
      return result;
    }
    //if you can't get it in a straight forward way, only then check all the subsidiary ones
   else {
      Iterator i = crsIndex.values().iterator();
      while (i.hasNext()) {
        result = (station)i.next();
        for (int j = 0; j < result.tiplocs.size(); j++) {
          String thisTiploc = (String)result.tiplocs.get(j);
          if (thisTiploc.equals(searchTiploc)) {
            return result;
          }
        }
      }
    }
    return null;
  }
  
 //crs codes aren't unique -> so if you give one, should get a set of stations back
  station getCRS(String searchCRS) {
    return crsIndex.get(searchCRS);
  }

  //find stations by name -> don't want to have two references to the same station in the hashmap because we loop over it, and it's only needed at the very start
  station getName(String name) {
    Iterator i = crsIndex.values().iterator();
    while (i.hasNext()) {
      station thisStation = (station)i.next();
      for (int j = 0; j < thisStation.names.size(); j++) {
        String thisName = thisStation.names.get(j); //check all the names for all the stations till you find the right one
        if (name.equals(thisName)) {
          return thisStation;
        }
      }
    }
    return null;
  }

  //go through all the stations and update their screen locations
  void updateScreen() {
    Iterator i = crsIndex.values().iterator();
    while (i.hasNext()) {
      station thisStation = (station)i.next();
      thisStation.screen = screenCoordinates(thisStation.easting, thisStation.northing);
      thisStation.onScreen = onScreen(thisStation);
    }
  }
  
  void updateScales() {
    Iterator i = crsIndex.values().iterator();
    while (i.hasNext()) {
      station thisStation = (station)i.next();
      thisStation.scale = map(thisStation.trainCount, 0, busiest, minStationRadius.value, maxStationRadius.value);
    }
  }
  
  void draw() {
    ArrayList tooltipStations = new ArrayList();
    Iterator i = crsIndex.values().iterator();
    stroke(stationColour.value);
    while (i.hasNext()) {
      station thisStation = (station)i.next();
      if (thisStation.cate != '9') { //ignore subsidiary stations
        if (thisStation.onScreen) { //only bother with ones on the screen
          noFill();//drawing conditions
          if (scaleStation.value) {
            strokeWeight(thisStation.scale); 
          }
          else {
            strokeWeight(normalStationRadius.value);
          }
          point(thisStation.screen.x, thisStation.screen.y); //draw a point
          //if the mouse is near stations, make a force-directed label
          if ((drawStationLabels.value) && (abs(thisStation.screen.x - mouseX) <= labelMouseRange.value) && (abs(thisStation.screen.y - mouseY) <= labelMouseRange.value)) {
            thisStation.addLabel(); //add/update the label
          }
        }
      }
    }
  }
}
