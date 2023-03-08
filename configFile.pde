//trainMap
//February 2013
//Tom Curtis
//
//Released under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported licence
//http://creativecommons.org/licenses/by-nc-sa/3.0/

void loadConfig(java.io.File configFile) {
  //if possible load a config file from the data folder
  selectedConfig = true;
  String[] dataFile = loadStrings(configFile.getAbsolutePath());
  if (dataFile == null) {
    return;
  }
  
  //go through the lines and parse the config input
  for (int i = 0; i < dataFile.length; i++) {
    if (i % 100 == 0) {
      println(String.format("processing line %s", i));
    }
    if (dataFile[i].length() == 0) {
      continue; //blank line
    }
    if (dataFile[i].charAt(0) == '/') {
      continue; //it's a comment
    }
    
    String[] data = split(dataFile[i], "=");
    if (data.length != 2) {
      continue; //looking for a key, value pair separated by an equals
    }
    String key = trim(data[0]);
    String value = trim(data[1]);
    
    //parse the input! -> get the value then go onto the next line
    if (key.equals("centreEasting")) {
      defaultCentreOS.x = float(value);
      centreOS.x = float(value);
      continue;
    }
    if (key.equals("centreNorthing")) {
      defaultCentreOS.y = float(value);
      centreOS.y = float(value);
      continue;
    }
    if (key.equals("minEasting")) {
      minEasting = float(value);
      continue;
    }
    if (key.equals("maxEasting")) {
      maxEasting = float(value);
      continue;
    }
    if (key.equals("minNorthing")) {
      minNorthing = float(value);
      continue;
    }
    if (key.equals("maxNorthing")) {
      maxNorthing = float(value);
      continue;
    }
    if (key.equals("scaleStations")) {
      scaleStation = new booleanHolder(Boolean.valueOf(value));
      continue;
    }
    if (key.equals("scaleLines")) {
      scaleLine = new booleanHolder(Boolean.valueOf(value));
      continue;
    }
    if (key.equals("transparentLines")) {
      transparentLine = new booleanHolder(Boolean.valueOf(value));
      continue;
    }
    if (key.equals("ignoreZeroLocations")) {
      ignoreZeroLocations = new booleanHolder(Boolean.valueOf(value)); 
      continue;
    }
    if (key.equals("drawStations")) {
      drawStations = new booleanHolder(Boolean.valueOf(value));
      continue;
    }
    if (key.equals("drawStationLabels")) {
      drawStationLabels = new booleanHolder(Boolean.valueOf(value));
      continue;
    }
    if (key.equals("drawLines")) {
      drawLines = new booleanHolder(Boolean.valueOf(value));
      continue;
    }
    if (key.equals("trainSimulator")) {
      trainSimulator = Boolean.valueOf(value);
      continue;
    }
    if (key.equals("drawClock")) {
      drawClock = new booleanHolder(Boolean.valueOf(value));
      continue;
    }
    if (key.equals("loadOtherLinks")) {
      loadOtherLinks = Boolean.valueOf(value);
      continue;
    }
    if (key.equals("background")) {
      backGround = new colourHolder(parseColour(value));
      continue;
    }
    if (key.equals("stationColour")) {
      stationColour = new colourHolder(parseColour(value));
      continue;
    }
    if (key.equals("labelMouseRange")) {
      labelMouseRange = new intHolder(int(value), min(int(value), labelMouseRange.min), max(int(value), labelMouseRange.max));
      continue;
    }
    if (key.equals("labelWeight")) {
      labelWeight = new floatHolder(float(value), min(float(value), labelWeight.min), max(float(value), labelWeight.max));
      continue;
    }
    if (key.equals("lineWidth")) {
      normalLineWidth = new floatHolder(float(value), min(float(value), normalLineWidth.min), max(float(value), normalLineWidth.max));
      continue;
    }
    if (key.equals("minLineWidth")) {
      minLineWidth = new floatHolder(float(value), min(float(value), minLineWidth.min), max(float(value), minLineWidth.max));
      continue;
    }
    if (key.equals("maxLineWidth")) {
      maxLineWidth = new floatHolder(float(value), min(float(value), maxLineWidth.min), max(float(value), maxLineWidth.max));
      continue;
    }
    if (key.equals("lineColour")) {
      normalLineColour = new colourHolder(parseColour(value));
      continue;
    }
    if (key.equals("minLineTransparency")) {
      minLineTransparency = new floatHolder(float(value), min(float(value), minLineTransparency.min), max(float(value), maxLineTransparency.max));
      continue;
    }
    if (key.equals("zoomFactor")) {
      if (float(value) > 0) {
        zoomFactor = new floatHolder(float(value), min(float(value), zoomFactor.min), max(float(value), zoomFactor.max));
      }
      continue;
    }
    if (key.equals("maxLineTransparency")) {
      maxLineTransparency = new floatHolder(float(value), min(float(value), maxLineTransparency.min), max(float(value), maxLineTransparency.max));
      continue;
    }
    if (key.equals("stationRadius")) {
      normalStationRadius = new floatHolder(float(value), min(float(value), normalStationRadius.min), max(float(value), normalStationRadius.max));
      continue;
    }
    if (key.equals("minStationRadius")) {
      minStationRadius = new floatHolder(float(value), min(float(value), minStationRadius.min), max(float(value), minStationRadius.max));
      continue;
    }
    if (key.equals("maxStationRadius")) {
      maxStationRadius = new floatHolder(float(value), min(float(value), maxStationRadius.min), max(float(value), maxStationRadius.max));
      continue;
    }
    if (key.equals("mcaCount")) {
      MCAcount = int(value);
      continue;
    }
    if (key.equals("ztrCount")) {
      ZTRcount = int(value);
      continue;
    }
    if (key.equals("timeDilation")) {
      if (float(value) > 0) {
        timeDilation = new floatHolder(float(value), min(float(value), timeDilation.min), max(float(value), timeDilation.max));
      }
      continue;
    }
    if (key.equals("trainRadius")) {
      trainRadius = new floatHolder(float(value), min(float(value), trainRadius.min), max(float(value), trainRadius.max));
      continue;
    }
    if (key.equals("trainColour")) {
      trainColour = new colourHolder(parseColour(value));
      continue;
    }
    if (key.equals("drawTrains")) {
      drawTrains = new booleanHolder(Boolean.valueOf(value));
      continue;
    }
    if (key.equals("screenshotType")) {
      String fileType = value.toLowerCase();
      if (fileType.equals("jpg") || fileType.equals("jpeg") || fileType.equals("tif") || fileType.equals("tif") || fileType.equals("tiff") || fileType.equals("png") || fileType.equals("tga")) {
        screenshotType = fileType;
      }
      continue;
    }
    if (key.equals("frameType")) {
      String fileType = value.toLowerCase();
      if (fileType.equals("jpg") || fileType.equals("jpeg") || fileType.equals("tif") || fileType.equals("tif") || fileType.equals("tiff") || fileType.equals("png") || fileType.equals("tga")) {
        frameType = fileType;
      }
      continue;
    }
  }
  println("Config file loaded by " + millis() + " milliseconds");
}
    
color parseColour(String data) {
  String[] components = split(data, ","); //for colours, give an RGB value
  color c;
  
  //it's a grey, an RGB or an RGBA separated by commas 
  if (components.length == 1) {
    c = color(float(components[0]));
    return c;
  }
  if (components.length == 3) {
    c = color(float(components[0]), float(components[1]), float(components[2]));
    return c;
  }
  if (components.length == 4) {
   c = color(float(components[0]), float(components[1]), float(components[2]), float(components[3]));
   return c;
  }
  
  return color(0); //default to black
}

//export current set up
void saveConfig(java.io.File selection) {
  if (selection == null) {
  }
  else {
    String[] variables = new String[39];
    variables[0] = "centreEasting=" + str(centreOS.x);
    variables[1] = "centreNorthing=" + str(centreOS.y);
    variables[2] = "minEasting=" + str(minEasting);
    variables[3] = "maxEasting=" + str(maxEasting);
    variables[4] = "minNorthing=" + str(minNorthing);
    variables[5] = "maxNorthing=" + str(maxNorthing);
    variables[6] = "drawStations=" + str(drawStations.value);
    variables[7] = "drawLines=" + str(drawLines.value);
    variables[8] = "ignoreZeroLocations=" + str(ignoreZeroLocations.value);
    variables[9] = "scaleLines=" + str(scaleLine.value);
    variables[10] = "transparentLines=" + str(transparentLine.value);
    variables[11] = "lineWidth=" + str(normalLineWidth.value);
    variables[12] = "minLineWidth=" + str(minLineWidth.value);
    variables[13] = "maxLineWidth=" + str(maxLineWidth.value);
    variables[14] = "minLineTransparency=" + str(minLineTransparency.value);
    variables[15] = "maxLineTransparency=" + str(maxLineTransparency.value);
    variables[16] = "drawStationLabels=" + str(drawStationLabels.value);
    variables[17] = "scaleStations=" + str(scaleStation.value);
    variables[18] = "stationRadius=" + str(normalStationRadius.value);
    variables[19] = "minStationRadius=" + str(minStationRadius.value);
    variables[20] = "maxStationRadius=" + str(maxStationRadius.value);
    variables[21] = "labelMouseRange=" + str(labelMouseRange.value);
    variables[22] = "labelWeight=" + str(labelWeight.value);
    variables[23] = "background=" + writeColour(backGround.value);
    variables[24] = "stationColour=" + writeColour(stationColour.value);
    variables[25] = "lineColour=" + writeColour(normalLineColour.value);
    variables[26] = "mcaCount=" + str(MCAcount);
    variables[27] = "ztrCount=" + str(ZTRcount);
    variables[28] = "zoomFactor=" + str(zoomFactor.value);
    variables[29] = "trainSimulator=" + str(trainSimulator);
    variables[30] = "loadOtherLinks=" + str(loadOtherLinks);
    variables[31] = "drawClock=" + str(drawClock.value);
    variables[32] = "trainRadius=" + str(trainRadius.value);
    variables[33] = "trainColour=" + writeColour(trainColour.value);
    variables[34] = "timeDilation=" + str(timeDilation.value);
    variables[35] = "drawTrains=" + str(drawTrains.value);
    variables[36] = "screenshotType=" + screenshotType;
    variables[37] = "frameType=" + frameType;
    variables[38] = "timeDilation=" + str(timeDilation.value);
    
    String configPath = selection.getAbsolutePath();
    if (!configPath.endsWith(".txt")) {
      configPath += ".txt";
    }
    saveStrings(configPath, variables);
    println("Saved config file at " + configPath);
  }
}

String writeColour(color c) {
  int red = int(red(c));
  int green = int(green(c));
  int blue = int(blue(c));
  int alpha = int(alpha(c));
  
  return red + "," + green + "," + blue + "," + alpha;
}
