//trainMap
//February 2013
//Tom Curtis
//
//Released under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported licence
//http://creativecommons.org/licenses/by-nc-sa/3.0/

//import to make hashmap work properly
import java.util.Iterator;

//set the mode
boolean trainSimulator = true;
boolean loadOtherLinks = false;
asynchronousLoader MCAloader;
asynchronousLoader ZTRloader;

//input and output variables
String movieOutput; //where to save frames?
String screenshotOutput; //where to save screenshots?
PFont BRailFont; //British Rail typeface (http://www.rmweb.co.uk/forum/viewtopic.php?f=5&t=20822)
String MCAFile; //file containing main train database
String ZTRFile; //file with other train data
String MSNFile; //file with station data
String ALFFile; //file with other links data
int MCAcount = -1; //how many trains to load from MCA file?
int ZTRcount = -1; //how many trains to load from ZTR file?
boolean selectedConfig = false; //flag to make the program wait for you to choose input/output
boolean selectedTimetable = false; //flag to make the program wait for you to choose input/output
boolean selectedScreenshot = false; //flag to make the program wait for you to choose input/output
boolean selectedFrames = false; //flag to make the program wait for you to choose input/output
String screenshotType = "jpg"; //file format for screenshots
String frameType = "tif"; //file format for movie films

//map controls
PVector defaultCentreOS = new PVector(350000, 500000);
PVector centreOS = new PVector(defaultCentreOS.x, defaultCentreOS.y); //centre on the OS Grid map //starting detail
float minEasting = -350000; //how far can you move the mouse off the sides?
float maxEasting = 1000000; //how far can you move the mouse off the sides?
float minNorthing = -450000; //how far can you move the mouse off the sides?
float maxNorthing = 1400000; //how far can you move the mouse off the sides?
floatHolder zoomFactor = new floatHolder(0.0005, 0.0005, 0.02); //how much to zoom in - common scale to keep it proportional //starting detail

//station settings
booleanHolder drawStations = new booleanHolder(true); //should they be drawn as points?
booleanHolder ignoreZeroLocations = new booleanHolder(true); //don't bother with the ones in the bottom left corner
booleanHolder scaleStation = new booleanHolder(false); //station size depends on how many trains go there //REALLY BORING
floatHolder normalStationRadius = new floatHolder(3, 0, 30); //if not scaling stations, how big are they?
floatHolder minStationRadius = new floatHolder(1, 0, 30); //if scaling stations, how small can they get?
floatHolder maxStationRadius = new floatHolder(30, 0, 30); //if scaling stations, how big is the biggest?

//line settings
booleanHolder drawLines = new booleanHolder(true); //should the lines be drawn?
booleanHolder scaleLine = new booleanHolder(false); //train line width depends on how many trains go up it
booleanHolder transparentLine = new booleanHolder(false); //train line opacity depends on how many trains go up it
floatHolder minLineTransparency = new floatHolder(255, 0, 255); //if making lines tranparent, maximum opaqueness
floatHolder maxLineTransparency = new floatHolder(50, 0, 255); //if making lines transparent, minimum opaqueness
floatHolder normalLineWidth = new floatHolder(1, 0, 30); //how thick is a section of track when not scaled?
floatHolder minLineWidth = new floatHolder(1, 0, 30); //if scaling lines, minimum thickness
floatHolder maxLineWidth = new floatHolder(30, 0, 30); //if scaling lines, maximum thickness

//colour settings
colourHolder backGround = new colourHolder(color(0)); //colour behind it all
colourHolder defaultBackGround = new colourHolder(color(0));
colourHolder stationColour = new colourHolder(color(255, 255, 255, 125)); //what colour to draw the stations?
colourHolder defaultStationColour = new colourHolder(color(255, 255, 255, 125));
colourHolder normalLineColour = new colourHolder(color(255, 0, 0)); //what colour to draw the lines, when not being transparent
colourHolder trainColour = new colourHolder(color(0, 0, 255, 180)); //what colour to draw each train?

//label settings
booleanHolder drawStationLabels = new booleanHolder(true);
intHolder labelMouseRange = new intHolder(5, 0, 20); //how close can you get to a station before the label pops out?
floatHolder labelWeight = new floatHolder(1, 0, 10); //how thick is the line between label and station?

//train settings
booleanHolder drawTrains = new booleanHolder(true); //should you draw the trains?
floatHolder trainRadius = new floatHolder(5, 0, 20); //how big to draw each train?
booleanHolder transparentTrain = new booleanHolder(false); //train line opacity depends on how many trains go up it

//clock settings
booleanHolder drawClock = new booleanHolder(true); //only does anything if on trainSimulator mode -> draw clock in top-right corner
intHolder clockWeight = new intHolder(2, 0, 10); //how thick is the line?
intHolder clockSize = new intHolder(50, 0, 200); //how big is the diameter?

//process flow settings
int currentWidth = 300; //keep track of size so we can resize the window
int currentHeight = 300; //keep track of size so we can resize the window
booleanHolder drawControlPanel = new booleanHolder(false); //draw the control panel?
boolean filmRecord = false; //should you save movie frames?
boolean runOnce = false; //don't want to check for resizing on first go, as it hasn't set up the time/date yet
boolean justResized = false; //need a flag for when it's been resized or the mouse events go wrong -> pmouseX is before resizing, mouseX afterwards so not directly comparable

//keeping track of time
booleanHolder pauseClock = new booleanHolder(false);
boolean pauseBefore = false;
int[] currentDate; //keep track of today, only work out once per frame
int[] offsetDate; //when did you last speed/slow time? have a stop so you can't go backwards
int[] currentTime; //current time of day
int[] offsetTime; //when did you last speed/slow time? have a stop so you can't go backwards
int offsetFrame = 0; //when did you last speed/slow time? have a stop so you can't go backwards
floatHolder timeDilation = new floatHolder(1, (1 / 60), 10); //how quickly does time move?
int currentWeekday; //what day of the week is it? -> work out once a frame only
boolean currentHoliday; //is today a bank holiday -> work out once a frame only
String[] dayNames = {"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"};
char[] dayInitials = new char[] {'M', 'T', 'W', 'T', 'F', 'S', 'S'};
int[] daysInMonth = new int[] {0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
String[] monthShortNames = new String[] {"", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}; 
String[] monthLongNames = new String[] {"", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"};
ArrayList<int[]> holidays = new ArrayList<int[]>(); //stores the bank holidays

//data containers
stationList stations; //stores the stations
stationLabelList stationLabels; //labels for stations
trainList trains; //trains!
stationPairList stationPairs; //pairs of stations linked by a train
ArrayList<otherLink> otherLinks; //other links from ALF file
controlList controls;

//Set up - load the data
void setup() {
  size(350, 500, P2D);
  background(0);
  
  println("Timetable data under licence from RSP");
  
  loadConfig(new File(dataPath("../config.txt")));
  folderSelected(new File(dataPath("../TTIS")));
  
  background(backGround.value);
  BRailFont = loadFont("BritishRailDarkNormal-12.vlw"); //http://www.rmweb.co.uk/community/index.php?/topic/8826-br-corporate-rail-alphabet-fonts/
  textFont(BRailFont, 12);
  registerMethod("pre", this);
  
  //make the window resizable!
  if (surface != null) {
    surface.setResizable(true);
  }
  
  //speed up memory allocation -> get right size of train list or massive if will fill it up
  int ztrLimit = ZTRcount;
  if (ZTRcount < 0) {
    ztrLimit = 9000;
  }
  int mcaLimit = MCAcount;
  if (MCAcount < 0) {
    mcaLimit = 280000;
  }
  
  //make data containers
  stations = new stationList(4000); //roughly right
  stationLabels = new stationLabelList();
  stationPairs = new stationPairList(10000);
  
  if (MSNFile != null) { //no point continuing otherwise
    if (trainSimulator) {
      trains = new trainList(ztrLimit + mcaLimit);
      offsetTime = new int[]{0, 0};
      offsetDate = new int[]{year() - 2000, month(), day()}; //today's date
      currentDate = offsetDate.clone();
      currentTime = offsetTime.clone();
    }
    if (loadOtherLinks) {
      otherLinks = new ArrayList<otherLink>(3000);
    }

    loadStations(MSNFile);
    if (loadOtherLinks && (ALFFile != null)) {
      loadOtherLinks(ALFFile);
    }
    loadHolidays();
    
    //load the trains asynchronously - may take up to half an hour
    if (MCAFile != null) {
      MCAloader = new asynchronousLoader(this, MCAFile, false, mcaLimit);
      MCAloader.start();
    }
    if (ZTRFile != null) {
      ZTRloader = new asynchronousLoader(this, ZTRFile, true, ztrLimit);
      ZTRloader.start();
    }
  }
  
  //load control panel
  controls = new controlList();
  controls.load();
}

//makeshift window update event
void pre() {
  if (runOnce && (width != currentWidth || height != currentHeight)) {
    stations.updateScreen();
    controls.errorText = wordWrap("Insufficient room to draw the control panel.", width - 50);
    controls.widthText = wordWrap("Please make the window wider.", width - 50);
    controls.heightText = wordWrap("Please make the window taller.", width - 50);
    justResized = true;
    currentWidth = width;
    currentHeight = height;
  }
}

void draw() {
  background(backGround.value);
  runOnce = true;
  
  //loop through the lines, stations and labels
  if (drawLines.value) {
    stationPairs.draw(loadOtherLinks);
  }
  if (drawStations.value) {
    stations.draw();
  }
  if (trainSimulator) {
    if (!pauseClock.value) {
      currentTime = getTime();
      currentDate = getDate();
      currentWeekday = getWeekday();
      currentHoliday = getHoliday();
    }
    else {
      offsetFrame = frameCount;
    }
    if (drawTrains.value) {
      trains.draw();
    }
  }
  if (drawStations.value && !drawControlPanel.value && drawStationLabels.value) {
    //want them on top -> but don't draw if in the controls
    stationLabels.draw();
  }
  if (trainSimulator && drawClock.value) {
    drawClock();
  }
  
  if (drawControlPanel.value) {
    //semi transparent control panel -> also disables normal mouse events, see below
    controls.draw();
  }
  else {
    //buttons at the bottom of the screen
    if (mouseY >= height - 100) {
      colorMode(RGB, 60);
      int alphaValue = 60 - (height - mouseY - 40);
      if (mouseY >= height - 40) {
        alphaValue = 60;
      }
      
      //draw the boxes
      int boxWidth = int((width - 40.0) / 5); 
      noFill();
      stroke(255, 255, 255, alphaValue);
      strokeWeight(1);
      rect(10, height - 30, boxWidth, 24); //control panel
      rect(10 + (1 * (boxWidth + 5)), height - 30, boxWidth, 24); //save config
      rect(10 + (2 * (boxWidth + 5)), height - 30, boxWidth, 24); //take screenshot
      if (filmRecord) {
        fill(255, 255, 255, alphaValue);
      }
      else {
        noFill();
      }
      rect(10 + (3 * (boxWidth + 5)), height - 30, boxWidth, 24); //record frames
      if (trainSimulator) {
        if (pauseClock.value) {
          fill(255, 255, 255, alphaValue);
        }
        else {
          noFill();
        }
        rect(10 + (4 * (boxWidth + 5)), height - 30, boxWidth, 24); //pause clock
      }
      
      //draw the text
      fill(255, 255, 255, alphaValue);
      textAlign(CENTER);
      text("Controls", (20 + (1 * boxWidth)) / 2, height - 14);
      text("Save config", (20 + (3 * (5 + boxWidth))) / 2, height - 14);
      text("Screenshot", (20 + (5 * (5 + boxWidth))) / 2, height - 14);
      if (filmRecord) {
        fill(0, 0, 0, alphaValue);
      }
      else {
        fill(255, 255, 255, alphaValue);
      }
      text("Record", (20 + (7 * (5 + boxWidth))) / 2, height - 14);
      if (trainSimulator) {
        if (pauseClock.value) {
          fill(0, 0, 0, alphaValue);
        }
        else {
          fill(255, 255, 255, alphaValue);
        }
        text("Pause", (20 + (9 * (5 + boxWidth))) / 2, height - 14);
      }

      //put things back to normal
      textAlign(LEFT);      
      colorMode(RGB, 255); 
    }
  }
  
  if (filmRecord && (movieOutput != null)) {
    //it wouldn't read the screenshot type from the variable - it would only save as png otherwise
    if (frameType.equals("jpg") || frameType.equals("jpeg")) {
      saveFrame(movieOutput + "/########" + ".jpg");
    }
    else if (frameType.equals("png")) {
      saveFrame(movieOutput + "/########" + ".png");
    }
    else if (frameType.equals("tga")) {
      saveFrame(movieOutput + "/########" + ".tga");
    }
    else {
      saveFrame(movieOutput + "/########" + ".tif");
    }

    noStroke();
    fill(255, 0, 0);
    ellipse(10, 10, 10, 10); //red on-air circle  
  }
}

void mouseClicked() {
  //click the buttons in the control panel!
  if (drawControlPanel.value && (controls.colourPicker == null) && (controls.datePicker == null)) {
    controls.update(false);
  }
  if (controls.colourPicker != null) {
    controls.colourPicker.updatePopup(false);
  }
  if (controls.datePicker != null) {
    controls.datePicker.updatePopup(false);
  }
  if ((mouseY >= height - 30) && (mouseY <= height - 10)) {
    int boxWidth = int((width - 40.0) / 5); 
    //buttons at the buttom of the screen
    if ((mouseX >= 10) && (mouseX <= 10 + boxWidth)) {
      //launch control panel
      offsetTime = currentTime.clone();
      offsetDate = currentDate.clone();
      offsetFrame = frameCount;
      pauseBefore = pauseClock.value; //store the old value to go back to
      pauseClock.value = true;
      controls.colourPicker = null;
      controls.datePicker = null;
      drawControlPanel.value = true;
    }
    
    if ((mouseX >= 15 + boxWidth) && (mouseX <= 15 + (2 * boxWidth))) {
      //save config
      selectOutput("Choose where to save your configuration file:", "saveConfig"); 
    } 
    
    if ((mouseX >= 20 + (2 * boxWidth)) && (mouseX <= 20 + (3 * boxWidth))) {
      //screenshots -> pick where to save and then save them there
      if (screenshotOutput == null) {
        selectedScreenshot = false;
        selectFolder("Choose where to save screenshots:", "screenshotChooser");
        while (!selectedScreenshot) {
          print("");
        }
      }
      saveScreenshot();
    }
    
    if ((mouseX >= 25 + (3 * boxWidth)) && (mouseX <= 25 + (4 * boxWidth))) {
      //record film frames
      filmRecord = !filmRecord;
      if (filmRecord) {
        selectFolder("Choose where to save movie frames:", "movieChooser");
        selectedFrames = false;
        while(!selectedFrames) {
          print("");
        }
      }
      else {
        println("Stopping recording at frame " + frameCount + " and saving in " + movieOutput);
      }
    }
    
    if ((mouseX >= 30 + (4 * boxWidth)) && (mouseX <= 30 + (5 * boxWidth))) {
      if (trainSimulator) {
        offsetTime = currentTime.clone();
        offsetDate = currentDate.clone();
        offsetFrame = frameCount;
        pauseClock.value = !pauseClock.value;
        pauseBefore = pauseClock.value;
      }
    }
  }
}

//mouse to drag the map around
void mouseDragged() {
  if (justResized) {
    justResized = false;
  }
  else {
    if (!drawControlPanel.value && (mouseY < height - 30)) {
      centreOS.x -= (mouseX - pmouseX) / zoomFactor.value;
      centreOS.y += (mouseY - pmouseY) / zoomFactor.value;
      
      //stay within limits -- arbitrary, but keep the british isles just in the window at 375 x 550
      if (centreOS.x > maxEasting) {
        centreOS.x = maxEasting;
      }
      if (centreOS.x < minEasting) {
        centreOS.x = minEasting;
      }
      if (centreOS.y > maxNorthing) {
        centreOS.y = maxNorthing;
      }
      if (centreOS.y < minNorthing) {
        centreOS.y = minNorthing;
      }
      //been a change, so need to reset the station locations
      stations.updateScreen();
      if (trainSimulator) {
        trains.draw();
      }
    }
    if (drawControlPanel.value && (controls.colourPicker == null) && (controls.datePicker == null)) {
      controls.update(true);
    }
    if (controls.colourPicker != null) {
      controls.colourPicker.updatePopup(true);
    }
    if (controls.datePicker != null) {
      controls.datePicker.updatePopup(true);
    }
  }
}

void keyPressed() {
  if (key == '-') { //zoom out
    zoomFactor.value /= 1.03;
    stations.updateScreen();
    if (trainSimulator) {
      trains.draw();
    }
  }
  if (key == '=') { //zoom in
    zoomFactor.value *= 1.03;
    stations.updateScreen();
    if (trainSimulator) {
      trains.draw();
    }
  }
  
    if (key == '[') { //slow down
    if (timeDilation.value >= timeDilation.min) {
      offsetTime = currentTime.clone();
      offsetDate = currentDate.clone();
      offsetFrame = frameCount;
      timeDilation.value /= 1.1;
    }
  }
  if (key == ']') { //speed up
    if (timeDilation.value <= timeDilation.max) {
      offsetTime = currentTime.clone();
      offsetDate = currentDate.clone();
      offsetFrame = frameCount;
      timeDilation.value *= 1.1;
    }
  }
  
  if (key == ' ') { //reset -> order follows control panel
    zoomFactor.reset(); //fixed because have to set screen size manually anyway
    centreOS = new PVector(defaultCentreOS.x, defaultCentreOS.y);
    backGround.reset();
    drawClock.reset();
    timeDilation.reset();
    if (trainSimulator) {
      offsetTime = currentTime.clone();
      offsetDate = currentDate.clone();
      offsetFrame = frameCount;
    }
    drawStations.reset();
    drawStationLabels.reset();
    ignoreZeroLocations.reset();
    normalStationRadius.reset();
    scaleStation.reset();
    minStationRadius.reset();
    maxStationRadius.reset();
    stationColour.reset();
    drawLines.reset();
    normalLineWidth.reset();
    scaleLine.reset();
    normalLineWidth.reset();
    minLineWidth.reset();
    maxLineWidth.reset();
    transparentLine.reset();
    minLineTransparency.reset();
    maxLineTransparency.reset();
    normalLineColour.reset();
    drawTrains.reset();
    trainRadius.reset();
    trainColour.reset();
    
    stations.updateScreen();
    stations.updateScales();
    stationPairs.updateScales();
  }

  //misc controls
  if (key == 'q') {
    //invert colour over
    color swap = stationColour.value;
    stationColour.value = backGround.value;
    backGround.value = swap;
  }
  
  //mirror the bottom buttons at the bottom of the screen
  if (key == 'z') {
    if (trainSimulator) {
      offsetTime = currentTime.clone();
      offsetDate = currentDate.clone();
      offsetFrame = frameCount;
    }
    if (drawControlPanel.value) {
      pauseClock.value = pauseBefore;
    }
    else {
      pauseClock.value = true;
    }
    drawControlPanel.value = !drawControlPanel.value;
    controls.colourPicker = null;
    controls.datePicker = null;
  }
  
  if (key == 'x') {
    //save configuration
    selectOutput("Choose where to save your configuration file:", "saveConfig"); 
  }
  
  if (key == 'c') {
    //screenshots -> pick where to save and then save them there
    if (screenshotOutput == null) {
      selectedScreenshot = false;
      selectFolder("Choose where to save screenshots:", "screenshotChooser");
      while (!selectedScreenshot) {
        print("");
      }
    }
    saveScreenshot();
  }
  
  if (key == 'v') {
    filmRecord = !filmRecord;
    if (filmRecord) {
      selectFolder("Choose where to save movie frames:", "movieChooser");
      selectedFrames = false;
      while(!selectedFrames) {
        print("");
      }
    }
    else {
      println("Stopping recording at frame " + frameCount + " and saving in " + movieOutput);
    }
  }

  if (key == 'b' && !drawControlPanel.value) {
    if (trainSimulator) {
      offsetTime = currentTime.clone();
      offsetDate = currentDate.clone();
      offsetFrame = frameCount;
      pauseClock.value = !pauseClock.value;
      pauseBefore = pauseClock.value;
    }
  }
}
