// sound visualizer.


import ddf.minim.analysis.*;
import ddf.minim.*;
import processing.pdf.*;
import java.util.Calendar;

Minim       minim;
AudioPlayer[] myPlayer;
FFT         fft;
FFT         fft1;

int formResolution;
int stepSize;
int bands;
int numMusic;

float distortionFactor;
float initRadius;
float centerX, centerY;
float smooth_factor;
float scale;
float[][] x;
float[][] y;
float[] sum;

boolean filled;
boolean freeze;
boolean recordPDF;

boolean play1;
boolean play2;
boolean play3;

int[][] lineColor = {{100, 233, 255},{255, 255, 100},{255, 148, 15},{255, 15, 148}};

void setup()
{
  size(displayWidth, displayHeight);

  smooth();

  strokeWeight(0.05);

  stroke(0, 8);

  frameRate(30);

  background(0);

  noFill();

  initSound();

  initDefaultData();
}

void initSound()
{
  numMusic = 4;
  minim = new Minim(this);
  
  myPlayer = new AudioPlayer[numMusic];
  
  myPlayer[0] = minim.loadFile("9.mp3", 1024);
  myPlayer[1] = minim.loadFile("12.mp3", 1024);
  myPlayer[2] = minim.loadFile("18.mp3", 1024);
  myPlayer[3] = minim.loadFile("23.mp3", 1024);
  
  
  myPlayer[0].play(); 

  fft = new FFT( myPlayer[0].bufferSize(), myPlayer[0].sampleRate() );
  //fft1 = new FFT( myPlayer[1].bufferSize(), myPlayer[1].sampleRate() );

  bands = (fft.specSize() / (fft.specSize()/15));

  //sum = new float[bands];
}

void initDefaultData()
{
  float angle;

  recordPDF = false;
  filled    = false;
  freeze    = false;

  formResolution   = 15;
  stepSize         = 2;
  distortionFactor = 1;
  initRadius       = 100;
  scale            = 0.07;
  smooth_factor    = 0.2;
  
  
  play1 = true;
  play2 = true;
  play3 = true;

  x   = new float[numMusic][formResolution];
  y   = new float[numMusic][formResolution];
  sum = new float[bands];

  centerX = width/2; 
  centerY = height/2;

  angle = radians(360/float(formResolution));

  for (int i=0; i<numMusic; i++)
  {
    for (int j=0; j<formResolution; j++)
    {
      x[i][j] = cos(angle*j) * (initRadius +  50 * i);
      y[i][j] = sin(angle*j) * (initRadius +  50 * i);
    }
  }
  
}



void calcStepSize(int p)
{
  float range;

  fft.forward(myPlayer[p].mix);

  for (int i = 0; i < bands; i++) 
  {
    sum[i] += (fft.getBand(i) - sum[i]) * smooth_factor;

    range = (sum[i] * scale);

    x[p][i] += random(-range, range);
    y[p][i] += random(-range, range);
  }
}


void visualizeSound(int p)
{
  calcStepSize(p);
  
  stroke(lineColor[p][0], lineColor[p][1], lineColor[p][2]);
 
  beginShape();

  curveVertex(x[p][formResolution-1]+centerX, y[p][formResolution-1]+centerY);

  for (int i=0; i<formResolution; i++) 
  {
    curveVertex(x[p][i]+centerX, y[p][i]+centerY);
  }

  curveVertex(x[p][0]+centerX, y[p][0]+centerY);

  // end controlpoint
  curveVertex(x[p][1]+centerX, y[p][1]+centerY);

  endShape();
}

void draw() {
  
  
  
  if (myPlayer[0].isPlaying() == true) {
    visualizeSound(0);
  }
  
  if (myPlayer[0].isPlaying() == false) {
    if (play1 == true) {
      myPlayer[1].play();
      play1 = false;
    }
    if (myPlayer[1].isPlaying() == true)
        visualizeSound(1);
  }
  if ((myPlayer[0].isPlaying() == false) && (myPlayer[1].isPlaying() == false)) {
    if (play2 == true) {
      myPlayer[2].play();
      play2 = false;
    }
    if (myPlayer[2].isPlaying() == true)
       visualizeSound(2);
  }
  if ((myPlayer[0].isPlaying() == false) && (myPlayer[1].isPlaying() == false) && (myPlayer[2].isPlaying() == false)) {
    if (play3 == true) {
      myPlayer[3].play();
      play3 = false;
    }
    if (myPlayer[3].isPlaying() == true)
        visualizeSound(3);
  }
}

void keyReleased() {
  if (key == 's' || key == 'S') 
    saveFrame(timestamp()+"_##.png");
}


String timestamp() 
{
  Calendar now = Calendar.getInstance();

  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}
