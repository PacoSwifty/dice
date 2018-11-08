import java.util.*;
//This project takes in an image titled testImg.jpg which should be saved in the source folder with the PDE as well as seven dice images,
//labeled dice1.jpg, dice2.jpg, etc.
//It scans the original source image and replaces chunks of it with various number sides of dice, the amount of black on each side of the 
//dice corresponds to an amount of "grey" in any given chunk of the source image. 

final int D1_BUCKET = 1;
final int D2_BUCKET = 2;
final int D3_BUCKET = 3;
final int D4_BUCKET = 4;
final int D5_BUCKET = 5;
final int D6_BUCKET = 6;

final int NORMAL_DICE = 1;
final int BLACK_DICE = 2;
final int WEIGHTED_DICE = 3;
final int INVERTED_NORMAL = 4;
//Set which dice to use here:
final int DICE_TYPE = INVERTED_NORMAL;

PImage img, greyImg, greyContrastImg, dice1, dice2, dice3, dice4, dice5, dice6;
float matrix[][], d1Matrix[][], d2Matrix[][], d3Matrix[][], d4Matrix[][], d5Matrix[][], d6Matrix[][];
color c;
float r, g, b;

//Counter variables used in printing out the instructions to rebuild it in person
int numInstructionsInOneLine = 0;
int maxInstructionsInOneLine = 10;
int numDiceInstructed = 0;
int numDiceInOneRow;
int instructionRowCount = 1;
String instructions = "-------Row:"+instructionRowCount+"------- ";



void setup() {
  img = loadImage("testImg.jpg");
  greyImg = loadImage("testImg.jpg");

  setUpIndividualDiceImages(DICE_TYPE);
  createDiceMatrices();

  loadPixels();
  colorMode(RGB, 255);
  
  //We crop the width and height so that the image divides evenly into a number of dice with no remaining pixels on the edges.
  int totalWidth = img.width - (img.width%dice1.width);
  int totalHeight = img.height - (img.height%dice1.height);
  int numDiceWide = totalWidth / dice1.width;
  int numDiceHigh = totalHeight / dice1.height;
  numDiceInOneRow = numDiceWide;
  println(numDiceWide + " dice across");
  println(numDiceHigh + " dice tall"); 
  println(numDiceWide * numDiceHigh + " total dice."); 
  
    size(totalWidth, totalHeight, P2D);

  dice();
}

void draw() {
  image(img, 0, 0, img.width, img.height);
  updatePixels();
  save("DicedImage.jpg");
}


//the dice method is computationally expensive but does basically everything and saves the created image in
//the source folder so it can be opened later without running the program. 
//First it runs through the entire source image which is represented in a long, single array, and copies it into a 2D array, which makes 
//substituting dice easier. 
//Basically the meat of the method lies in the nested for loops. In the outer one, incrementing the variable l, each tile is examined and 
//the inner two loops iterate over each pixel in the tile, 
//determing an average grey value for a given tile. Once that grey value has been determined, the conditionals determine which dice image 
//should be displayed in each tile and edits the 2D array of the whole image with the smaller 2D array of the corresponding dice image. 

void dice() {
  int widthDice = dice1.width; 
  int heightDice = dice1.height;
  int divisionx = widthDice;
  int divisiony = heightDice;
  float maxGrey = determineMaxGrey();
  float minGrey = determineMinGrey();

  float greyRange = maxGrey-minGrey;
  float rangeIncrement = greyRange/6;

  int c=0;
  int r=0;
  matrix = new float[img.width][img.height];
  //This loop builds a 2D array of all of the pixels in the sample image
  for (int i = 0; i<img.width*img.height; i++) {
    matrix[c][r]=img.pixels[i];
    c++;
    if (c%img.width==0) {
      c=0;
      r++;
    }
  }
  r=0;
  c=0;

  //avgGreyTile refers to the average greyscaled value of all of the pixels in a tile
  float avgGreyTile = 0;
  for (int l=0; l < (img.width*img.height)/(dice1.width*dice1.height); l++) { // for every tile
    avgGreyTile = 0;
    int currentDiceTile = 0;
    for (int j=0; j<divisiony; j++) { //for row in tile
      for (int k=0; k<divisionx; k++) { //for every column in tile
        //This loop gets the average grey value of each pixel in a tile and adds it to a running total, 
        //which is later divided by the number of pixels in the tile to get the true average grey value of the tile
        avgGreyTile += (red((int)matrix[minimum(c+k, img.width-1)][minimum(r+j, img.height-1)])+green((int)matrix[minimum(c+k, img.width-1)][minimum(r+j, img.height-1)])+blue((int)matrix[minimum(c+k, img.width-1)][minimum(r+j, img.height-1)]))/3;
      }
    } 
    avgGreyTile=avgGreyTile/(widthDice*heightDice);

    //Decide which side of the die this tile should be:
    if (avgGreyTile <= rangeIncrement) {
      currentDiceTile = D6_BUCKET;
    } else if (avgGreyTile <= 2*rangeIncrement && avgGreyTile > rangeIncrement) {
      currentDiceTile = D5_BUCKET;
    } else if (avgGreyTile <= 3*rangeIncrement && avgGreyTile > 2*rangeIncrement) {
      currentDiceTile = D4_BUCKET;
    } else if (avgGreyTile <= 4*rangeIncrement && avgGreyTile > 3*rangeIncrement) {
      currentDiceTile = D3_BUCKET;
    } else if (avgGreyTile <= 5*rangeIncrement && avgGreyTile > 4*rangeIncrement) {
      currentDiceTile = D2_BUCKET;
    } else {
      currentDiceTile = D1_BUCKET;
    }

    updateInstructions(currentDiceTile);

    //once the tile has determined what side of the die should represent it, these nested loops replace the pixels in that tile with the corresponding
    //pixels from the determined side of the die.
    for (int j=0; j<divisiony; j++) {
      for (int k=0; k<divisionx; k++) {
        switch (currentDiceTile) {
        case D6_BUCKET:
          matrix[minimum(c+k, img.width-1)][minimum(r+j, img.height-1)]=d6Matrix[k][j];
          break;
        case D5_BUCKET:
          matrix[minimum(c+k, img.width-1)][minimum(r+j, img.height-1)]=d5Matrix[k][j];
          break;
        case D4_BUCKET:
          matrix[minimum(c+k, img.width-1)][minimum(r+j, img.height-1)]=d4Matrix[k][j];
          break;
        case D3_BUCKET:
          matrix[minimum(c+k, img.width-1)][minimum(r+j, img.height-1)]=d3Matrix[k][j];
          break;
        case D2_BUCKET:
          matrix[minimum(c+k, img.width-1)][minimum(r+j, img.height-1)]=d2Matrix[k][j];
          break;
        case D1_BUCKET:
          matrix[minimum(c+k, img.width-1)][minimum(r+j, img.height-1)]=d1Matrix[k][j];
          break;
        }
      }
    }

    if (c<img.width-(divisionx+img.width%widthDice))
      c+=divisionx;
    else {
      c=0;
      if (r<img.height-divisiony)
        r+=divisiony;
    }
  }
  c=0;
  r=0;
  for (int i=0; i<img.width*img.height; i++) {
    img.pixels[i]=(int)matrix[c][r];
    c++;
    if (c%img.width==0) {
      c=0;
      r++;
    }
  }
  
  updatePixels();
  String[] instructionsArray = split(instructions, " ");
  saveStrings("instructions.txt", instructionsArray);
  save("DicedImage.jpg");
}



void updateInstructions(int currentTile) {
  boolean inverted = DICE_TYPE == INVERTED_NORMAL;
  
  switch(currentTile) {
  case D1_BUCKET:
    instructions += inverted ? "6," : "1,";
    break;
  case D2_BUCKET:
    instructions += inverted ? "5," : "2,";
    break;
  case D3_BUCKET:
    instructions += inverted ? "4," : "3,";
    break;
  case D4_BUCKET:
    instructions += inverted ? "3," : "4,";
    break;
  case D5_BUCKET:
    instructions += inverted ? "2," : "5,";
    break;
  case D6_BUCKET:
    instructions += inverted ? "1," : "6,";
    break;
  }
  numInstructionsInOneLine++;
  numDiceInstructed++;

  if (numInstructionsInOneLine >= maxInstructionsInOneLine) {
    instructions+=" ";
    numInstructionsInOneLine = 0;
  }
  if (numDiceInstructed >= numDiceInOneRow) {
    instructionRowCount++;
    instructions +=" -------Row:"+instructionRowCount+"------- ";
    numDiceInstructed = 0;
    numInstructionsInOneLine = 0;
  }
}

//The idea behind determineMaxGrey and determineMinGrey is that they should scan the source image and determine the maximum and minimum grey values in an image so
//if the source image is really dark and there is no grey value above ~127, the image won't just be made up of 4's, 5's, and 6's. Currently these methods check every pixel
//and are generally uselss because most source images have min and max grey values pretty close to 0 and 255. To be more efficient they should go through the "tiles" that are 
//replaced with dice and come up with an average grey value for each chunk.

//ToDo - this looks at the individual pixels in an image. Maybe break the image into tiles, get the average grey of that tile and use that for minimum/maximum purposes.
//this would prevent a single pitch black/white pixel from skewing the min/max value.
float determineMaxGrey() {
  float maxGrey = 0;
  float currGrey = 0;
  for (int i=0; i<img.width*img.height; i++) {
    currGrey = (red(greyImg.pixels[i])+green(greyImg.pixels[i])+blue(greyImg.pixels[i]))/3;
    if (currGrey>maxGrey)
      maxGrey=(float)currGrey;
  }
  return maxGrey;
}

float determineMinGrey() {
  float minGrey = 255;
  float currGrey = 0;
  for (int i=0; i<img.width*img.height; i++) {
    currGrey = (red(greyImg.pixels[i])+green(greyImg.pixels[i])+blue(greyImg.pixels[i]))/3;
    if (currGrey<minGrey)
      minGrey=(float)currGrey;
  }
  return minGrey;
}


int minimum(int x, int y) {
  if (x<=y)
    return x;
  else
    return y;
}

// Decides which dice images we want to use based on constants defined at the top of the class 
void setUpIndividualDiceImages(int diceType) {
  String d1, d2, d3, d4, d5, d6;

  switch (diceType) {
  case NORMAL_DICE:
    d1 = "dice1.png";
    d2 = "dice2.png";
    d3 = "dice3.png";
    d4 = "dice4.png";
    d5 = "dice5.png";
    d6 = "dice6.png";
    break;
  case WEIGHTED_DICE:
    d1 = "dice1weighted.jpg";
    d2 = "dice2weighted.jpg";
    d3 = "dice3weighted.jpg";
    d4 = "dice4weighted.jpg";
    d5 = "dice5weighted.jpg";
    d6 = "dice6weighted.jpg";
    break;
  case BLACK_DICE:
    d1 = "blackDice1.png";
    d2 = "blackDice2.png";
    d3 = "blackDice3.png";
    d4 = "blackDice4.png";
    d5 = "blackDice5.png";
    d6 = "blackDice6.png";
    break;
    case INVERTED_NORMAL:
    d1 = "dice6.png";
    d2 = "dice5.png";
    d3 = "dice4.png";
    d4 = "dice3.png";
    d5 = "dice2.png";
    d6 = "dice1.png";
    
    break;
  default:
    d1 = "dice1.png";
    d2 = "dice2.png";
    d3 = "dice3.png";
    d4 = "dice4.png";
    d5 = "dice5.png";
    d6 = "dice6.png";
    break;
  }

  dice1 = loadImage(d1);
  dice2 = loadImage(d2);
  dice3 = loadImage(d3);
  dice4 = loadImage(d4);
  dice5 = loadImage(d5);
  dice6 = loadImage(d6);
}

//This sets up the initial dice matrices that represent each side of a die.
void createDiceMatrices() {
  d1Matrix = new float[dice1.width][dice1.height];
  d2Matrix = new float[dice2.width][dice2.height];
  d3Matrix = new float[dice3.width][dice3.height];
  d4Matrix = new float[dice4.width][dice4.height];
  d5Matrix = new float[dice5.width][dice5.height];
  d6Matrix = new float[dice6.width][dice6.height];

  int c = 0;
  int r = 0;
  for (int i=0; i<dice1.pixels.length; i++) {
    d1Matrix[c][r] = dice1.pixels[i];
    d2Matrix[c][r] = dice2.pixels[i];
    d3Matrix[c][r] = dice3.pixels[i];
    d4Matrix[c][r] = dice4.pixels[i];
    d5Matrix[c][r] = dice5.pixels[i];
    d6Matrix[c][r] = dice6.pixels[i];
    c++;
    if (c%dice1.width==0) {
      c=0;
      r++;
    }
  }
}

