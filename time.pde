//trainMap
//February 2013
//Tom Curtis
//
//Released under a Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported licence
//http://creativecommons.org/licenses/by-nc-sa/3.0/

boolean getHoliday(int[] date) {
  for (int i = 0; i < holidays.size(); i++) {
    int[] thisDate = (int[])holidays.get(i);
    if (intDate(thisDate) == intDate(date)) {
      return true;
    }
  }
  return false;
}

boolean getHoliday() {
  return getHoliday(currentDate);
}

//turn date from an array into a number yymmdd for comparison 
int intDate(int[] date) {
  return date[2] + (100 * date[1]) + (10000 * (2000 + date[0]));
} 

//put time in an hhmm format for comparison
int intTime(int[] time) {
  return (60 * time[0]) + time[1];  
}

int interval(int[] time1, int[] time2) {
  if ((time1.length != 2) || (time2.length != 2)) {
    return -99999999; //not a time array
  }
  if ((time1[1] >= 60) || (time2[1] >= 60)) {
    return -99999999; //not a minutes value
  }
  int[] interval = new int[3];
  interval[0] = time2[0] - time1[0];
  interval[1] = time2[1] - time1[1];
  return (60 * interval[0]) + interval[1];
}

int[] getTime() {
  //start with the current time
  int[] t = new int[2];
  t[0] = offsetTime[0];
  t[1] = offsetTime[1];
  
  //then add on time for the number of frames since there
  float frameF = ((frameCount - offsetFrame) * timeDilation.value);
  t[0] += floor((frameF / 60) % 24);
  t[1] += floor(frameF % 60);
  
  //check the clock logic
  if (t[1] > 59) {
    t[0] += floor(t[1] / 60);
    t[1] %= 60;
  }
  t[0] %= 24; 
  return t;
}

boolean isLeapYear(int yy) {
  int year = 2000 + yy;
  if (((year % 4) == 0) && ((year % 400) != 0)) {
    return true;
  }
  return false;
}

boolean isLeapYear() {
  return isLeapYear(currentDate[0]);
}

//amazing find! adapted from http://java.dzone.com/articles/algorithm-week-how-determine
int getWeekday(int[] date) {
  int y = 2000 + date[0];
  int m = date[1];
  int d = date[2] - 1;
  
  // 1700-1-1 = 5 (Friday)
  int[] mo = new int[] { 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334 }; // monthly offset
  int af = m > 2 ? 0 : 1; // after february
  // every fourth year is a leap year, unless it is divisible by 100 unless it is divisible by 400
  int w = 5 + (y-1700)*365 + (y-1700-af)/4 - (y-1700-af)/100 + (y-1600-af)/400 + mo[m-1] + (d-1);
  return w % 7;
}

int getWeekday() {
  return getWeekday(currentDate);
}

int[] getDate() {
  //i don't think this is very efficient, but hey ho
  //remember: dates don't count from 0 -> not in the data we're using, anyway
  //start at the beginning
  int[] date = new int[3];
  date[0] = offsetDate[0];
  date[1] = offsetDate[1];
  date[2] = offsetDate[2];
  
  //get how many days to go up -> how many minutes? -> add one by one to current time, and count numbers of days that go up
  int dayCount = 0;
  int[] t = new int[2];
  t[0] = offsetTime[0];
  t[1] = offsetTime[1];
  
  float frameF = ((frameCount - offsetFrame) * timeDilation.value);
  t[0] += floor((frameF / 60));
  t[1] += floor(frameF % 60);
  
  if (t[1] > 59) {
    t[0] += floor(t[1] / 60);
    t[1] %= 60;
  }
  if (t[0] > 23) {
    dayCount = floor(t[0] / 24);
    t[0] %= 24; 
  }
  
  //go through the days, one by one
  for (int i = 0; i < dayCount; i++) {
    date[2]++; //add on another day
    int monthTarget; //how many days in the month?
    if (isLeapYear(date[0]) && (date[1] == 2)) { //february leap years are weird
      monthTarget = 29;
    }
    else {
      monthTarget = daysInMonth[date[1]]; //normally just a lookup
    }
    
    //if that's more than the number of the days in the month, go up a month
    if (date[2] > monthTarget) {
      date[1]++;
      date[2] = date[2] % monthTarget; 
      //if you go past december, it's january next year
      if (date[1] > 12) { 
        date[0]++;
        date[1] = (date[1] % 12);
      }
    }
  }
  return date;
}

// draw a clock on the top-right, based on framecount
void drawClock() {
  float minuteAngle = map(currentTime[1], 0, 60, -HALF_PI, 3*HALF_PI);
  float hourAngle = map(currentTime[0] + (currentTime[1] / 60.0), 0, 24, -HALF_PI, 7*HALF_PI);
  PVector clockCentre = new PVector(width - (0.6 * clockSize.value), 0.6 * clockSize.value);
  textAlign(CENTER);
  
  stroke(red(stationColour.value), green(stationColour.value), blue(stationColour.value));
  strokeWeight(clockWeight.value);
  fill(red(backGround.value), green(backGround.value), blue(backGround.value), 175);
  
  ellipse(clockCentre.x, clockCentre.y, clockSize.value, clockSize.value);
  line(clockCentre.x, clockCentre.y, clockCentre.x + (0.3 * clockSize.value * cos(hourAngle)), clockCentre.y + (0.3 * clockSize.value * sin(hourAngle)));
  line(clockCentre.x, clockCentre.y, clockCentre.x + (0.4 * clockSize.value * cos(minuteAngle)), clockCentre.y + (0.4 * clockSize.value * sin(minuteAngle)));
  
  //write the text below
  fill(red(stationColour.value), green(stationColour.value), blue(stationColour.value));
  
  //day of the week
  text(dayNames[currentWeekday], clockCentre.x, clockCentre.y + clockSize.value - (clockSize.value / 5.0)); //day of the week

  String dateString = nf(currentDate[2], 2) + " " + monthShortNames[currentDate[1]] + " " + (currentDate[0] + 2000);
  text(dateString, clockCentre.x, clockCentre.y + clockSize.value + (clockSize.value / 25.0)); //date
  
  String timeString = nf(currentTime[0], 2) + ":" + nf(currentTime[1], 2);
  text(timeString, clockCentre.x, clockCentre.y + clockSize.value + ((clockSize.value / 50.0) * 14)); //time
}
