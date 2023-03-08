//trainMap
//February 2013
//Tom Curtis
//
//Released under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported licence
//http://creativecommons.org/licenses/by-nc-sa/3.0/

class asynchronousLoader extends Thread {
  private PApplet app;
  private boolean isAlive;
  private String file;
  private String line;
  private boolean zTrain; //is it from the zTrain file?
  ArrayList<ArrayList<String>> bigList; //stores all the info in the file
  int count = 0;
  int limit;
  
  //give it some files to load trains from
  asynchronousLoader(PApplet a, String f, boolean z, int l) {
    app = a;
    file = f;
    isAlive = true;
    zTrain = z;
    limit = l;
    bigList = new ArrayList<ArrayList<String>>();
  }
  
  public void run() {
    long startMillis = System.currentTimeMillis();
    BufferedReader reader = createReader(file);
    ArrayList<String> currentTrain = new ArrayList<String>();
     
    try {
      String line;
      while ((line = reader.readLine()) != null) {
        char firstChar = line.charAt(0);
        if ((firstChar == 'B') || (firstChar == 'L')) {
          String recordType = line.substring(0, 2);
          if (recordType.equals("BX") || recordType.equals("LO") || recordType.equals("LI") || recordType.equals("LT")) {
            //if it's one of the parts of a train file, add it to the index
            currentTrain.add(line);
          }
          if (recordType.equals("BS")) {
            if (currentTrain.size()   >= 3) {
              bigList.add(currentTrain);
            }
            currentTrain = new ArrayList<String>();
            currentTrain.add(line);
          }
        }
      }
    }
    catch (Exception e) {
      e.printStackTrace(); 
    }
     
    println(bigList.size() + " trains loaded from " + file + " by " + millis() + " milliseconds");
    
    //now process the results!
    for (int i = 0; i < bigList.size(); i++) {
      ArrayList<String> thisTrain = (ArrayList<String>)bigList.get(i);
      new train(thisTrain, zTrain);
      if ((i % 1000) == 0) {
        println(i + " trains processed from " + file + " by " + millis() + " milliseconds");
      }
    }
  }
  
}
