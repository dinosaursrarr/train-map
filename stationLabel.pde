//trainMap
//February 2013
//Tom Curtis
//
//Released under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported licence
//http://creativecommons.org/licenses/by-nc-sa/3.0/

//force directed label for each station
class stationLabel {
  String tooltip; //text it contains
  float textWidth; //how wide is the text?
  station station; //which station is it for?
  PVector screen; //where is the centre of it on the screen?
  PVector velocity; //how fast is it moving
  int creationTime; //when was it added to the map?
  PVector topLeft; //where does the box start??
  
  stationLabel(station thisStation) {
    tooltip = thisStation.displayName;
    textWidth = textWidth(tooltip);
    station = thisStation;
    creationTime = millis();
    velocity = new PVector();
    
    //put it a certain distance in the direction of the mouse
    float angle = random(0, 2*PI);
    PVector direction = new PVector(50 * sin(angle), 50 * cos(angle));
    screen = PVector.add(station.screen, direction);
    topLeft = new PVector(screen.x - (textWidth / 2) - 4, screen.y - 12);
    
    stationLabels.add(this);
  }
  
  //repel itself from other locations
  void repel(PVector otherLocation) {
    float d = PVector.dist(screen, otherLocation); //distance to the other one
    float radius = textWidth; //limit on how far the force reaches
    float strength = -1; //tweakable
    float ramp = 0.4; //tweakable
    if (d > 0 && d < radius) { //if in range
      float s = pow(d / radius, 1 / ramp); //no idea how this works -> got it from the Generative Design book
      float f = s * 9 * strength * (1 / (s + 1) + ((s - 3) / 4)) / d;
      PVector df = PVector.sub(screen, otherLocation);
      df.mult(f);
      
      velocity.x -= df.x;
      velocity.y -= df.y;
    }
  }
  
  //is this label overlapping/overlapped by another one?
  boolean overlapping(stationLabel otherLabel) {
    float longestWidth = max(textWidth, otherLabel.textWidth);
      if (abs(topLeft.x - otherLabel.topLeft.x) < (longestWidth + 8)) {
        if (abs(topLeft.y - otherLabel.topLeft.y) < 17) {
          return true; //yes, if top left corners of each are too close
        }
      }
    return false;
  }
  
  //make it force-directed - this is the magic
  void update() {
    //remove if it's too old
    int timeNow = millis();
    if ((timeNow - creationTime) > 1000) {
      station.label = null;
      stationLabels.remove(this);
    }
    
    //repel all other nodes
    boolean foundOverlap = false;
    for (int i = 0; i < stationLabels.size(); i++) {
      stationLabel otherLabel = stationLabels.get(i);
      if (otherLabel == null) { //can't repel a blank label
        break;
      }
      if (otherLabel == this) { //can't repel yourself
        continue;
      }
      repel(otherLabel.screen); //repel other labels in range
      repel(station.screen); //also repel the station -> stretches the label line so it's not blocking the other lines
      
      if (!foundOverlap) { //keep checking if you're overlapping someone until you are, or you run out of ones to check
        if (overlapping(otherLabel)) {
          foundOverlap = true;
        }
      }
    }
    
    //if it's not overlapping anyone, then you can just stop moving around
    if (!foundOverlap) {
      if (PVector.dist(getNearestCorner(), station.screen) > 35) { //so long as the nearest corner is far enough from the station -> wasn't accurate enough when working off the centre point
        velocity = new PVector(0, 0); //STOP!
      }
    }
    
    screen.add(velocity); //get new location!
    
    //stay in the limits of the window
    if ((screen.x - (textWidth / 2) - 4) < 0) {
      screen.x = (textWidth / 2) + 5;
      velocity.x *= -0.5; //bounce off the walls
    }
    if ((screen.x + (textWidth / 2) + 4) > width) {
      screen.x = width - (textWidth / 2) - 5;
      velocity.x *= -0.5;
    }
    if ((screen.y - 12) < 0) {
      screen.y = 13;
      velocity.y *= -0.5;
    }
    if ((screen.y + 12) > height) {
      screen.y = height - 13;
      velocity.y *= -0.5;
    }
    topLeft = new PVector(screen.x - (textWidth / 2) - 4, screen.y - 12); //update top left position
  }
  
  //get the location of the corner of the label box nearest to the station itself 
  PVector getNearestCorner() {
    PVector nearestCorner = new PVector();
    float lowestDistance = 999999;
    float width = textWidth + 8;
    float height = 17;
    //these are the possibilities!
    PVector[] corners = {new PVector(topLeft.x, topLeft.y), new PVector(topLeft.x + width, topLeft.y), new PVector(topLeft.x, topLeft.y + height), new PVector(topLeft.x + width, topLeft.y + height)};
    //test each for length, return the the lowest one
    for (int i = 0; i < corners.length; i++) {
      float distance = PVector.dist(corners[i], station.screen);
      if (distance < lowestDistance) {
        lowestDistance = distance;
        nearestCorner = corners[i];
      }
    } 
    return nearestCorner;
  }
}

class stationLabelList {
  private ArrayList<stationLabel> labels;
  
  stationLabelList(int capacity) {
    labels = new ArrayList<stationLabel>(capacity);
  }
  
  stationLabelList() {
    labels = new ArrayList<stationLabel>();
  }
  
  //have to pass on some of the arraylist methods to the array list
  void add(stationLabel label) {
    labels.add(label);
  }
  
  void remove(stationLabel label) {
    labels.remove(label);
  }
  
  int size() {
    return labels.size();
  }
  
  stationLabel get(int i) {
    return (stationLabel)labels.get(i);
  }
  
  //now some of the interesting methods
  void draw() {
    //draw the lines to the labels first, so they're at the back
    textAlign(CENTER);
    strokeWeight(labelWeight.value);
    stroke(red(stationColour.value), blue(stationColour.value), green(stationColour.value));
    fill(red(stationColour.value), green(stationColour.value), blue(stationColour.value));
    for (int i = 0; i < labels.size(); i++) {
      stationLabel thisLabel = (stationLabel)labels.get(i);
      line(thisLabel.screen.x, thisLabel.screen.y, thisLabel.station.screen.x, thisLabel.station.screen.y);
    }
    //draw the labels themselves
    for (int i = 0; i < labels.size(); i++) {
      stationLabel thisLabel = (stationLabel)labels.get(i);
      fill(red(backGround.value), green(backGround.value), blue(backGround.value));
      rect(thisLabel.screen.x - (thisLabel.textWidth / 2) - 4, thisLabel.screen.y - 12, thisLabel.textWidth + 8, 17);
      fill(red(stationColour.value), green(stationColour.value), blue(stationColour.value));
      text(thisLabel.tooltip, thisLabel.screen.x, thisLabel.screen.y);
      thisLabel.update();
    }
  }
}

String titleCase(String input) {
  input = input.toLowerCase();
  char[] charArray = input.toCharArray();
  for (int i = 0; i < charArray.length - 1; i++) {
    charArray[0] = str(charArray[0]).toUpperCase().charAt(0);
    if ((charArray[i] == ' ') || (charArray[i] == '(') || (charArray[i] == '-')) { //it's a space!
      charArray[i + 1] = str(charArray[i + 1]).toUpperCase().charAt(0);
    }
  }
  
  return new String(charArray).replaceAll("<cie>", "<CIE>").replaceAll("<nir>", "<NIR>").replaceAll("<ns>", "<NS>").replaceAll("<evr>", "<EVR>").replaceAll("<lul>", "<LUL>");
}
