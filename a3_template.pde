/**************************************************************
* File: a3.pde
* Group: Joel Foster, Mark Anderson, *Add your names just testing git* (Group 30)
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
float radians=radians(0); //if your ship is facing up (like in atari game)
float turnSpeed = 0.05;
PVector shipLoc;
PVector shipVel;
PVector shipAcc;
PVector shipFric;
int speedLimit = 8;
float thrusterPower = 0.25;
float spaceFriction = 0.05;

ArrayList shots= new ArrayList();
ArrayList sDirections= new ArrayList();
boolean sUP=false,sDOWN=false,sRIGHT=false,sLEFT=false;
int score=0;
boolean alive=true;


void setup(){
  size(800,800);

  shipLoc = new PVector(width/2, height/2);
  shipVel = new PVector(0, 0);  
  shipAcc = new PVector(thrusterPower, thrusterPower);
  shipFric = new PVector(spaceFriction, spaceFriction);  
  ship = createShape(TRIANGLE, 0, -15, -10, 15, 10, 15);
  thrust = createShape(TRIANGLE, 0, 25, -5, 15, 5, 15);

  //initialise pvtecotrs
  //random astroid initial positions and directions;
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
  
  if (shipVel.y < 0){shipVel.y = shipVel.y + shipFric.y ;} // slow down
  else            {shipVel.y = shipVel.y - shipFric.y ;}
  
  if(sUP) {   shipVel.y = shipVel.y-shipAcc.y; }            //speed up
  if(sDOWN){  shipVel.y = shipVel.y+shipAcc.y; }
  if(sRIGHT){ radians = radians+turnSpeed; println("turning not working yet"); } 
  if(sLEFT){  radians = radians-turnSpeed; println("turning not working yet"); }
  
  shipVel.limit(speedLimit);                            // limit speed
  
  shipLoc.x = shipLoc.x + shipVel.x;            // change ship location
  shipLoc.y = shipLoc.y + shipVel.y;
}

void drawShip(){
  moveShip();
  
    pushMatrix();        
    translate(shipLoc.x, shipLoc.y);
    rotate(radians);   
    shape(ship,0,0); 
    if(sUP){shape(thrust,0,0);} 
    popMatrix();
  
}

void drawShots(){
   //draw points for each shot from spacecraft
   //at location and updated to new location
}

void drawAstroids(){
  //check to see if astroid is not already destroyed
  //otherwise draw at location
  //initial direction and location should be randomised
  //also make sure the astroid has not moved outside of the window

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
  if (key == ' ') {  println("pew, pew"); } //fire a shot
}
void keyReleased() {
  if (key == CODED) {
    if (keyCode == UP)   { sUP=false; }
    if (keyCode == DOWN) { sDOWN=false; }
    if (keyCode == RIGHT){ sRIGHT=false; }
    if (keyCode == LEFT) { sLEFT=false; }
  }
}
