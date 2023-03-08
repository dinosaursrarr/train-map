//trainMap
//February 2013
//Tom Curtis
//
//Released under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported licence
//http://creativecommons.org/licenses/by-nc-sa/3.0/

class control {
  String label;
  int type; //sliding = 0, boolean = 1;
  
  void writeLabel(PVector start) {
    fill(255);
    text(label, start.x, start.y + 10);
  }
}

class slidingControl extends control {
  intHolder intValue;
  floatHolder floatValue;
  
  slidingControl(intHolder i, String l) {
    intValue = i;
    label = l;
    type = 0;
  }
  
  slidingControl(floatHolder h, String l) {
    floatValue = h;
    label = l;
    type = 0;
  }
  
  void draw(PVector start, float startControl, float rightMargin) {
    //draw int/float control as slider
    writeLabel(start);
    noFill();
    rect(startControl, start.y, width - rightMargin - startControl, 12);
    float midX;          
    if (intValue == null) {
      midX = map(floatValue.value, floatValue.min, floatValue.max, startControl + 2, width - rightMargin - 2);
    }
    else {
      midX = map(intValue.value, intValue.min, intValue.max, startControl + 2, width - rightMargin - 2);
    }
    fill(255);
    rect(midX - 2, start.y, 4, 12);
  }
  
  void update(float startControl, float rightMargin) {
    if (mouseX <= (width - rightMargin) && (mouseX >= startControl)) {
      if (intValue == null) {
        floatValue.value = map(mouseX, startControl, width - rightMargin, floatValue.min, floatValue.max);
      }
      else {
        intValue.value = int(map(mouseX, startControl, width - rightMargin, intValue.min, intValue.max));
      }
      stations.updateScreen();
      stations.updateScales();
      stationPairs.updateScales();
    }
  }
}

class booleanControl extends control {
  booleanHolder booleanValue;
  
  booleanControl(booleanHolder b, String l) {
    booleanValue = b;
    label = l;
    type = 1;
  }
  
  void draw(PVector start, float startControl) {
    //draw as checkbox
    writeLabel(start);
    noFill();
    stroke(255);
    strokeWeight(1);
    rect(startControl, start.y, 12, 12);
    if (booleanValue.value) {
      fill(255);
      rect(startControl + 3, start.y + 3, 6, 6);
    }
  }
  
  void update(float startControl) {
    if (mouseX <= (startControl + 12) && (mouseX >= startControl)) { 
      booleanValue.value = !booleanValue.value;
    }
  }
}

//will use to split control panel into sections
class headerControl extends control {
  headerControl (String l) {
    label = l;
    type = 2;
  }
  
  void draw(PVector start, float rightMargin) {
    writeLabel(start);
    stroke(255);
    line(20, start.y + 12, width - rightMargin, start.y + 12);
  }
}

class spaceControl extends control {
  spaceControl() {
    label = "";
    type = 3;
  }
}

class doubleEndedControl extends control {
  intHolder minInt;
  intHolder maxInt;
  int minMinInt;
  int maxMaxInt;
  floatHolder minFloat;
  floatHolder maxFloat;
  float minMinFloat;
  float maxMaxFloat;
  
  doubleEndedControl(intHolder mN, intHolder mX, String l) {
    label = l;
    type = 4;
    minInt = mN;
    maxInt = mX;
    minMinInt = min(minInt.min, maxInt.min);
    maxMaxInt = max(minInt.max, maxInt.max);
    
    //make sure max and min are the right way round when you link the variables like this
    if (maxInt.value < minInt.value) {
      intHolder swap = new intHolder(maxInt.value, maxInt.min, maxInt.max, maxInt.defaultValue);
      maxInt = minInt;
      minInt = swap;
    }
  }
  
  doubleEndedControl(floatHolder mN, floatHolder mX, String l) {
    label = l;
    type = 4;
    minFloat = mN;
    maxFloat = mX;
    minMinFloat = min(minFloat.min, maxFloat.min);
    maxMaxFloat = max(minFloat.max, maxFloat.max);
    
    //make sure max and min are the right way round when you link the variables like this
    if (maxFloat.value < minFloat.value) {
      floatHolder swap = new floatHolder(maxFloat.value, maxFloat.min, maxFloat.max, maxFloat.defaultValue);
      maxFloat = minFloat;
      minFloat = swap;
    }
  }
  
  void draw(PVector start, float startControl, float rightMargin) {
    writeLabel(start);
    //draw int/float control as slider
    noFill();
    rect(startControl, start.y, width - rightMargin - startControl, 12);
    float minX;
    float maxX;
    if (minInt == null) {
      minX = map(minFloat.value, minMinFloat, maxMaxFloat, startControl + 2, width - rightMargin - 4);
      maxX = map(maxFloat.value, minMinFloat, maxMaxFloat, startControl + 2, width - rightMargin - 4); 
    }
    else {
      minX = map(minInt.value, minMinInt, maxMaxInt, startControl + 2, width - rightMargin - 4);
      maxX = map(maxInt.value, minMinInt, maxMaxInt, startControl + 2, width - rightMargin - 4); 
    }
    fill(255);
    rect(minX, start.y, maxX - minX, 12);
  }
  
  void update(float startControl, float rightMargin) {
    if ((mouseX <= (width - rightMargin)) && (mouseX >= startControl)) {
      if (minInt == null) {
        float mouseValue = map(mouseX, startControl + 2, width - rightMargin - 4, minMinFloat, maxMaxFloat);
        float minDiff = abs(mouseValue - minFloat.value);
        float maxDiff = abs(mouseValue - maxFloat.value);
        
        //set the min or max, depending which is nearer to where you clicked
        if (minDiff <= maxDiff) {
          minFloat.value = mouseValue;
        }
        else {
          maxFloat.value = mouseValue;
        }
      }
      else {
        int mouseValue = int(map(mouseX, startControl + 2, width - rightMargin - 4, minMinInt, maxMaxInt));
        int minDiff = abs(mouseValue - minInt.value);
        int maxDiff = abs(mouseValue - maxInt.value);
        
        //set the min or max, depending which is nearer to where you clicked 
        if (minDiff <= maxDiff) {
          minInt.value = mouseValue;
        }
        else {
          maxInt.value = mouseValue;
        }
      }
      stations.updateScreen();
      stations.updateScales();
      stationPairs.updateScales();
    }
  }
  
}

class colourControl extends control {
  colourHolder colour;
  floatHolder transparency;
  slidingControl transparencySlider;
  float startControl;
  boolean firstClick = false;
  
  colourControl(colourHolder c, String l) {
    type = 5;
    colour = c;
    label = l;
    transparency = new floatHolder(alpha(c.value), 0, 255);
    transparencySlider = new slidingControl(transparency, "Opacity");
    startControl = textWidth(transparencySlider.label) + 44;
  }
  
  void draw(PVector start, float startControl, float rightMargin) {
    writeLabel(start);
    stroke(255);
    fill(red(colour.value), green(colour.value), blue(colour.value));
    rect(startControl, start.y, width - rightMargin - startControl, 12);
  }
  
  void update(float startControl, float rightMargin) {
    if ((mouseX <= width - rightMargin) && (mouseX >= startControl)) {
      controls.colourPicker = this;
      firstClick = true;
    }
  }
  
  void drawPopup() {
    //grey out the main control panel
    fill(0, 0, 0, 200);
    noStroke();
    rect(10, 10, width - 20, (controls.size() * 14));
    
    //draw a new box for the colour picker
    int boxHeightOffset = (height - 300) / 2;
    fill(0, 0, 0, 225);
    stroke(255);
    strokeWeight(1);
    rect(30, boxHeightOffset, width - 60, 300);
    
    //draw an exit button
    rect(width - 50, boxHeightOffset + 5, 10, 10);  
    line(width - 50, boxHeightOffset + 5, width - 40, boxHeightOffset + 15);
    line(width - 50, boxHeightOffset + 15, width - 40, boxHeightOffset + 5);
    
    //label at the top
    fill(255);
    text(label, 40, boxHeightOffset + 18);
    line(40, boxHeightOffset + 20, width - 40, boxHeightOffset + 20);
    
    //draw the colour chooser
    noFill();
    rect(40, boxHeightOffset + 30, width - 80, 160);
    colorMode(HSB, width - 81, 159, width - 81);
    float hue = hue(colour.value);
    for (int saturation = 0; saturation < 159; saturation++) {
      for (int brightness = 0; brightness < width - 81; brightness++) {
        stroke(hue, (159 - saturation), brightness);
        point(41 + brightness, boxHeightOffset + 31 + saturation);
      }
    }
    colorMode(RGB, 255);
    
    //change the hue
    noFill();
    stroke(255);
    rect(40, boxHeightOffset + 200, width - 80, 20);
    colorMode(HSB, width - 81, 1, 1);
    for (int i = 0; i < width - 81; i++) {
      color hueRange = color(i, 1, 1);
      stroke(hueRange);
      line(41 + i, boxHeightOffset + 201, 41 + i, boxHeightOffset + 219);
    }
    colorMode(RGB, 255);
    
    //draw the current colour
    fill(255);
    text("Result", 40, boxHeightOffset + 236);
    stroke(255);
    fill(red(colour.value), green(colour.value), blue(colour.value));
    rect(40, boxHeightOffset + 240, width - 80, 30);
    
    //sliding control for transparency
    PVector slideStart = new PVector(40, boxHeightOffset + 276);
    transparencySlider.draw(slideStart, startControl, 40);
  }
  
  void updatePopup(boolean dragged) {
    if (firstClick) {
      firstClick = false;
    }
    else {
      int boxHeightOffset = (height - 300) / 2;
      
      if (!dragged && (mouseX >= width - 50) && (mouseX <= width - 40) && (mouseY >= boxHeightOffset + 5) && (mouseY <= boxHeightOffset + 15)) {
        //exit button
        controls.colourPicker = null;
      }
      
      if ((mouseY > boxHeightOffset + 30) && (mouseY < boxHeightOffset + 190) && (mouseX > 40) && (mouseX < width - 40)) {
        //set the current shade
        colorMode(HSB, width - 81, 159, width - 81);
        colour.value = color(hue(colour.value), 159 - (mouseY - boxHeightOffset - 31), mouseX - 41);
        colorMode(RGB, 255);
      }
      
      if ((mouseY > boxHeightOffset + 200) && (mouseY < boxHeightOffset + 220) && (mouseX > 40) && (mouseX < width - 40)) {
        //set the hue
        colorMode(HSB, width - 81, 1, 1);
        colour.value = color(mouseX - 41, saturation(colour.value), brightness(colour.value));
        colorMode(RGB, 255);
      }
      
      if ((mouseY >= boxHeightOffset + 276) && (mouseY <= boxHeightOffset + 290)) {
        transparencySlider.update(startControl, 40);
        colour.value = color(red(colour.value), green(colour.value), blue(colour.value), transparency.value);
      }
    }
  }
}

class dateControl extends control {
  boolean firstClick = false;
  
  dateControl(String l) {
    label = l;
    type = 6;
  }
  
  void draw(PVector start, float startControl, float rightMargin) {
    writeLabel(start);
    noFill();
    stroke(255);
    rect(startControl, start.y, width - rightMargin - startControl, 12);
    fill(255);
    
    int weekday;
    weekday = getWeekday(currentDate);
    
    String text = dayNames[weekday] + " " + nf(currentDate[2], 2) + " " + monthLongNames[currentDate[1]] + " " + (currentDate[0] + 2000);
    textAlign(CENTER);
    text(text, (startControl + width - rightMargin) / 2, start.y + 10);
    textAlign(LEFT);
  }
  
  void update(float startControl, float rightMargin) {
    if ((mouseX <= width - rightMargin) && (mouseX >= startControl)) {
      controls.datePicker = this;
      firstClick = true;
    }
  }
  
  void drawPopup() {
    //grey out the main control panel
    fill(0, 0, 0, 200);
    noStroke();
    rect(10, 10, width - 20, (controls.size() * 14));
    
    //draw a new box for the date picker
    int boxHeightOffset = (height - 200) / 2;
    fill(0, 0, 0, 225);
    stroke(255);
    strokeWeight(1);
    rect(30, boxHeightOffset, width - 60, 200);
    
    //draw an exit button
    rect(width - 50, boxHeightOffset + 5, 10, 10);  
    line(width - 50, boxHeightOffset + 5, width - 40, boxHeightOffset + 15);
    line(width - 50, boxHeightOffset + 15, width - 40, boxHeightOffset + 5);
    
    //label at the top
    fill(255);
    text(label, 40, boxHeightOffset + 18);
    line(40, boxHeightOffset + 20, width - 40, boxHeightOffset + 20);
    
    //title for the month
    textAlign(CENTER);
    String monthTitle = monthLongNames[currentDate[1]] + " " + (currentDate[0] + 2000);
    text(monthTitle, width / 2, boxHeightOffset + 40);
    
    //controls for month/year
    triangle(60, boxHeightOffset + 34, 66, boxHeightOffset + 28, 66, boxHeightOffset + 40); //year down
    triangle(66, boxHeightOffset + 34, 72, boxHeightOffset + 28, 72, boxHeightOffset + 40); //year down
    triangle(86, boxHeightOffset + 34, 92, boxHeightOffset + 28, 92, boxHeightOffset + 40); //month down
    triangle(width - 86, boxHeightOffset + 34, width - 92, boxHeightOffset + 28, width - 92, boxHeightOffset + 40); //month up
    triangle(width - 60, boxHeightOffset + 34, width - 66, boxHeightOffset + 28, width - 66, boxHeightOffset + 40); //year up
    triangle(width - 66, boxHeightOffset + 34, width - 72, boxHeightOffset + 28, width - 72, boxHeightOffset + 40); //year up
    
    //columns for the calender
    float colWidth = (width - 50) / 8;
    for (int i = 0; i < 7; i++) {
      text(dayInitials[i], 25 + (colWidth * (i + 1)), boxHeightOffset + 60);
    }
    
    //which day of week is the first of the month?
    int[] firstDate = new int[3];
    firstDate[0] = currentDate[0];
    firstDate[1] = currentDate[1];
    firstDate[2] = 1;
    int weekday = getWeekday(firstDate);
    
    //write the days on the calendar
    int dayCount = daysInMonth[currentDate[1]];
    if (isLeapYear(currentDate[0]) && (currentDate[1] == 2)) { //february leap years are weird
      dayCount = 29;
    }
    
    int startY = boxHeightOffset + 80;
    for (int i = 1; i <= dayCount; i++) {
      //check if it's a bank holiday
      int[] thisDate = new int[3];
      thisDate[0] = currentDate[0];
      thisDate[1] = currentDate[1];
      thisDate[2] = i;
      
      if (getHoliday(thisDate)) {
        fill(255, 0, 0);
      }
      else {
        fill(255);
      }
      
      text(i, 25 + (colWidth * (weekday + 1)), startY);
      weekday++;
      if (weekday > 6) {
        weekday = 0;
        startY += 20;
      } 
    }
    
    textAlign(LEFT);
  }
  
  void updatePopup(boolean dragged) {
    if (firstClick) {
      firstClick = false;
    }
    else {
      int boxHeightOffset = (height - 200) / 2;
      if (!dragged && (mouseX >= width - 50) && (mouseX <= width - 40) && (mouseY >= boxHeightOffset + 5) && (mouseY <= boxHeightOffset + 15)) {
        //exit button
        controls.datePicker = null;
      }
      
      if ((mouseY >= boxHeightOffset + 28) && (mouseY <= boxHeightOffset + 40)) {
        if ((mouseX >= 86) && (mouseX <= 92)) {
          currentDate[1]--; //month down
          if (currentDate[1] == 0) {
            currentDate[1] = 12;
            currentDate[0]--;
          }
          currentWeekday = getWeekday(currentDate);
          offsetTime = currentTime.clone();
          offsetDate = currentDate.clone();
          offsetFrame = frameCount;
        }
        
        if ((mouseX >= width - 92) && (mouseX <= width - 86)) {
          currentDate[1]++; //month up
          if (currentDate[1] == 13) {
            currentDate[1] = 1;
            currentDate[0]++;
          }
          currentWeekday = getWeekday(currentDate);
          offsetTime = currentTime.clone();
          offsetDate = currentDate.clone();
          offsetFrame = frameCount;
        }
        
        if ((mouseX >= 60) && (mouseX <= 72)) {
          currentDate[0]--; //year down
          currentWeekday = getWeekday(currentDate);
          offsetTime = currentTime.clone();
          offsetDate = currentDate.clone();
          offsetFrame = frameCount;
        }
        
        if ((mouseX >= width - 72) && (mouseX <= width - 60)) {
          currentDate[0]++; //year up
          currentWeekday = getWeekday(currentDate);
          offsetTime = currentTime.clone();
          offsetDate = currentDate.clone();
          offsetFrame = frameCount;
        }
      }
      else {
        //clicked on a date -> set the date and close the box
        float colWidth = (width - 50) / 8;
        if (!dragged && (mouseX >= 6 + colWidth) && (mouseX <= 6 + (8 * colWidth)) && (mouseY >= boxHeightOffset + 68) && (mouseY <= boxHeightOffset + 186)) { //the date area
          //get position in the grid
          int gridCol = int((mouseX - 6) / colWidth) - 1; //gets the day of the week you're at
          if (gridCol == 7) {
            gridCol = 6;
          }
          int gridRow = floor((mouseY - boxHeightOffset - 68) / 20);
          
          //get the first weekday
          int[] firstDate = new int[3];
          firstDate[0] = currentDate[0];
          firstDate[1] = currentDate[1];
          firstDate[2] = 1;
          int firstWeekday = getWeekday(firstDate);
          
          //work out what date you clicked on
          int newDay = (7 * gridRow) + gridCol - firstWeekday + 1;
          int dayCount = daysInMonth[currentDate[1]];
          if (isLeapYear(currentDate[0]) && (currentDate[1] == 2)) { //february leap years are weird
            dayCount = 29;
          }
          
          //set the date
          if ((newDay > 0) && (newDay <= dayCount)) {
            currentDate[2] = newDay;
            currentWeekday = getWeekday(currentDate);
            offsetTime = currentTime.clone();
            offsetDate = currentDate.clone();
            offsetFrame = frameCount;
            controls.datePicker = null;
          }
        }
      }
    }
  }
}

class timeControl extends control {
  float boxWidth = textWidth("00") + 4;
  int[] time;
  
  timeControl(String l) {
    time = currentTime;
    label = l;
    type = 7;
  }
  
  void draw(PVector start, float startControl) {
    time = currentTime;
    writeLabel(start);
    textAlign(CENTER);
    noFill();
    stroke(255);
    rect(startControl, start.y, boxWidth, 12);
    rect(startControl + boxWidth + 12, start.y, boxWidth, 12);
    fill(255);
    //up down for hours
    triangle(startControl + boxWidth + 2, start.y + 4, startControl + boxWidth + 8, start.y + 4, startControl + boxWidth + 5, start.y);
    triangle(startControl + boxWidth + 2, start.y + 8, startControl + boxWidth + 8, start.y + 8, startControl + boxWidth + 5, start.y + 12);
    //up down for minutes
    triangle(startControl + (2 * boxWidth) + 14, start.y + 4, startControl + (2 * boxWidth) + 20, start.y + 4, startControl + (2 * boxWidth) + 17, start.y);
    triangle(startControl + (2 * boxWidth) + 14, start.y + 8, startControl + (2 * boxWidth) + 20, start.y + 8, startControl + (2 * boxWidth) + 17, start.y + 12);
    
    //text parts
    text(nf(time[0], 2), startControl + (boxWidth / 2), start.y + 10);
    text(nf(time[1], 2), startControl + boxWidth + 12 + (boxWidth / 2), start.y + 10);
    textAlign(LEFT);
  }
  
  void update(PVector start, float startControl) {
    if ((mouseX >= startControl + boxWidth + 2) && (mouseX <= startControl + boxWidth + 8)) {
      //hour controls
      if ((mouseY >= start.y) && (mouseY <= start.y + 4)) {
        //up
        currentTime[0]++;
        if (currentTime[0] > 23) {
          currentTime[0] = 0;
        }
        offsetTime = currentTime.clone();
        offsetDate = currentDate.clone();
        offsetFrame = frameCount;
      }
      if ((mouseY >= start.y + 8) && (mouseY <= start.y + 12)) {
        //down
        currentTime[0]--;
        if (currentTime[0] < 0) {
          currentTime[0] = 23;
        }
        offsetTime = currentTime.clone();
        offsetDate = currentDate.clone();
        offsetFrame = frameCount;
      }
    }
    if ((mouseX >= startControl + (2 * boxWidth) + 14) && (mouseX <= startControl + (2 * boxWidth) + 20)) {
      //minute controls
      if ((mouseY >= start.y) && (mouseY <= start.y + 4)) {
        //up
        currentTime[1]++;
        if (currentTime[1] > 59) {
          currentTime[1] = 0;
        }
        offsetTime = currentTime.clone();
        offsetDate = currentDate.clone();
        offsetFrame = frameCount;
      }
      if ((mouseY >= start.y + 8) && (mouseY <= start.y + 12)) {
        //down
        currentTime[1]--;
        if (currentTime[1] < 0) {
          currentTime[1] = 59;
        }
        offsetTime = currentTime.clone();
        offsetDate = currentDate.clone();
        offsetFrame = frameCount;
      }
    }
  }
}

class controlList {
  private ArrayList<control> controls;
  float startControl = 0;
  private ArrayList<String> errorText;
  private ArrayList<String> widthText;
  private ArrayList<String> heightText;
  colourControl colourPicker;
  dateControl datePicker;
  
  controlList() {
    controls = new ArrayList<control>();
    errorText = wordWrap("Insufficient room to draw the control panel.", width - 50);
    widthText = wordWrap("Please make the window wider.", width - 50);
    heightText = wordWrap("Please make the window taller.", width - 50);
  }
  
  controlList(int capacity) {
    controls = new ArrayList<control>(capacity);
    errorText = wordWrap("Insufficient room to draw the control panel.", width - 50);
    widthText = wordWrap("Please make the window wider.", width - 50);
    heightText = wordWrap("Please make the window taller.", width - 50);
  }
  
  int size() {
    return controls.size();
  }
  
  control get(int i) {
    return controls.get(i);
  }
  
  void add(control c) {
    float labelWidth = textWidth(c.label) + 30;
    if (labelWidth > startControl) {
      startControl = labelWidth; 
    }
    controls.add(c);
  }
  
  void draw() {
    //black out what's behind
    noStroke();
    fill(0, 0, 0, 200);
    rect(0, 0, width, height);
    
    //draw the bounding box
    strokeWeight(1);
    stroke(255, 255, 255);
    fill(0, 0, 0, 225);
    float rightMargin = 20;
    rect(10, 10, width - rightMargin, (controls.size() * 14));
    
    //draw an exit button
    rect(width - rightMargin - 10, 15, 10, 10);  
    line(width - rightMargin - 10, 15, width - rightMargin, 25);
    line(width - rightMargin - 10, 25, width - rightMargin, 15);
    
    if ((width - (2 * rightMargin) - startControl) >= 50 && (height - 10 >= (14 * controls.size()))) { //only bother drawing them if there is 
      textAlign(LEFT);
      for (int i = 0; i < controls.size(); i++) {
        control thisControl = (control)controls.get(i);
        PVector start = new PVector(20, 20 + (i * 14));
        switch(thisControl.type) {
          case 0: //sliding control
            slidingControl slideControl = (slidingControl)thisControl;
            slideControl.draw(start, startControl, rightMargin);
            break;
          case 1: //check box
            booleanControl booleanControl = (booleanControl)thisControl;
            booleanControl.draw(start, startControl);
            break;
          case 2: //header
            headerControl headerControl = (headerControl)thisControl;
            headerControl.draw(start, rightMargin);
            break;
          case 4: //double ended
            doubleEndedControl doubleControl = (doubleEndedControl)thisControl;
            doubleControl.draw(start, startControl, rightMargin);
            break;
          case 5: //colour picker
            colourControl colourControl = (colourControl)thisControl;
            colourControl.draw(start, startControl, rightMargin);
            break;
          case 6:
            dateControl dateControl = (dateControl)thisControl;
            dateControl.draw(start, startControl, rightMargin);
            break;
          case 7:
            timeControl timeControl = (timeControl)thisControl;
            timeControl.draw(start, startControl);
        }
      }
      if (colourPicker != null) {
        colourPicker.drawPopup();
      }
      if (datePicker != null) {
        datePicker.drawPopup();
      }
    }
    else {
      //error messages -> window not big enough for the control panel
      textAlign(CENTER);
      fill(255);
      int startY = 30;
      for (int i = 0; i < errorText.size(); i++) {
        String thisLine = (String)errorText.get(i);
        text(thisLine, width / 2, startY);
        startY += 15;
      }
      startY += 30;
      if ((width - 40 - startControl) < 50) {
        for (int i = 0; i < widthText.size(); i++) {
          String thisLine = (String)widthText.get(i);
          text(thisLine, width / 2, startY);
          startY += 15;
        }
        startY += 30;
      }
      if (height - 10 < (14 * controls.size())) {
        for (int i = 0; i < heightText.size(); i++) {
          String thisLine = (String)heightText.get(i);
          text(thisLine, width / 2, startY);
          startY += 15;
        }
      }
    }
  }
  
  //function called on mouse click
  void update(boolean dragged) {
    float rightMargin = 20;
    if (!dragged && (mouseX >= width - rightMargin - 10) && (mouseX <= width - rightMargin) && (mouseY >= 15) && (mouseY <= 25)) {
      //exit value
      drawControlPanel.value = false;
      pauseClock.value = pauseBefore;
    }
    
    //only bother if it's far enough over to be clicking a control
    if (mouseX >= startControl) {
      int controlNumber = int((mouseY - rightMargin) / 14);
      if (controlNumber < controls.size()) {
        control thisControl = controls.get(controlNumber);
        switch(thisControl.type) {
          case 0: //sliding control
            slidingControl slideControl = (slidingControl)thisControl;
            slideControl.update(startControl, rightMargin);
            break;
          case 1: //booelean control
            if (!dragged) {
              booleanControl booleanControl = (booleanControl)thisControl;
              booleanControl.update(startControl);
            }
            break;
          case 4: //double ended control
            doubleEndedControl doubleControl = (doubleEndedControl)thisControl;
            doubleControl.update(startControl, rightMargin);
            break;
          case 5: //colour picker
            if (!dragged) {
              colourControl colourControl = (colourControl)thisControl;
              colourControl.update(startControl, rightMargin);
            }
            break;
          case 6: //date chooser
            if(!dragged) {
              dateControl dateControl = (dateControl)thisControl;
              dateControl.update(startControl, rightMargin);
            }
            break;
          case 7: //time chooser
            PVector start = new PVector(20, 20 + (controlNumber * 14));
            timeControl timeControl = (timeControl)thisControl;
            timeControl.update(start, startControl);
            break;
        }
      }
    }
  }
 
  void load() {
    add(new headerControl("Control panel"));
    add(new slidingControl(zoomFactor, "Zoom"));
    add(new colourControl(backGround, "Background colour"));//background
    add(new spaceControl());
    
    if (trainSimulator) {
      add(new headerControl("Time"));
      add(new booleanControl(drawClock, "Show clock"));
      add(new dateControl("Set date"));
      add(new timeControl("Set time"));
      add(new slidingControl(timeDilation, "Speed"));
      add(new spaceControl());
    }
    
    add(new headerControl("Stations"));
    add(new booleanControl(drawStations, "Show stations"));
    add(new booleanControl(drawStationLabels, "Show station labels"));
    add(new booleanControl(ignoreZeroLocations, "Ignore non-geographic"));
    add(new slidingControl(normalStationRadius, "Normal station radius"));
    add(new booleanControl(scaleStation, "Scale station radius"));
    add(new doubleEndedControl(minStationRadius, maxStationRadius, "Station radius range"));
    add(new colourControl(stationColour, "Station colour"));//stations
    add(new spaceControl());
    
    add(new headerControl("Lines"));
    add(new booleanControl(drawLines, "Show lines"));
    add(new slidingControl(normalLineWidth, "Normal line width"));
    add(new booleanControl(scaleLine, "Scale line width"));
    add(new doubleEndedControl(minLineWidth, maxLineWidth, "Line width range"));
    add(new booleanControl(transparentLine, "Scale line opacity"));
    add(new doubleEndedControl(minLineTransparency, maxLineTransparency, "Line opacity range"));
    add(new colourControl(normalLineColour, "Line colour"));//lines
    add(new spaceControl());
    
    if (trainSimulator) {
      add(new headerControl("Trains"));
      add(new booleanControl(drawTrains, "Show trains"));
      add(new slidingControl(trainRadius, "Train radius"));
      add(new colourControl(trainColour, "Train colour"));//trains
      add(new spaceControl());
    }
  }
}

/**
wordwrap taken from http://wiki.processing.org/index.php?title=Word_wrap_text
@author Daniel Shiffman
*/
 
// Function to return an ArrayList of Strings (maybe redo to just make simple array?)
// Arguments: String to be wrapped, maximum width in pixels of each line
ArrayList wordWrap(String s, int maxWidth) {
  // Make an empty ArrayList
  ArrayList a = new ArrayList();
  float w = 0;    // Accumulate width of chars
  int i = 0;      // Count through chars
  int rememberSpace = 0; // Remember where the last space was
  // As long as we are not at the end of the String
  while (i < s.length()) {
    // Current char
    char c = s.charAt(i);
    w += textWidth(c); // accumulate width
    if (c == ' ') rememberSpace = i; // Are we a blank space?
    if (w > maxWidth) {  // Have we reached the end of a line?
      String sub = s.substring(0,rememberSpace); // Make a substring
      // Chop off space at beginning
      if (sub.length() > 0 && sub.charAt(0) == ' ') sub = sub.substring(1,sub.length());
      // Add substring to the list
      a.add(sub);
      // Reset everything
      s = s.substring(rememberSpace,s.length());
      i = 0;
      w = 0;
    } 
    else {
      i++;  // Keep going!
    }
  }
 
  // Take care of the last remaining line
  if (s.length() > 0 && s.charAt(0) == ' ') s = s.substring(1,s.length());
  a.add(s);
 
  return a;
}
