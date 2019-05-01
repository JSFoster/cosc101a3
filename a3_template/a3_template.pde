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
**************************************************************/

PShape ship,thrust; // don't have to use pshape - can use image
int astroNums=20;
PVector[] astroids = new PVector[astroNums];
PVector[] astroDirect = new PVector[astroNums];

	//===== ship related globals ====
boolean sUP=false,sDOWN=false,sRIGHT=false,sLEFT=false,sSPACE=false;
float shipAngle=radians(270); 
float turnSpeed = 0.10;
PVector shipLoc;
PVector shipVel;
float shipFric = 0.98;
int speedLimit = 6;
float thrusterPower = 0.15;
float astroSpeed = 1.0;
boolean[] hit = new boolean [astroNums];
boolean[] destroyed = new boolean [astroNums];

ArrayList<PVector> shots= new ArrayList<PVector>();
ArrayList<PVector> sDirections= new ArrayList<PVector>();
PVector shotVel;
float shotSpeed = 1.1;

int score=0;
boolean alive=true;

void setup(){
  size(800,800);

  shipLoc = new PVector(width/2, height/2);
  shipVel = new PVector(0, 0); 
  noFill();
  stroke(255);
  ship = createShape(TRIANGLE, 15, 0, -15, -10, -15, 10);
  thrust = createShape(TRIANGLE, -25, 0, -15, -5, -15, 5);
  
  //initialise pvtecotrs
  //random astroid initial positions and directions;
  for (int i = 0; i < astroNums; i++){
    astroids[i] = new PVector(0, random(0,height));// may want to change so not all astroids start from left edge
    astroDirect[i] = new PVector(random(-astroSpeed,astroSpeed),random(-astroSpeed,astroSpeed));
    hit[i] = false;
    destroyed[i] = false;
  }
    
  //initialise shapes if needed
}

void draw(){
  background(0);
          //might be worth checking to see if you are still alive first
  collisionDetection();
  drawShots();
  drawShip();
          // report if game over or won
  drawAstroids();
          // draw score
}

/**************************************************************
* Function: myFunction()

* Parameters: None ( could be integer(x), integer(y) or String(myStr))

* Returns: Void ( again this could return a String or integer/float type )

* Desc: Each funciton should have appropriate documentation.
        This is designed to benefit both the marker and your team mates.
        So it is better to keep it up to date, same with usage in the header comment

***************************************************************/

void moveShip(){

  if (shipLoc.y < 0){ shipLoc.y = height; }            //border wraps
  if (shipLoc.y > height){ shipLoc.y = 0; }
  if (shipLoc.x < 0){ shipLoc.x = width; }
  if (shipLoc.x > width){ shipLoc.x = 0; }
  
  if(sUP) { shipVel.add(PVector.fromAngle(shipAngle));}           //speed up
    //if(sDOWN){  shipVel.y = shipVel.y+shipAcc.y; }  // brakes are for girls
  if(sRIGHT){ shipAngle = shipAngle+turnSpeed; } 
  if(sLEFT){  shipAngle = shipAngle-turnSpeed; }
  
  shipVel.mult(shipFric);         // slow down
  shipVel.limit(speedLimit);      // limit speed
  shipLoc.add(shipVel);           // change ship location
}

void drawShip(){
  moveShip();
  
  pushMatrix();    
  translate(shipLoc.x, shipLoc.y);
  rotate(shipAngle);
  println(shipLoc.heading());
  shape(ship,0,0); 
  if(sUP){shape(thrust,0,0);} 
  popMatrix();
  
}

void drawShots(){
   //draw points for each shot from spacecraft
   //at location and updated to new location
   fill(255);
   if (sSPACE) {
     shots.add(new PVector(shipLoc.x, shipLoc.y));
     sDirections.add(PVector.fromAngle(shipAngle));
   }
   for (int i = 0; i < shots.size(); i++) {
     ellipse(shots.get(i).x, shots.get(i).y, 2, 2);
     shotVel = sDirections.get(i);
     shots.get(i).add(shotVel);
   }
}

void drawAstroids(){
  //check to see if astroid is not already destroyed
  //otherwise draw at location
  //initial direction and location should be randomised
  //also make sure the astroid has not moved outside of the window
  for (int i = 0 ; i < astroNums ; i ++){
    if (!hit[i]){
      astroids[i].add(astroDirect[i]);
      if (astroids[i].x > width){
        astroids[i].x = 0;
      }
      else if (astroids[i].x < 0){
        astroids[i].x = width;
      }
      if (astroids[i].y > height){
        astroids[i].y = 0;
      }
      else if (astroids[i].y < 0){
        astroids[i].y = height;
      }
      //ellipse for now TODO: PImage or PShape
      stroke(255);
      strokeWeight(3);
      noFill();
      ellipse(astroids[i].x,astroids[i].y,50,30);
    }
  }
}


void collisionDetection(){
  //check if shots have collided with astroids
  //check if ship as collided wiht astroids
}



void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP)   { sUP=true; }
    if (keyCode == DOWN) { sDOWN=true; }
    if (keyCode == RIGHT){ sRIGHT=true; }
    if (keyCode == LEFT) { sLEFT=true; }
  }
  if (key == ' ') {  println("pew, pew"); sSPACE=true;} //fire a shot
  if (key == 'w'){ sUP=true; }
  if (key == 's'){ sDOWN=true; }
  if (key == 'd'){ sRIGHT=true; }
  if (key == 'a'){ sLEFT=true; }
}
void keyReleased() {
  if (key == CODED) {
    if (keyCode == UP)   { sUP=false; }
    if (keyCode == DOWN) { sDOWN=false; }
    if (keyCode == RIGHT){ sRIGHT=false; }
    if (keyCode == LEFT) { sLEFT=false; }
  }
  if (key == ' ') {  println("pew, pew"); sSPACE=false;} //fire a shot
  if (key == 'w'){ sUP=false; }
  if (key == 's'){ sDOWN=false; }
  if (key == 'd'){ sRIGHT=false; }
  if (key == 'a'){ sLEFT=false; }
}
