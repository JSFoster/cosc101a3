/**************************************************************
 * File: a3.pde
 * Group: Joel Foster, Mark Anderson, Leigh Dayes (Group 30)
 * Date: 14/03/2018
 * Course: COSC101 - Software Development Studio 1
 * Desc: Astroids is a ...
 * ...
 * Usage: Make sure to run in the processing environment and press play etc...
 * Notes: If any third party items are use they need to be credited (don't use anything with copyright - unless you have permission)
 * ...
 **************************************************************
 sound effects sourced from: https://freesound.org
 All images sourced from: https://www.kisspng.com 
 */

import processing.sound.*;
SoundFile thrustSound, laserSound, shotgunSound, dingSound, boomSound, 
  biggerBoomSound, deepBoomSound, laser2Sound, bigGunSound;

//SoundFile music;

PImage frame, hud, ship, ufo, thrust1, thrust2, heart, blueBall, purpleBall, bubble;
PImage[] explosionImages, backGroundImages, nebulaImages, rockImages;
int[] explosionsList = {};
int nebulaRandomizer, backGroundRandomizer, nebulaPosRandomizerX, nebulaPosRandomizerY;

int astroNums=1;
int increaseAstros=1;
int bigRockSize = 50;
int smallRockSize = 25;
PVector[] astroids = new PVector[astroNums];
PVector[] astroDirect = new PVector[astroNums];
PVector[] sAstroOne = new PVector[astroNums];
PVector[] sAstroTwo = new PVector[astroNums];
PVector[] sAstroThree = new PVector[astroNums];
PVector[] sAstroDirectOne = new PVector[astroNums];
PVector[] sAstroDirectTwo = new PVector[astroNums];
PVector[] sAstroDirectThree = new PVector[astroNums];

//===== ship related globals ====
boolean sUP=false, sDOWN=false, sRIGHT=false, sLEFT=false, sSPACE=false;
float shipAngle=radians(270); 
float turnSpeed = 0.08;
PVector shipLoc, shipVel;
float shipFric = 0.986;
int speedLimit = 7;
int crashCounter = 0;

float astroSpeed = 1.0;
float astroAccel = 0.5;
float maxAstroSpeed = astroSpeed*5+astroAccel;
float sAstroSpeed = 3.0;
float sAstroAccel = 1.0;
float maxsAstroSpeed = sAstroSpeed*3+sAstroAccel;
boolean[] hit = new boolean [astroNums];
boolean[] destroyedOne = new boolean [astroNums];
boolean[] destroyedTwo = new boolean [astroNums];
boolean[] destroyedThree = new boolean [astroNums];

ArrayList<PVector> shots= new ArrayList<PVector>();
ArrayList<PVector> sDirections= new ArrayList<PVector>();
PVector shotVel;
float shotSpeed = 25;
float fireRate = 0.1; // Adjust 0.0 - 1.0
float timeToFire = 1; // Will fire shot when >= 1. Controlled by fireRate.
PImage bullet;

int score=0;
int lives = 3;
int level = 1;
int levelMax = 20;
boolean playerAlive = true;
//boolean alive=true;

// Start screen bools
boolean startScreen = true;
boolean startButton = false;
boolean highScoreButton = false;
boolean exitButton = false;

void setup() {
  //fullScreen();
  size(1440, 900);
  //size(1000, 600);

  bigRockSize = width/12;  // if we are going to use scaling here, this has to be after fullscreen is called
  smallRockSize = width/24;

  shipLoc = new PVector(width/2, height/2);
  shipVel = new PVector(0, 0); 
  noFill();
  stroke(255);

  imageMode(CENTER);
  frame      = loadImage("frame.png");
  frame.resize(width, height);
  hud        = loadImage("hud.png");
  ship       = loadImage("ship.png");
  thrust1    = loadImage("thrust1.png");
  thrust2    = loadImage("thrust2.png");
  ufo        = loadImage ("ufo.png");
  heart      = loadImage ("heart.png");
  blueBall   = loadImage ("blueball.png");
  purpleBall = loadImage ("purpleball.png");
  bubble     = loadImage ("bubble.png");

  nebulaRandomizer     =int(random(0, 4));
  backGroundRandomizer =level % 4;
  nebulaPosRandomizerX =int(random(0, width));
  nebulaPosRandomizerY =-350;
  explosionImages  = new PImage[17];
  backGroundImages = new PImage[4];
  nebulaImages     = new PImage[4];
  rockImages       = new PImage[4];
  createImageArrays();

  thrustSound     = new SoundFile(this, "thrust.mp3");
  laserSound      = new SoundFile(this, "laser.mp3");
  shotgunSound    = new SoundFile(this, "ding.mp3");
  dingSound       = new SoundFile(this, "boom.mp3");
  boomSound       = new SoundFile(this, "boom.mp3");
  biggerBoomSound = new SoundFile(this, "biggerBoom.mp3");
  deepBoomSound   = new SoundFile(this, "deepBoom.mp3");
  laser2Sound     = new SoundFile(this, "laser2.mp3");
  bigGunSound     = new SoundFile(this, "bigGun.mp3");
  //music   =    new SoundFile(this, "music.mp3");

  //initialise pvtecotrs
  //random astroid initial positions and directions;
  createAstro();
  //initialise shapes if needed
  
  // Create bullet graphic.
  PGraphics pg = createGraphics(10, 10);
  pg.beginDraw();
  pg.strokeWeight(2);
  pg.stroke(0,255,0);
  pg.ellipse(5, 5, 5, 5);
  pg.filter(BLUR,2);
  pg.endDraw();
  bullet = pg.get();
}

void draw() {
  if (startScreen) {
    startScreen();
  } else {
    drawBackGround();
    collisionDetection();
    drawShots();
    drawShip();
    // report if game over or won
    drawAstroids();
    drawExplosions();
    drawHud();
    levelUp();
  }
}

/**************************************************************
 * Function: myFunction()
 
 * Parameters: None ( could be integer(x), integer(y) or String(myStr))
 
 * Returns: Void ( again this could return a String or integer/float type )
 
 * Desc: Each funciton should have appropriate documentation.
 This is designed to benefit both the marker and your team mates.
 So it is better to keep it up to date, same with usage in the header comment
 
 ***************************************************************/

void moveShip() {

  if (shipLoc.y < 0) {       //border wraps
    shipLoc.y = height;
  }           
  if (shipLoc.y > height) { 
    shipLoc.y = 0;
  }
  if (shipLoc.x < 0) { 
    shipLoc.x = width;
  }
  if (shipLoc.x > width) { 
    shipLoc.x = 0;
  }
  if (sUP) { 
    shipVel.add(PVector.fromAngle(shipAngle));    //speed up
    if ( thrustSound.isPlaying()== false )thrustSound.play();
  }           
  if (!sUP && thrustSound.isPlaying()== true ) {
    thrustSound.stop();
  }
  if (sRIGHT) { 
    shipAngle = shipAngle+turnSpeed;
  } 
  if (sLEFT) {  
    shipAngle = shipAngle-turnSpeed;
  }
  shipVel.mult(shipFric);         // slow down
  shipVel.limit(speedLimit);      // limit speed
  shipLoc.add(shipVel);           // change ship location
}

void drawShip() {
  if (crashCounter>0){
    crashCounter -- ;
  }
  pushMatrix();    
  translate(shipLoc.x, shipLoc.y);
  if (crashCounter < 90) {
    moveShip();
    rotate(shipAngle+PI/2);
    if (sUP) {
      if (frameCount % 2 == 0 ) {
        image(thrust1, 0, 35);
      } else {
        image(thrust2, 0, 35);
      }
    }
    image(ship, 0, 0); 
    if ( crashCounter != 0 && (frameCount % 6 == 0 || frameCount % 5 == 0 || frameCount % 4 == 0) ) {
      image(bubble, 0, 0);
    }
  }
  else if(crashCounter == 90){
    shipLoc = new PVector(width/2, height/2);
    shipVel = new PVector(0, 0);
    shipAngle=radians(270);
  }
  else if(crashCounter < 160){
    //silence();  // fix the sound bug here
  }
  else if(crashCounter == 160){
    explosionsList = append(explosionsList, 0);
    explosionsList = append(explosionsList, int(shipLoc.x));
    explosionsList = append(explosionsList, int(shipLoc.y));
    if (lives == 0 ) {
      bigGunSound.play();//biggerBoomSound.play();  // hehehehe
    }
    deepBoomSound.play();
  }
  else if(crashCounter < 209){
    moveShip();
    rotate(frameCount/2);
    image(thrust2, 0, 35);
    image(ship, 0, 0); 
  }
  else if(crashCounter == 209){
    lives--;
    explosionsList = append(explosionsList, 0);
    explosionsList = append(explosionsList, int(shipLoc.x));
    explosionsList = append(explosionsList, int(shipLoc.y));
    biggerBoomSound.play();  // hehehehe
  }
  popMatrix();
}


//void lifeLost() {
 // playerAlive = true; 
//}

void drawBackGround() {
  background(0);
  tint(95);
  image(backGroundImages[backGroundRandomizer], width/2, height/2);
  if (nebulaPosRandomizerY > height+350) {
    nebulaPosRandomizerY = -350;
    nebulaRandomizer =int(random(0, 4));
    nebulaPosRandomizerX =int(random(0, width));
  }
  tint(75);
  image(nebulaImages[nebulaRandomizer], nebulaPosRandomizerX, nebulaPosRandomizerY++);
  noTint();
}

void drawHud() {
  image(frame, width/2, height/2);

  pushMatrix();    
  translate(175, height-150);

  textAlign(CENTER);
  image(hud, 0, 0);
  if (lives > 0) {
    image(ship, -102, -67, 23, 35);
  }
  if (lives > 1) {
    image(ship, -80, -67, 23, 35);
  }
  if (lives > 2) {
    image(ship, -58, -67, 23, 35);
  }
  fill(200, 100, 00);
  textSize(22);
  text("Score", -80, 15);
  text(score, -80, 45);
  text("Level", -7, 58);
  text(level, -7, 88);

  if ( 1 == 1 ) {
    image(rockImages[2], -5, -18, 40, 40); // powerup placeholder
  }
  if ( 1 == 1 ) {
    image(rockImages[3], 70, 25, 40, 40); // powerup placeholder
  }
  popMatrix();
}

void createImageArrays() {

  //explosion
  for (int i = 1; i <= 17; i++) {
    String str = "explosion/" +i +".gif";
    explosionImages[i-1] = loadImage(str);
  }
  //BackGrounds
  for (int i = 1; i <= 4; i++) {
    String str = "stars" +i +".png";
    backGroundImages[i-1] = loadImage(str);
    backGroundImages[i-1].resize(width, height);
  }
  //nebula
  for (int i = 1; i <= 4; i++) {
    String str = "nebula" +i +".png";
    nebulaImages[i-1] = loadImage(str);
  }
  //rocks
  for (int i = 1; i <= 4; i++) {
    String str = "rock" +i +".png";
    rockImages[i-1] = loadImage(str);
    if (i==1) {
      rockImages[i-1].resize(bigRockSize, bigRockSize);
    } else {
      rockImages[i-1].resize(smallRockSize, smallRockSize);
    }
  }
}

void drawExplosions() {
  for (int i = 0; i <= explosionsList.length-1; i=i+3) {
    if (explosionsList[i]<17) {
      image(explosionImages[explosionsList[i]], explosionsList[i+1], explosionsList[i+2]);
      if (frameCount % 2 == 0) {
        explosionsList[i] = explosionsList[i]+1;
      }
    }
  }
}

/**************************************************************
 * Function: cleanArray()
 * Parameters: None
 * Returns: Void
 
 * Desc: This is a tricky little devil, Loops through arrays
 making a copy as it goes, when it finds an expired value 
 ( end of animation for example ) It does not copy the associated 
 values ( co-ords ). It then overwrites the old array with the
 values of the new one.
 effectivly removing a group of values from an array
 
 ***************************************************************/

void cleanArray() {
  int[] explosionsListTemp = new int[0];
  for (int i = 0; i <= explosionsList.length-1; i=i+3) {
    if (explosionsList[i] < 17) {
      explosionsListTemp = append(explosionsListTemp, explosionsList[i]);
      explosionsListTemp = append(explosionsListTemp, explosionsList[i+1]);
      explosionsListTemp = append(explosionsListTemp, explosionsList[i+2]);
    }
  }
  explosionsList = explosionsListTemp;  
}

void drawShots() {
  //draw points for each shot from spacecraft
  //at location and updated to new location
  fill(255);
  if (sSPACE) {
    timeToFire += fireRate;
    if (timeToFire >= 1) {
      shots.add(new PVector(shipLoc.x, shipLoc.y));
      sDirections.add(PVector.fromAngle(shipAngle));
      timeToFire = 0;
      laserSound.play();
    }
  } else if (!sSPACE) {
    timeToFire = 1;
  }
  for (int i = 0; i < shots.size(); i++) {
    image(bullet, shots.get(i).x, shots.get(i).y);
    shotVel = sDirections.get(i).normalize();
    shotVel.mult(shotSpeed);
    shots.get(i).add(shotVel);
  }
}

/**************************************************************
 * Function: drawAstroids
 
 * Parameters: None
 
 * Returns: Void
 
 * Desc: Loops through hit array to see if bigger astroids have been
 shot. if they haven't it draws big asteroids to the canvas
 with updated position. if big astroids have been shot then
 three smaller astroids have their position updated. if the
 smaller astroids have not been shot they are drawn to the 
 canvas.
 
 ***************************************************************/

void drawAstroids() {
  for (int i = 0; i < astroNums; i ++) {
    if (shotCollision(astroids[i].x, astroids[i].y, bigRockSize, hit[i])) {
      hit[i] = true;
    }
    if (!hit[i]) {
      astroids[i].add(astroDirect[i]);
      sAstroOne[i].add(astroDirect[i]);
      sAstroTwo[i].add(astroDirect[i]);
      sAstroThree[i].add(astroDirect[i]);
      borderWrap(sAstroOne[i]);
      borderWrap(sAstroTwo[i]);
      borderWrap(sAstroThree[i]);
      borderWrap(astroids[i]);   
      pushMatrix();    
      translate(astroids[i].x, astroids[i].y);
      rotate(radians(frameCount)); 
      image(rockImages[0], 0, 0);
      popMatrix();
    }
    if (hit[i]) {
      if (!destroyedOne[i]) {
        sAstroOne[i].add(sAstroDirectOne[i]);
        borderWrap(sAstroOne[i]);    
        pushMatrix();    
        translate(sAstroOne[i].x, sAstroOne[i].y);
        rotate(radians(frameCount)/.25); 
        image(rockImages[1], 0, 0);
        popMatrix();
        if (shotCollision(sAstroOne[i].x, sAstroOne[i].y, smallRockSize, destroyedOne[i])) {
          destroyedOne[i] = true;
        }
      }
      if (!destroyedTwo[i]) {
        sAstroTwo[i].add(sAstroDirectTwo[i]);
        borderWrap(sAstroTwo[i]);
        pushMatrix();    
        translate(sAstroTwo[i].x, sAstroTwo[i].y);
        rotate(radians(frameCount)/2); 
        image(rockImages[2], 0, 0);
        popMatrix();
        if (shotCollision(sAstroTwo[i].x, sAstroTwo[i].y, smallRockSize, destroyedTwo[i])) {
          destroyedTwo[i] = true;
        }
      }
      if (!destroyedThree[i]) {
        sAstroThree[i].add(sAstroDirectThree[i]);
        borderWrap(sAstroThree[i]);
        pushMatrix();    
        translate(sAstroThree[i].x, sAstroThree[i].y);
        rotate(radians(frameCount)/.5); 
        image(rockImages[3], 0, 0);
        popMatrix();
        if (shotCollision(sAstroThree[i].x, sAstroThree[i].y, smallRockSize, destroyedThree[i])) {
          destroyedThree[i] = true;
        }
      }
    }
  }
}

/**************************************************************
 * Function: borderWrap
 
 * Parameters: stroid - a PVector of the location of an astroid
 
 * Returns: Void
 
 * Desc: tests to see if an astroid is leaving the screen, if it
 is, it is repositioned on the other side.
 
 ***************************************************************/

void borderWrap(PVector stroid) {
  if (stroid.x > width) {
    stroid.x = 0;
  } else if (stroid.x < 0) {
    stroid.x = width;
  }
  if (stroid.y > height) {
    stroid.y = 0;
  } else if (stroid.y < 0) {
    stroid.y = height;
  }
}


void collisionDetection() {
  if (crashCounter  <= 90 ) { 
    for (int i = 0; i < astroNums; i ++) {
      if ((dist(shipLoc.x, shipLoc.y, astroids[i].x, astroids[i].y) < bigRockSize/2 + ship.width/2 && !hit[i]) ||
          (dist(shipLoc.x, shipLoc.y, sAstroOne[i].x, sAstroOne[i].y) < smallRockSize/2 + ship.width/2 && !destroyedOne[i]) ||
          (dist(shipLoc.x, shipLoc.y, sAstroTwo[i].x, sAstroTwo[i].y) < smallRockSize/2 + ship.width/2 && !destroyedTwo[i]) ||
          (dist(shipLoc.x, shipLoc.y, sAstroThree[i].x, sAstroThree[i].y) < smallRockSize/2 + ship.width/2 && !destroyedThree[i])) {
        if (crashCounter  == 0 ){
          crashCounter = 210;
        }
        hit[i] = true;
      }
    }
  }
}



void startScreen () {
  drawBackGround();
  image(frame, width/2, height/2);
  pushMatrix();
  textAlign(CENTER);
  rectMode(CENTER);
  strokeWeight(3);
  textSize(125);
  fill(255, 0, 0);
  text("ASTEROIDS", width/2, height/3);
  textSize(70);
  if (startButton) {
    stroke(0, 255, 0);
  } else {
    stroke(255);
  }
  fill(0);
  rect(width/2, height/3+175, 420, 100);
  fill(255, 0, 0);
  text("START", width/2, height/3 + 200);
  if (highScoreButton) {
    stroke(0, 255, 0);
  } else {
    stroke(255);
  }
  fill(0);
  rect(width/2, height/3+325, 420, 100);
  fill(255, 0, 0);
  text("HIGHSCORE", width/2, height/3 + 350);
  if (exitButton) {
    stroke(0, 255, 0);
  } else {
    stroke(255);
  }
  fill(0);
  rect(width/2, height/3+475, 420, 100);
  fill(255, 0, 0);
  text("EXIT", width/2, height/3 + 500);
  popMatrix();
  if (mouseX > width/2 - 210 && mouseX < width/2 + 210 && mouseY > height/3+125 && mouseY < height/3+225) {
    startButton = true;
    if (mousePressed) {
      startScreen = false;
    }
  } else {
    startButton = false;
  }
  if (mouseX > width/2 - 210 && mouseX < width/2 + 210 && mouseY > height/3+275 && mouseY < height/3+375) {
    highScoreButton = true;
  } else {
    highScoreButton = false;
  }
  if (mouseX > width/2 - 210 && mouseX < width/2 + 210 && mouseY > height/3+425 && mouseY < height/3+525) {
    exitButton = true;
    if (mousePressed) {
      exit();
    }
  } else {
    exitButton = false;
  }
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) { 
      sUP=true;
    }
    if (keyCode == DOWN) { 
      sDOWN=true;
    }
    if (keyCode == RIGHT) { 
      sRIGHT=true;
    }
    if (keyCode == LEFT) { 
      sLEFT=true;
    }
  }
  if (key == ' ') { 
    sSPACE=true;
  } //fire a shot
  if (key == 'w') { 
    sUP=true;
  }
  if (key == 's') { 
    sDOWN=true;
  }
  if (key == 'd') { 
    sRIGHT=true;
  }
  if (key == 'a') { 
    sLEFT=true;
  }
  if (key == 'f') { 

    cleanArray();
  }
}
void keyReleased() {
  if (key == CODED) {
    if (keyCode == UP) { 
      sUP=false;
    }
    if (keyCode == DOWN) { 
      sDOWN=false;
    }
    if (keyCode == RIGHT) { 
      sRIGHT=false;
    }
    if (keyCode == LEFT) { 
      sLEFT=false;
    }
  }
  if (key == ' ') { 
    sSPACE=false;
  } //fire a shot
  if (key == 'w') { 
    sUP=false;
  }
  if (key == 's') { 
    sDOWN=false;
  }
  if (key == 'd') { 
    sRIGHT=false;
  }
  if (key == 'a') { 
    sLEFT=false;
  }
}

/**************************************************************
 * Function: shotCollision
 
 * Parameters: 
 - astroidX - float - the X location of the center of the 
 asteroid to be tested
 - astroidY - float - the Y location of the center of the 
 asteroid to be tested
 - rockSize - interger - the size of the astroid to be tested
 - dead - boolean - make sure asteroid tested is an asteroid 
 that is being displayed
 
 * Returns: 
 - collision - boolean - if there has been a collision returns 
 true, else returns false.
 
 * Desc: used to test individual asteroids against all shots in 
 the shots array to see if there has been a collision. if there 
 has been, the shot is removed from the shots array and an 
 explosion is displayed with an accompanying explosion sound.
 ***************************************************************/
 
boolean shotCollision(float astroidX, float astroidY, int rockSize, boolean dead) {
  boolean collision = false;
  rockSize/=2;
  for (int i = 0; i < shots.size(); i++) {
    if ((shots.get(i).x >= (astroidX - rockSize)) && (shots.get(i).x <= (astroidX + rockSize)) 
    && (shots.get(i).y >= (astroidY - rockSize)) && (shots.get(i).y <= (astroidY + rockSize))) {
      if (!dead){
        collision = true;
        shots.remove(i);
        sDirections.remove(i);
        score++;
        explosionsList = append(explosionsList, 0);
        explosionsList = append(explosionsList, int(astroidX));
        explosionsList = append(explosionsList, int(astroidY));
        boomSound.play();
      }
    }
  }
  return collision;
}

/**************************************************************
 * Function: createAstro
 
 * Parameters: None
 
 * Returns: Void
 
 * Desc: used to create arrays for use with asteroids.
  ***************************************************************/
 
void createAstro(){
    for (int i = 0; i < astroNums; i++) {
    astroids[i] = new PVector(0, random(0, height));// may want to change so not all astroids start from left edge
    astroDirect[i] = new PVector(random(-astroSpeed, astroSpeed), random(-astroSpeed, astroSpeed));
    sAstroOne[i] = new PVector(astroids[i].x, astroids[i].y);
    sAstroTwo[i] = new PVector(astroids[i].x, astroids[i].y);
    sAstroThree[i] = new PVector(astroids[i].x, astroids[i].y);
    sAstroDirectOne[i] = new PVector(random(-sAstroSpeed, sAstroSpeed), random(-sAstroSpeed, sAstroSpeed));
    sAstroDirectTwo[i] = new PVector(random(-sAstroSpeed, sAstroSpeed), random(-sAstroSpeed, sAstroSpeed));
    sAstroDirectThree[i] = new PVector(random(-sAstroSpeed, sAstroSpeed), random(-sAstroSpeed, sAstroSpeed));
    hit[i] = false;
    destroyedOne[i] = false;
    destroyedTwo[i] = false;
    destroyedThree[i] = false;
    }
}

/**************************************************************
 * Function: isNextLevel
 
 * Parameters: None
 
 * Returns: 
 - nextLevel - boolean - if a new level is required returns true
 else returns false
 
 * Desc: iterates throuh asteroid boolean arrays and uses a 
 counter to see if all asteroids on current level have been
 destroyed.
  ***************************************************************/
  
boolean isNextLevel(){
  boolean nextLevel = false;
  int counter = 0;
  for (int i = 0; i < astroNums; i++){
    if (hit[i] && destroyedOne[i] && destroyedTwo[i] && destroyedThree[i]){
      counter++;
    }
    if (counter == astroNums){
      nextLevel = true;
    }
  }
  return nextLevel;
}
/**************************************************************
 * Function: levelUp
 
 * Parameters: None
 
 * Returns: void
 
 * Desc: when it is time for the next level, increases number of
 asteroids as well as increasing their potential speed.
 
 /////////TODO finish the game once max level complete/////////////////////////////////////////////
  ***************************************************************/    
void levelUp(){
  if (isNextLevel()){
    level++;
    backGroundRandomizer = level % 4;
    if (level <= levelMax){
      astroNums += increaseAstros;
      if (astroSpeed < maxAstroSpeed){
        astroSpeed += astroAccel;
      }
      if (sAstroSpeed < maxsAstroSpeed){
        sAstroSpeed += sAstroAccel;
      }
      resetArrays();
      createAstro();
    } 
  }// }else} game finished
}

/**************************************************************
 * Function: resetArrays
 
 * Parameters: None
 
 * Returns: void
 
 * Desc: creates temporary arrays to reset existing arrays so 
 they can be resized.
  ***************************************************************/
void resetArrays(){
      PVector[] astroTemp = new PVector[astroNums];
      astroids = astroTemp;
      PVector[] astroDirectTemp = new PVector[astroNums];
      astroDirect = astroDirectTemp;
      PVector[] sAstroOneTemp = new PVector[astroNums];
      sAstroOne = sAstroOneTemp;
      PVector[] sAstroTwoTemp = new PVector[astroNums];
      sAstroTwo = sAstroTwoTemp;
      PVector[] sAstroThreeTemp = new PVector[astroNums];
      sAstroThree = sAstroThreeTemp;
      PVector[] sAstroDirectOneTemp = new PVector[astroNums];
      sAstroDirectOne = sAstroDirectOneTemp;
      PVector[] sAstroDirectTwoTemp = new PVector[astroNums];
      sAstroDirectTwo = sAstroDirectTwoTemp;
      PVector[] sAstroDirectThreeTemp = new PVector[astroNums];
      sAstroDirectThree = sAstroDirectThreeTemp;
      boolean[] hitTemp = new boolean [astroNums];
      hit = hitTemp;
      boolean[] destroyedOneTemp = new boolean [astroNums];
      destroyedOne = destroyedOneTemp;
      boolean[] destroyedTwoTemp = new boolean [astroNums];
      destroyedTwo = destroyedTwoTemp;
      boolean[] destroyedThreeTemp = new boolean [astroNums];
      destroyedThree = destroyedThreeTemp;
}