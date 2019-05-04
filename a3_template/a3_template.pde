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

PImage frame,ship,ufo,nebula1,nebula2,nebula3,nebula4,stars1,stars2,stars3,stars4,stars5,rock1,rock2,rock3,rock4;
PShape thrust;
int nebulaRandomizer,backGroundRandomizer, nebulaPosRandomizerX, nebulaPosRandomizerY;

int astroNums=20;
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
float turnSpeed = 0.10;
PVector shipLoc;
PVector shipVel;
float shipFric = 0.98;
int speedLimit = 6;
float thrusterPower = 0.15;
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
boolean alive=true;

void setup() {
  fullScreen();
  //size(1200, 800);

  shipLoc = new PVector(width/2, height/2);
  shipVel = new PVector(0, 0); 
  noFill();
  stroke(255);
  thrust = createShape(TRIANGLE, -25, 0, -15, -5, -15, 5);
  
  imageMode(CENTER);
  frame   = loadImage("frame.png");
  ship    = loadImage("ship.png");
  ufo     = loadImage ("ufo.png");
  nebula1 = loadImage ("nebula1.png");
  nebula2 = loadImage ("nebula2.png");
  nebula3 = loadImage ("nebula3.png");
  nebula4 = loadImage ("nebula4.png");
  stars1  = loadImage ("stars1.png");
  stars2  = loadImage ("stars2.png");
  stars3  = loadImage ("stars3.png");
  stars4  = loadImage ("stars4.png");
  stars5  = loadImage ("stars5.png");
  rock1   = loadImage("rock1.png");
  rock2   = loadImage("rock2.png");
  rock3   = loadImage("rock3.png");
  rock4   = loadImage("rock4.png"); 
  nebulaRandomizer =int(random(1,5));
  backGroundRandomizer =int(random(1,6));
  nebulaPosRandomizerX =int(random(0,width));
  nebulaPosRandomizerY =int(random(0,height));

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
  hit[5] = true; //for demonstration purposes only
  destroyedOne[5] = true; //for demonstration purposes only
  //initialise shapes if needed
}

void draw() {
  drawBackGround();
  //might be worth checking to see if you are still alive first
  collisionDetection();
  drawShots();
  drawShip();
  // report if game over or won
  drawAstroids();
  drawHud();// draw score
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

  if (shipLoc.y < 0) { 
    shipLoc.y = height;
  }            //border wraps
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
    shipVel.add(PVector.fromAngle(shipAngle));
  }           //speed up
  //if(sDOWN){  shipVel.y = shipVel.y+shipAcc.y; }  // brakes are for girls
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
  moveShip();

  pushMatrix();    
  translate(shipLoc.x, shipLoc.y);
  rotate(shipAngle);
  image(ship, 0, 0); 
  if (sUP) {
    shape(thrust, 0, 0);
  } 
  popMatrix();
}

void drawBackGround() {
  background(0);
  tint(90);
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
  else if (backGroundRandomizer == 5 ){
    image(stars5,width/2,height/2);
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
  textAlign(CENTER);
  image(frame,200,108);//,width,height);
  image(ship,50,175,40,30);
  image(ship,125,125,40,30);
  image(ship,200,85,40,30);
  fill(200, 100, 00);
  textSize(30);
  text("00", 350, 85);
  text("000", 125, 44);
  text("42", 50, 85);
  text("73", 275, 125);
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
    if (!hit[i]) {
      astroids[i].add(astroDirect[i]);
      borderWrap(astroids[i]);
      //ellipse for now TODO: PImage or PShape
      stroke(255);
      strokeWeight(3);
      noFill();
      image(rock1,astroids[i].x, astroids[i].y);
    }
    if (hit[i]) {
      sAstroOne[i].add(sAstroDirectOne[i]);
      borderWrap(sAstroOne[i]);
      sAstroTwo[i].add(sAstroDirectTwo[i]);
      borderWrap(sAstroTwo[i]);
      sAstroThree[i].add(sAstroDirectThree[i]);
      borderWrap(sAstroThree[i]);
      stroke(255);
      strokeWeight(3);
      noFill();
      if (!destroyedOne[i]) {
        image(rock2,sAstroOne[i].x, sAstroOne[i].y);
      }
      if (!destroyedTwo[i]) {
        image(rock3,sAstroTwo[i].x, sAstroTwo[i].y);
      }
      if (!destroyedThree[i]) {
        image(rock4,sAstroThree[i].x, sAstroThree[i].y);
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
  //check if shots have collided with astroids
  //check if ship as collided wiht astroids
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
  backGroundRandomizer =int(random(1,6));
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