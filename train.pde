//trainMap
//February 2013
//Tom Curtis
//
//Released under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported licence
//http://creativecommons.org/licenses/by-nc-sa/3.0/

class train {
  ArrayList<routeEntry> route; //where does it go?
  boolean[] days;
  boolean bankHolidayRunning; 
 
  //create a train from a train file in the pre-processed MCA
  train(ArrayList<String> trainFile, boolean ztrTrain) {
    route = new ArrayList<routeEntry>();
    for (int i = 0; i < trainFile.size(); i++) {
      String data = (String)trainFile.get(i);
      if (data.length() < 10) { //ignore blank/small lines
        continue;
      }
      String recordType = data.substring(0, 2); 
      
      //BS record -> badic details
      if (recordType.equals("BS")) { 
        days = new boolean[7];
        for (int j = 0; j < 7; j++) {
          days[j] = data.charAt(21 + j) == '1';
        }
        bankHolidayRunning = data.charAt(28) != ' ';
      }
      
      //LO record -> extra details
      if (recordType.equals("LO")) {
        routeEntry thisEntry = new routeEntry(0, data);
        if (thisEntry.station != null) {
          route.add(thisEntry);
        }
      }
      
      //LI record -> extra details
      else if (recordType.equals("LI")) {
        routeEntry thisEntry = new routeEntry(1, data);
        if (thisEntry.station != null) {
          route.add(thisEntry);
        }
      }
      
      //LT record -> extra details
      else if (recordType.equals("LT")) {
        routeEntry thisEntry = new routeEntry(2, data);
        if (thisEntry.station != null) {
          route.add(thisEntry);
        }
      }
    }
    
    //make pairs of stations from the route -> add new unique ones to the list for drawing lines 
    for (int i = 0; i < route.size() - 1; i++) {
      routeEntry firstEntry = (routeEntry)route.get(i);
      station firstStation = firstEntry.station;
      routeEntry secondEntry = (routeEntry)route.get(i + 1);
      station secondStation = secondEntry.station;
      
      if ((firstStation == null) || (secondStation == null)) {
        continue;
      }
      
      stationPair newPair = new stationPair(firstStation, secondStation, false);
      stationPair thisPair = stationPairs.get(newPair);
      
      if (thisPair == null) {
        stationPairs.add(newPair);
      }
      else {
        thisPair.trainCount++;
        if (thisPair.trainCount > stationPairs.busiest) {
          stationPairs.busiest = thisPair.trainCount; //for updating the scales as we go along, if loading asynchronously
        } 
      }
    }
    
    if (trainSimulator && (route.size() >= 2)) {
      trains.add(this);
    }
  }
  
  //get the locations of all stations on the route
  ArrayList<station> getRouteStations() {
    ArrayList<station> results = new ArrayList<station>();
    for (int i = 0; i < route.size(); i++) {
      routeEntry thisEntry = (routeEntry)route.get(i);
      results.add(thisEntry.station);
    }
    return results;
  }
  
  PVector getScreen(int[] date, int[] time, boolean firstGo) {
    //see when it starts in the morning
    routeEntry firstEntry = (routeEntry)route.get(0);
    routeEntry lastEntry = (routeEntry)route.get(route.size() - 1);
    int firstDeparture = intTime(firstEntry.scheduledDeparture);
    int lastArrival = intTime(lastEntry.scheduledArrival);
    int timeNow = intTime(time);
    
    //it's after it starts in the morning -> check today's schedule
    if (timeNow >= firstDeparture) {
      int weekDay;
      boolean holiday;

      //what day of week is it? short cut for normal operation
      if (date == currentDate) {
        weekDay = currentWeekday;
        holiday = currentHoliday;
      }
      else {
        weekDay = getWeekday(date);
        holiday = getHoliday(date);
      }
      //if it's running today //and if it either isn't a bank holiday, or it runs on bank holidas
      if ((days[weekDay] && !holiday) || bankHolidayRunning) {
        //check first if it's currently running at all
        if (timeNow < lastArrival) {
          //go through the route checking the entries
          for (int i = 0; i < route.size() - 1; i++) {
            routeEntry currentEntry = (routeEntry)route.get(i);
            routeEntry nextEntry = (routeEntry)route.get(i + 1);
            //don't draw it if it's going to the bottom-left
            if (!ignoreZeroLocations.value || ((currentEntry.station.easting != 0) && (currentEntry.station.northing != 0) && (nextEntry.station.easting != 0) && (nextEntry.station.northing != 0))) {
              //case 1) sitting in a platform -> between arrival and departure
              if ((timeNow <= intTime(currentEntry.scheduledDeparture)) && (timeNow >= intTime(currentEntry.scheduledArrival))) {
                return currentEntry.station.screen;
              }
              
              //case 2) between stations -> it's after departing one and before arriving at the next
              if ((timeNow >= intTime(currentEntry.scheduledDeparture)) && (timeNow <= intTime(nextEntry.scheduledArrival))) {
                int legTime = interval(nextEntry.scheduledArrival, currentEntry.scheduledDeparture); //how far between one and the other
                int progress = interval(time, currentEntry.scheduledDeparture); //how far have you got so far?
                float interpolate = float(progress) / legTime;
                return PVector.lerp(currentEntry.station.screen, nextEntry.station.screen, interpolate);
              }
            }
          }
        }
      }
    }
    //it wouldn't have started today's run yet -> check if last night's still needs to finish
    else {
      if (lastArrival < firstDeparture) { 
        //get yesterday's date and check then
        int[] yesterDate = date.clone();
        yesterDate[2]--;
        if (yesterDate[2] < 1) {
          yesterDate[1]--;
          if (yesterDate[1] < 1) {
            yesterDate[0]--;
            yesterDate[1] = 12;
          }
          yesterDate[2] = daysInMonth[yesterDate[1]];
          if ((yesterDate[1] == 2) && (isLeapYear(yesterDate[0]))) {
            yesterDate[2] = 29;
          }
        }
        if (firstGo) {
          //only try looking back one day
          return getScreen(yesterDate, time, false);
        } 
      }
    }
   return null;
  }
}

class trainList {
  private ArrayList<train> trains;
  
  trainList(int capacity) {
    trains = new ArrayList<train>(capacity);
  }
  
  trainList() {
    trains = new ArrayList<train>();
  }
  
  void add(train t) {
    trains.add(t);
  }
  
  int size() {
    return trains.size();
  }
  
  train get(int i) {
    return (train)trains.get(i);
  }
 
  void draw() {
    strokeWeight(trainRadius.value);
    stroke(trainColour.value);
    for (int i = 0; i < trains.size(); i++) {
      train thisTrain = (train)trains.get(i);
      if (thisTrain != null) {
        PVector location = thisTrain.getScreen(currentDate, currentTime, true);
        if (location != null) {
          point(location.x, location.y);
        }
      }
    }
  }
}
