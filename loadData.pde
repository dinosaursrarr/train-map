//trainMap
//February 2013
//Tom Curtis
//
//Released under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported licence
//http://creativecommons.org/licenses/by-nc-sa/3.0/

//use to check a folder is right
void folderSelected(java.io.File selection) {
  selectedTimetable = true;
  if (selection == null) {
    println("Cannot simulate trains without timetable data!");
    exit();
  }
  else {
    //define filters for each kind of file we're looking for -> if the folder doesn't contain them, abort!
    java.io.FilenameFilter MSNFilter = new java.io.FilenameFilter() { //needed to only see the relevant files in the tr
      public boolean accept(java.io.File dir, String name) {
        return name.endsWith(".MSN");
      }
    };
    
    java.io.FilenameFilter MCAFilter = new java.io.FilenameFilter() { //needed to only see the relevant files in the tr
      public boolean accept(java.io.File dir, String name) {
        return name.endsWith(".MCA");
      }
    };
    
    java.io.FilenameFilter ZTRFilter = new java.io.FilenameFilter() { //needed to only see the relevant files in the tr
      public boolean accept(java.io.File dir, String name) {
        return name.endsWith(".ZTR");
      }
    };
    
    java.io.FilenameFilter ALFFilter = new java.io.FilenameFilter() { //needed to only see the relevant files in the tr
      public boolean accept(java.io.File dir, String name) {
        return name.endsWith(".ALF");
      }
    };
    
    //get the files involved for processing
    String[] MCAList = selection.list(MCAFilter);
    String[] ZTRList = selection.list(ZTRFilter);
    String[] MSNList = selection.list(MSNFilter);
    String[] ALFList = selection.list(ALFFilter);
    
    //process MSN -> absolutely critical!
    if (MSNList.length == 0) {
      println("Cannot simulate trains without stations!");
      exit();
    }
    else {
      MSNFile = selection.getAbsolutePath() + "/" + MSNList[0];
    }
    
    //process MCAFile -> main train database
    if (MCAList.length > 0) {
      MCAFile = selection.getAbsolutePath() + "/" + MCAList[0];
    }
    
    //process ZTRFile -> extra trains file
    if (ZTRList.length > 0) {
      ZTRFile = selection.getAbsolutePath() + "/" + ZTRList[0];
    }
    
    //process ALF File -> other links
    if (ALFList.length > 0) {
      ALFFile = selection.getAbsolutePath() + "/" + ALFList[0];
    }
  }
}

void loadStations(String filePath) {
  //load stations file
  String[] dataFile = loadStrings(filePath); //load file into array
  //process the strings -> put to the right place
  for (int i = 0; i < dataFile.length; i++) {
    char firstChar = dataFile[i].charAt(0);
    switch(firstChar) {
      case 'A':
        if (dataFile[i].charAt(6) != ' ') { //is it the timestamp line? hope not!
          new station(dataFile[i]); //make a new station
        }
        break;
      case 'L':
        //extract the alias and add to the station's names array
        String stationName = trim(dataFile[i].substring(5, 36));
        String stationAlias = trim(dataFile[i].substring(36));
        station match = stations.getName(stationName);
        match.names.add(stationAlias);
        break;
    }
  }
  println(stations.crsSize() + " stations loaded by " + millis() + " milliseconds");
}

void loadOtherLinks(String filePath) {
  String[] dataFile = loadStrings(filePath);
  for (int i = 0; i < dataFile.length; i++) {
    if (dataFile[i].length() > 0) {
      new otherLink(dataFile[i]);
    }
  }
  println(otherLinks.size() + " other links loaded by " + millis() + " milliseconds");
}

void loadHolidays() {
  String[] holidayFile = loadStrings("holidays.txt");
  for (int i = 0; i < holidayFile.length; i++) {
    String[] holiday = split(holidayFile[i], "/");
    int[] date = new int[3];
    date[0] = int(holiday[0]) - 2000;
    date[1] = int(holiday[1]);
    date[2] = int(holiday[2]);
    holidays.add(date);
  }
  println("Loaded " + holidays.size() + " bank holidays by " + millis() + " milliseconds");
}

//choose a folder to record into, otherwise stop
void movieChooser(java.io.File selection) {
  selectedFrames = true;
  if (selection == null) {
    filmRecord = false;
    movieOutput = null;
    println("No folder chosen to save movie frames to");
  }
  else {
    movieOutput = selection.getAbsolutePath();
    println("Starting recording at frame " + frameCount + " and saving in " + movieOutput);
  }
}

void screenshotChooser(java.io.File selection) {
  selectedScreenshot = true;
  if (selection == null) {
    println("Cannot save screenshots unless you select a folder to save them into");
  }
  else {
    screenshotOutput = selection.getAbsolutePath();
  }
}

void saveScreenshot() {
  if (screenshotOutput != null) {
    java.io.File folder = new java.io.File(screenshotOutput);
    int exportFileCount = folder.list().length;
    //it wouldn't read the screenshot type from the variable - it would only save as png otherwise
    if (screenshotType.equals("jpg") || screenshotType.equals("jpeg")) {
      save(screenshotOutput + "/" + exportFileCount + "-trainMap.jpg");
    }
    else if (screenshotType.equals("png")) {
      save(screenshotOutput + "/" + exportFileCount + "-trainMap.png");
    }
    else if (screenshotType.equals("tga")) {
      save(screenshotOutput + "/" + exportFileCount + "-trainMap.tga");
    }
    else {
      save(screenshotOutput + "/" + exportFileCount + "-trainMap.tif");
    }
    println("Saved screenshot at " + screenshotOutput + "/" + exportFileCount + "-trainMap." + screenshotType);
  }
}
