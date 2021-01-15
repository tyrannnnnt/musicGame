PImage welcome;
PImage ins;
PImage GamePlay;
PImage twinkle;
PImage overpage;
PFont photoshoot;
int speed = 8;
int stage;
int notegap = 280; //row width
float scale = 1.35;
int combo = 0;
int rows = 4;
int twinkleTime = 15;
int lastJudge = -1; //init : -1 miss : 0 charming : 1
float score = 0;
int charmingNum = 0;
int upperBond = 66; //where notes appears
int bottomBond = 680; //where notes should be hitted
int maxCombo = 0;
int firstLineX = 80; //leftbond of the first row
int secondLineX = firstLineX + notegap;
int thirdLineX = secondLineX + notegap;
int forthLineX = thirdLineX + notegap;
String[] lines;
int totalNum; //total number of notes
PImage note;
int maxNotes = 1000;
float[] x  = new float [maxNotes];
float[] y  = new float [maxNotes];
boolean[] visiable = new boolean[maxNotes];
boolean[] alive = new boolean[maxNotes];  //when notes pass the bottom bond alive=false
boolean[] charming = new boolean[maxNotes];
int[] twinkleTimer = new int[rows]; //when a charming hit, twinkle last for a while
int[] outputX = new int [0]; //used for recording a song
int[] outputY = new int [0]; //used for recording a song
int time = -5;
int songIndex; //song selected (from 0 to maxSongIndex-1)
int maxSongIndex = 4;
int[] songLength = {80326,80326,44000,44000};

//set music
import ddf.minim.*;
Minim minim;
AudioPlayer[] songs = new AudioPlayer[maxSongIndex];
AudioPlayer wel;

void setup()
{
  stage = 0;
  
  //image
  welcome = loadImage("welcome.png");
  ins = loadImage("ins.png");
  GamePlay = loadImage("GamePlay.png");
  twinkle = loadImage("twinkle.png");
  overpage = loadImage("gameover.png");
  size(welcome.width, welcome.height);
  
  //music
  minim = new
  Minim(this);
  wel = minim.loadFile("Henry.mp3");
  
  //font
  photoshoot = createFont("type.ttf",60);
  
  gamePlaySetup();
}

void draw()
{
  //welcome stage = 0 
  //instrunction stage = 1
  //gameplay stage = 2
  //result stage = 3
  if(stage == 0)
  {
    image(welcome, 0, 0, welcome.width, welcome.height);
    wel.play();
    if(wel.position() == wel.length())
    {
      wel.rewind();
      wel.play();
    }
  }
  else if(stage == 1)
  {
    image(ins, 0, 0, welcome.width, welcome.height);
  }  
  else if(stage == 2)
  {
    image(GamePlay, 0, 0, welcome.width, welcome.height);
    gamePlayDraw();
    showText();
    if(songs[songIndex].position() >= songLength[songIndex])
    {
      songs[songIndex].pause();
      stage++;
    }
  }
  else if(stage == 3)
  {
    image(overpage,0 , 0, welcome.width, welcome.height);
    wel.play();
    showScore();
    if(wel.position() == wel.length())
    {
      wel.rewind();
      wel.play();
    }
  }
}

void keyPressed()
{
  //welcome stage = 0 
  //instrunction stage = 1
  //gameplay stage = 2
  //result stage = 3
  if(stage == 0)
  {
    songIndex = key - '1';
    if (songIndex >= 0 && songIndex < maxSongIndex)
    {
      stage = stage + 1;
      lines = loadStrings("lines"+songIndex+".txt");
      println(songIndex);
      totalNum = lines.length;
      note = loadImage("note.png");    
      loadNotes();
    }
  }  
  else if(stage == 1)
  {   
    stage = stage + 1;
    wel.pause();
    songs[songIndex].play();
  }  
  else if(stage == 2)
  {
    judge();
    keyPressOutput();
  }
  else if(stage == 3)
  {
    if (key == 'r' || key == 'R' )
    {
      stage = 0;
      charmingNum = 0;
      maxCombo = 0;
      combo = 0;
      lastJudge = -1;
      score = 0;
      wel.pause();
      setup();
    }
  }
     
}

void gamePlaySetup()
{
  for (int i = 0; i < maxSongIndex; i++)
  {
    songs[i] = minim.loadFile("song"+i+".mp3");
  }
  
  for(int i = 0; i < twinkleTimer.length; i++)
  {
    twinkleTimer[i] = 0;
  }
  textAlign(CENTER, CENTER);
}

//draw notes and twinkles
void gamePlayDraw()
{
  for (int i = 0; i < totalNum; i++)
  {
    if(y[i]>upperBond-note.height )
    {
      visiable[i] = true;
    }
          
    if(visiable[i] == true && alive[i] == true)
    {
      image(note, x[i], y[i], note.width*scale, note.height*scale);
    }
    float downRange = bottomBond + ((note.height)*2);
    float downerRange = bottomBond + ((note.height)*3);
    if(charming[i] == false && y[i]>downRange &&y[i]<downerRange )
    {
      combo = 0;
      lastJudge = 0;
    }
      
    y[i] = y[i] + speed;
      
  } 
  for(int i = 0; i < twinkleTimer.length; i++)
  {
    if(twinkleTimer[i]>0)
    {
      twinkleTimer[i] = twinkleTimer[i] - 1;
      imageMode(CENTER);
      image(twinkle, firstLineX+(i*notegap)+80, bottomBond, (twinkle.width*scale*(twinkleTime+1-twinkleTimer[i])/twinkleTime),
      (twinkle.height*scale*(twinkleTime+1-twinkleTimer[i]))/twinkleTime);
      imageMode(CORNER);
    }
  }
  time = time - speed;
}

//jugde if a keyboard input is charming or not
void judge()
{
  for (int i = 0; i < totalNum; i ++)
  { 
    isCharming(i);
    if(charming[i] == true)
    {
      combo = combo + 1;
      if(combo > maxCombo)
      {
        maxCombo = combo;
      }
      visiable[i] = false;
      charmingNum = charmingNum + 1;
      score = (float(charmingNum)/float(totalNum))*100;

      alive[i] = false;
      lastJudge = 1;     
      return;
    }  
  }
  
  //miss
  combo = 0;
  lastJudge = 0;
}


void isCharming(int i)
{
  float upRange = bottomBond-(note.height)*3.5;
  float downRange = bottomBond + note.height*2;
  if(key == 's' && x[i] == firstLineX
     && y[i] > upRange
     && y[i] < downRange)    
    {
      charming[i] = true;
      twinkleTimer[0] = twinkleTime;
    }
    else if(key == 'd' && x[i] == secondLineX
             && y[i] > upRange
             && y[i] < downRange)
    {
      charming[i] = true;
      twinkleTimer[1] = twinkleTime;
    }
    else if(key == 'j' && x[i] == thirdLineX
            && y[i] > upRange
            && y[i] < downRange)
    {
      charming[i] = true;
      twinkleTimer[2] = twinkleTime;
    }
    else if(key == 'k' && x[i] == forthLineX
            && y[i] > upRange
            && y[i] < downRange)
    {
      charming[i] = true;
      twinkleTimer[3] = twinkleTime;
    }
    else
    {
      charming[i] = false;
    }
}

//show score combo and charming/miss
void showText()
{
  fill(#FFFFFF);
  textSize(25);
  textFont(photoshoot);
  text(combo,1135,280);
  if(lastJudge == 1)
  {
    textSize(40);
    text("charming",1130,330);
  }
  else if(lastJudge == 0)
  {
    textSize(40);
    text("miss",1130,330);
  }
  textSize(60);
  text(nf(score, 0, 2)+"%",1100,40);
}

//load the notes from notechart to array
void loadNotes()
{
  for(int i = 0; i < lines.length; i++)
  {    
      String[] pieces = split(lines[i], '\t');
   
      if (pieces.length == 2)
      {
        x[i] = int(pieces[0]);
        y[i] = int(pieces[1])+685;
        visiable[i] = false;
        alive[i] = true;
        charming[i] = false;
      }
  }
}

void keyPressOutput()
{
  if(key == 's')
    {
      outputX = append(outputX, firstLineX);
    }
    if(key == 'd')
    {
      outputX = append(outputX, secondLineX);
    }
    if(key == 'j')
    {
      outputX = append(outputX, thirdLineX);
    }
    if(key == 'k')
    {
      outputX = append(outputX, forthLineX);
    }
    outputY = append(outputY, time);
    
}

//generate the notechart to output.txt(when recording a song)
void mousePressed()
{
  /*String[] lines = new String[outputX.length];
  for (int i = 0; i < outputX.length; i++)
  {
    lines[i] = outputX[i] + "\t" + outputY[i];
  }
  saveStrings("output1.txt", lines);
  exit();*/
}

void showScore()
{
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(100);
  textFont(photoshoot);
  text(nf(score, 0, 2)+"%",230 ,280);
  textSize(60);
  text(charmingNum+"/"+lines.length, 170 ,540);
  textSize(60);
  text(maxCombo, 445 ,540);  
}
  
  
  


      
  
  
      
    
   


