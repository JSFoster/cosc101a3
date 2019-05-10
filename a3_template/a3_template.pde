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
 All images sourced from: https://www.kisspng.com 
 */

import processing.sound.*;
SoundFile thrustSound, laserSound, shotgunSound;
//SoundFile music;

PImage frame,hud,ship,ufo,nebula1,nebula2,nebula3,nebula4,stars1,stars2,stars3,stars4,rock1,rock2,rock3,rock4,thrust1,thrust2;
int nebulaRandomizer,backGroundRandomizer, nebulaPosRandomizerX, nebulaPosRandomizerY;

int astroNums=5;
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
PVector shipLoc;
PVector shipVel;
float shipFric = 0.986;
int speedLimit = 7;
float astroSpeed = 1.0;
float sAstroSpeed = 3.0;
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

int score=0;
int lives = 3;
int level = 1;
boolean alive=true;

// Start screen bools
boolean startScreen = true;
boolean startButton = false;
boolean highScoreButton = false;
boolean exitButton = false;

void setup() {
  //fullScreen();
  size(1440, 900);

  shipLoc = new PVector(width/2, height/2);
  shipVel = new PVector(0, 0); 
  noFill();
  stroke(255);
  
  imageMode(CENTER);
  frame   = loadImage("frame.png");
  hud     = loadImage("hud.png");
  ship    = loadImage("ship.png");
  thrust1 = loadImage("thrust1.png");
  thrust2 = loadImage("thrust2.png");
  ufo     = loadImage ("ufo.png");
  nebula1 = loadImage ("nebula1.png");
  nebula2 = loadImage ("nebula2.png");
  nebula3 = loadImage ("nebula3.png");
  nebula4 = loadImage ("nebula4.png");
  stars1  = loadImage ("stars1.png");
  stars2  = loadImage ("stars2.png");
  stars3  = loadImage ("stars3.png");
  stars4  = loadImage ("stars4.png");
  rock1   = loadImage("rock1.png");
  rock1.resize(bigRockSize,bigRockSize);
  rock2   = loadImage("rock2.png");
  rock2.resize(smallRockSize,smallRockSize);
  rock3   = loadImage("rock3.png");
  rock3.resize(smallRockSize,smallRockSize);
  rock4   = loadImage("rock4.png");
  rock4.resize(smallRockSize,smallRockSize);
  nebulaRandomizer =int(random(1,5));
  backGroundRandomizer =int(random(1,5));
  nebulaPosRandomizerX =int(random(0,width));
  nebulaPosRandomizerY =int(random(0,height));
  
  thrustSound =    new SoundFile(this, "thrust.mp3");
  laserSound =     new SoundFile(this, "laser.mp3");
  shotgunSound =   new SoundFile(this, "shotgun.mp3");
  //music        =   new SoundFile(this, "music.mp3");

  //initialise pvtecotrs
  //random astroid initial positions and directions;
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
  //hit[5] = true; //for demonstration purposes only
  //destroyedOne[5] = true; //for demonstration purposes only
  //initialise shapes if needed
}

void draw() {
  if (startScreen) {
    startScreen();
  } else {
    drawBackGround();
    //might be worth checking to see if you are still alive first
    drawShots();
    drawShip();
    // report if game over or won
    drawAstroids();
    drawHud();// draw score
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
  if(!sUP && thrustSound.isPlaying()== true ){
    thrustSound.stop();
  }
  if (sRIGHT) { 
    shipAngle = shipAngle+turnSpeed;
  } 
  if (sLEFT) {  
    shipAngle = shipAngle-turnSpeed;
  }

  shipVel.mult(shipFric);  // slow down
  shipVel.limit(speedLimit);      // limit speed
  shipLoc.add(shipVel);           // change ship location
}

void drawShip() {
  moveShip();
  pushMatrix();    
  translate(shipLoc.x, shipLoc.y);
  rotate(shipAngle+PI/2);
  if (sUP) {
    if(frameCount % 2 == 0 ){
      image(thrust1, 0, 35);
    }
    else {
      image(thrust2, 0, 35);
    }
  }
  image(ship, 0, 0); 
  popMatrix();
}

void drawBackGround() {
  background(0);
  tint(90);
  println(backGroundRandomizer,nebulaRandomizer);
  if (backGroundRandomizer == 1 ){
    image(stars1,width/2,height/2);
  }
  else if (backGroundRandomizer == 2 ){
    image(stars2,width/2,height/2); 
  }
  else if (backGroundRandomizer == 3 ){
    image(stars3,width/2,height/2); 
  }
  else if (backGroundRandomizer == 4 ){
    image(stars4,width/2,height/2);
  }
  if (nebulaRandomizer == 1 ){
    image(nebula1,nebulaPosRandomizerX,+nebulaPosRandomizerY);
  }
  else if (nebulaRandomizer == 2 ){
    image(nebula2,nebulaPosRandomizerX,+nebulaPosRandomizerY); 
  }
  else if (nebulaRandomizer == 3 ){
    image(nebula3,nebulaPosRandomizerX,+nebulaPosRandomizerY); 
  }
  else if (nebulaRandomizer == 4 ){
    image(nebula4,nebulaPosRandomizerX,+nebulaPosRandomizerY); 
  }
  noTint();
}

void drawHud() {
  image(frame,width/2,height/2);
  
  pushMatrix();    
  translate(175, height-150);
  
  textAlign(CENTER);
  image(hud,0,0);
  if (lives > 0){
    image(ship,-102,-67,23,35);
  }
  if (lives > 1){
    image(ship,-80,-67,23,35);
  }
    if (lives > 2){
    image(ship,-58,-67,23,35);
  }
  fill(200, 100, 00);
  textSize(22);
  text("Score", -80, 15);
  text(score, -80, 45);
  text("Level", -7, 58);
  text(level, -7, 88);
  
  if ( 1 == 1 ){
    image(rock3,-5,-18,40,40); // powerup placeholder
  }
  if ( 1 == 1 ){
    image(rock4,70,25,40,40); // powerup placeholder
  }
  
  popMatrix();
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
      ellipse(shots.get(i).x, shots.get(i).y, 2, 2);
      shotVel = sDirections.get(i).normalize();
      shotVel.mult(shotSpeed);
      shots.get(i).add(shotVel);
  }
}

/**************************************************************
 * Function: drawAstroids()
 
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
  //check to see if astroid is not already destroyed
  //otherwise draw at location
  //initial direction and location should be randomised
  //also make sure the astroid has not moved outside of the window
  for (int i = 0; i < astroNums; i ++) {
    if(shotCollision(astroids[i].x,astroids[i].y,bigRockSize)) {
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
      image(rock1,astroids[i].x, astroids[i].y);
    }
    if (hit[i]) {
      if (!destroyedOne[i]) {
        sAstroOne[i].add(sAstroDirectOne[i]);
        borderWrap(sAstroOne[i]);
        image(rock2,sAstroOne[i].x, sAstroOne[i].y);
        if (shotCollision(sAstroOne[i].x,sAstroOne[i].y,smallRockSize)){
          destroyedOne[i] = true;
        }
      }
      if (!destroyedTwo[i]) {
        sAstroTwo[i].add(sAstroDirectTwo[i]);
        borderWrap(sAstroTwo[i]);
        image(rock3,sAstroTwo[i].x, sAstroTwo[i].y);
        if (shotCollision(sAstroTwo[i].x,sAstroTwo[i].y,smallRockSize)){
          destroyedTwo[i] = true;
        }
      }
      if (!destroyedThree[i]) {
        sAstroThree[i].add(sAstroDirectThree[i]);
        borderWrap(sAstroThree[i]);
        image(rock4,sAstroThree[i].x, sAstroThree[i].y);
        if (shotCollision(sAstroThree[i].x,sAstroThree[i].y,smallRockSize)){
          destroyedThree[i] = true;
        }
      }
    }
  }
}

/**************************************************************
 * Function: borderWrap(stroid)
 
 * Parameters: stroid - a PVector of the location of an astroid
 
 * Returns: Void
 
 * Desc: tests to see if an astroid is leaving the screen, if it
 is, it is repositioned on the other side.
 
 ***************************************************************/
 
void borderWrap(PVector stroid){
      if (stroid.x > width){
        stroid.x = 0;
      }
      else if (stroid.x < 0){
        stroid.x = width;
      }
      if (stroid.y > height){
        stroid.y = 0;
      }
      else if (stroid.y < 0){
        stroid.y = height;
      }
}


void collisionDetection() {
  //check if shots have collided with astroids
  //check if ship as collided wiht astroids
}

void startScreen () {
  drawBackGround();
  image(frame,width/2,height/2);
  pushMatrix();
  textAlign(CENTER);
  rectMode(CENTER);
  strokeWeight(3);
  textSize(125);
  fill(255,0,0);
  text("ASTEROIDS", width/2, height/3);
  textSize(70);
  if (startButton) {
    stroke(0,255,0);
  } else {
    stroke(255);
  }
  fill(0);
  rect(width/2, height/3+175, 420, 100);
  fill(255,0,0);
  text("START", width/2, height/3 + 200);
  if (highScoreButton) {
    stroke(0,255,0);
  } else {
    stroke(255);
  }
  fill(0);
  rect(width/2, height/3+325, 420, 100);
  fill(255,0,0);
  text("HIGHSCORE", width/2, height/3 + 350);
  if (exitButton) {
    stroke(0,255,0);
  } else {
    stroke(255);
  }
  fill(0);
  rect(width/2, height/3+475, 420, 100);
  fill(255,0,0);
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
  nebulaRandomizer =int(random(1,5));
  backGroundRandomizer =int(random(1,5));
  nebulaPosRandomizerX =int(random(0,width));
  nebulaPosRandomizerY =int(random(0,height));
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

boolean shotCollision(float astroidX, float astroidY, int rockSize){
  boolean collision = false;
  rockSize/=2;
  for (int i = 0; i < shots.size(); i++){
    if ((shots.get(i).x >= (astroidX - rockSize)) && (shots.get(i).x <= (astroidX + rockSize)) && (shots.get(i).y >= (astroidY - rockSize)) && (shots.get(i).y <= (astroidY + rockSize))){
      collision = true;
      shots.remove(i);
      sDirections.remove(i);
    }
  }
  return collision;
}
   
