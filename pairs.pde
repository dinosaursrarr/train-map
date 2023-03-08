//trainMap
//February 2013
//Tom Curtis
//
//Released under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported licence
//http://creativecommons.org/licenses/by-nc-sa/3.0/

class stationPair {
  station firstStation;
  station secondStation;
  int trainCount; //how many trains go up it?
  float transparency; //how opaque to draw it?
  float weight; // how think a line would it merit?
  boolean otherLink; //is it a train or another link?

  stationPair(station s1, station s2, boolean oL) {
    trainCount = 1;
    firstStation = s1;
    secondStation = s2;
    otherLink = oL;
  }
}

class stationPairList {
  private ArrayList<stationPair> stationPairs;
  int busiest;

  stationPairList() {
    stationPairs = new ArrayList<stationPair>();
    busiest = 1;
  }
  
  stationPairList(int capacity) {
    stationPairs = new ArrayList<stationPair>(capacity);
    int busiest = 1;
  }

  void add(stationPair p) {
    stationPairs.add(p);
  }

  stationPair get(stationPair thatPair) {
    for (int i = 0; i < stationPairs.size(); i++) {
      stationPair thisPair = (stationPair)stationPairs.get(i);
      if ((thisPair.firstStation.mainCRS.equals(thatPair.firstStation.mainCRS) && (thisPair.secondStation.mainCRS.equals(thatPair.secondStation.mainCRS))) || ((thisPair.firstStation.mainCRS.equals(thatPair.secondStation.mainCRS)) && (thisPair.secondStation.mainCRS.equals(thatPair.firstStation.mainCRS)))) {
        return thisPair;
      }
    }
    return null;
  }

  boolean contains(stationPair thatPair) {
    for (int i = 0; i < stationPairs.size(); i++) {
      stationPair thisPair = (stationPair)stationPairs.get(i);
      //is this pair already in there, either way round -> match tiploc codes
      if ((thisPair.firstStation.mainCRS.equals(thatPair.firstStation.mainCRS) && (thisPair.secondStation.mainCRS.equals(thatPair.secondStation.mainCRS))) || ((thisPair.firstStation.mainCRS.equals(thatPair.secondStation.mainCRS)) && (thisPair.secondStation.mainCRS.equals(thatPair.firstStation.mainCRS)))) {
        return true;
      }
    }
    return false;
  }

  int size() {
    return stationPairs.size();
  }

  //can only do once all loaded up
  void updateScales() {
    for (int i = 0; i < stationPairs.size(); i++) {
      stationPair thisPair = (stationPair)stationPairs.get(i);
      thisPair.transparency = map(thisPair.trainCount, 0, busiest, maxLineTransparency.value, minLineTransparency.value);
      thisPair.weight = map(thisPair.trainCount, 0, busiest, minLineWidth.value, maxLineWidth.value);
    }
  }

  void draw(boolean includeOtherLinks) {
    if (!transparentLine.value) {
      stroke(normalLineColour.value);
    }
    if (!scaleLine.value) {
      strokeWeight(normalLineWidth.value);
    }
    for (int i = 0; i < stationPairs.size(); i++) {
      stationPair thisPair = (stationPair)stationPairs.get(i);
      //don't draw to bottom right corner if told not to
      if (ignoreZeroLocations.value && ((thisPair.firstStation.easting == 0 && thisPair.firstStation.northing == 0) || (thisPair.secondStation.easting == 0 && thisPair.secondStation.northing == 0))) {
        continue;
      }
      if (!includeOtherLinks && thisPair.otherLink) {
        continue; //don't draw the other links if you tell it not to
      }
      if (thisPair.firstStation.onScreen || thisPair.secondStation.onScreen) {
        if (transparentLine.value) { 
          stroke(red(normalLineColour.value), green(normalLineColour.value), blue(normalLineColour.value), thisPair.transparency);
        }
        if (scaleLine.value) {
          strokeWeight(thisPair.weight);
        }
        line(thisPair.firstStation.screen.x, thisPair.firstStation.screen.y, thisPair.secondStation.screen.x, thisPair.secondStation.screen.y);
      }
    }
  }
}
