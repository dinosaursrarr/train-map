//trainMap
//February 2013
//Tom Curtis
//
//Released under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported licence
//http://creativecommons.org/licenses/by-nc-sa/3.0/

class routeEntry {
  station station; //store a reference for easier lookup
  int[] scheduledDeparture;
  int[] scheduledArrival;
  boolean stops; //does it stop there?
  
  routeEntry(int type, String data) {
    String tiploc = null;
    String crs = null;
    switch(type) {
      //LO entry -> origin station 
      case(0):
        tiploc = trim(data.substring(2, 10)); //take the full 8 digits, will see about sorting out the suffix it later
        if (trim(data.substring(10, 14)).length() > 0) {
          scheduledDeparture = new int[2];
          scheduledDeparture[0] = int(trim(data.substring(10, 12)));
          scheduledDeparture[1] = int(trim(data.substring(12, 14)));
        }
        scheduledArrival = scheduledDeparture;
        stops = true; 
        break;
      
      //LI entry -> intermediate station
      case(1):
        tiploc = trim(data.substring(2, 10));
        if (trim(data.substring(20, 24)).length() > 0) {
          //there is a scheduled pass -> use as arrival and departure
          scheduledArrival = new int[2];
          scheduledArrival[0] = int(trim(data.substring(20, 22)));
          scheduledArrival[1] = int(trim(data.substring(22, 24)));
          scheduledDeparture = scheduledArrival;
          stops = false;
        }
        else {
          //no scheduled pass, so use the arrival and departure times
          scheduledArrival = new int[2];
          scheduledArrival[0] = int(trim(data.substring(10, 12)));
          scheduledArrival[1] = int(trim(data.substring(12, 14)));
          scheduledDeparture = new int[2];
          scheduledDeparture[0] = int(trim(data.substring(15, 17)));
          scheduledDeparture[1] = int(trim(data.substring(17, 19)));
          stops = true;
        }        
        break;
      
      //LT entry -> terminal station
      case(2):
        tiploc = trim(data.substring(2, 10));
        if (trim(data.substring(10, 14)).length() > 0) {
          scheduledArrival = new int[2];
          scheduledArrival[0] = int(trim(data.substring(10, 12)));
          scheduledArrival[1] = int(trim(data.substring(12, 14)));
        }
        scheduledDeparture = scheduledArrival;
        stops = true;
        break;
    }
    
    //if it contains dashes, it's actually a crs code from the ZTR file
    if (tiploc.indexOf("-") != -1) {
      crs = tiploc.substring(0, 3);
      tiploc = null;
    }
    else {
      //it has a tiploc, check if there's a suffix
      //if 8 digits in text, last one must be suffix. fact that max tiploc is 7digits, and they leave 8 means suffix can be only 1 long
      if (tiploc.length() == 8) {
        tiploc = tiploc.substring(0, 7);
      }
      //got 7 digits or less -> check if all but the last letter is a valid tiploc
      else {
        String shortTiploc = tiploc.substring(0, tiploc.length() - 1); //all but the less letter
        //if the short one is a valid tiploc, assume we have a tiploc + suffix. otherwise, assume there is no suffix
        if (stations.getTiploc(shortTiploc) != null) {
          tiploc = shortTiploc;
        }
      }
    }
    
    if (tiploc == null) {
      station = stations.getCRS(crs);
    }
    else if (crs == null) {
      station = stations.getTiploc(tiploc);
    } 
    
    if (station != null) {
      station.trainCount++;
      if (station.trainCount > stations.busiest) {
        stations.busiest = station.trainCount; //update as we go along if loading asynchronously
      }
    }
  }
}
