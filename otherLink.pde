//trainMap
//February 2013
//Tom Curtis
//
//Released under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported licence
//http://creativecommons.org/licenses/by-nc-sa/3.0/

//load up the other kinds of links seen in the ALF file
class otherLink {
  station origin;
  station destination;
  
  otherLink(String input) {
    String[] fields = split(input, ',');
    for (int i = 0; i < fields.length; i++) {
      char type = fields[i].charAt(0);
      String value = fields[i].substring(2);
      
      switch(type) {
        //origin
        case('O'):
          origin = stations.getCRS(value);
          break;
          
        //destination
        case('D'):
          destination = stations.getCRS(value);
          break;
          
        //mode of transport
        case('M'):
          break;
        
        //time taken
        case('T'):
          break;
        
        //start time
        case('S'):
          break;
        
        //end time
        case('E'):
          break;
        
        //priority
        case('P'):
          break;
        
        //das of the week it runs
        case('R'):
          break;
        
        //from date
        case('F'):
          break;
        
        //until date
        case('U'):
          break;
       
      }
    }
    if ((origin == null) || (destination == null)) {
        return;
    } 
    stationPair pair = new stationPair(origin, destination, true);
    if (!stationPairs.contains(pair)) {
      pair.trainCount = 1;
      stationPairs.add(pair);
    }
    otherLinks.add(this);
  }
}
