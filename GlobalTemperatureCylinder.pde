import java.util.Map;
import com.hamoid.*;

VideoExport videoExport;

PFont helveticaSmall;
PFont helveticaLarge;

color blue = color(127,127,255);
color white = color(255,255,255);
color red = color(255,0,0);

StringList _seaIceData;
int _lineCount = 0;
StringDict _data = new StringDict();
StringDict _elNinoLaNinaData = new StringDict();

float _minTemp = 100.0;
float _maxTemp = 0.0;
float _tempRange = 0.0;

color _coolColor = color(0, 63,0);
color _warmColor = color(255,255,0);

float _currentMaxTemp;

void setup(){
  size(1000,1000,P3D);
  helveticaSmall = createFont("helvetica-normal-58c348882d347.ttf", 50);
  helveticaLarge = createFont("helvetica-normal-58c348882d347.ttf", 64);
  textFont(helveticaLarge);
  textAlign(CENTER, CENTER);
  textMode(SHAPE);
  frameRate(30);
  strokeWeight(4);
  strokeCap(PROJECT);
  loadData();
  
  float fov = PI/6;
  float cameraZ = (height/2.0) / tan(fov/2.0);
  perspective(fov, float(width)/float(height), cameraZ/10.0, cameraZ*10.0);
  camera(width/2, height/2 - 500, 3000, width/2, height/2, 0, 0, 1, 0);
  
  videoExport = new VideoExport(this);
  videoExport.setFrameRate(30);
  videoExport.startMovie();
}


void draw(){ 
  
  //camera(500, 500, 866.0254, 500, 500, 0,0,1,0);
  //println(frameCount/365+1978);
  background(0);
  lights();
  //ambientLight(255, 255, 255);
  
  fill(255);

  //rotateX( PI );
  
  float lastTemp = 666;
  float lastX = 0.0;
  float lastZ = 0.0;
  
  translate( width/2, 1000, -1000 );
  
  float angle = (TWO_PI*(((frameCount+690)/1.5) % 365.0)/365.0) + PI;
  rotateY(-angle);
  renderScales();
  
  int maxD = frameCount*5;
    
  pushMatrix();
    stroke(0);
    strokeWeight(1);
    textFont(helveticaLarge);
    rotateY(angle);
    
    text("Global temperature change\n(1880-2017)",0,-990,0);
    text("@kevpluck",0,-864,0);
    int displayYear = maxD/12+1880;
    if(displayYear>2017) displayYear=2017;  // TODO, in 2018 increase by 1 :-)
    text(displayYear,-10,-778,0);
        
    textFont(helveticaSmall);
    
    text("-0.5°C",     -740,-0.5 * -500 - 300,0);
    text(" 0.0°C",     -740, 0.0 * -500 - 300,0);
    text(" 0.5°C",     -740, 0.5 * -500 - 300,0);
    text(" 1.0°C",     -740, 1.0 * -500 - 300,0);
    text(" 1.5°C",     -740, 1.5 * -500 - 300,0);
    text(" 2.0°C",     -740, 2.0 * -500 - 300,0);
  
    text("Sources: GHCN-v3 + SST: ERSST v4\nBase line: 1951-1980", 0, 600,0);
  
  popMatrix();
  
  float runningMaxTemp = -100.0;
  
  for(int d=0; d<=maxD;d++)
  {
    int year = d / 12;
    year += 1880;
    int month = d % 12 + 1;
    float r = 2*PI * d/12.0;
    float x = (float) Math.sin(r) * 600;
    float z = (float) Math.cos(r) * 600;
    
    String tempStr = GetData(year, month);
    
    if(tempStr == "") 
    {
      pushStyle();
      pushMatrix();
        strokeWeight(10);
        stroke(255,0,0);
        fill(0,255,0);
        translate(lastX,-lastTemp*500-300,lastZ);
        sphere(10);
      popMatrix();
      popStyle();
      
      continue;
    }
    
    float temp = float(tempStr);
    
    if(lastTemp == 666) 
    {
      lastTemp = temp;
      lastX = x;
      lastZ = z;
    }
    
    if(temp > runningMaxTemp)
    {      
      runningMaxTemp = temp;
      if(runningMaxTemp>_currentMaxTemp)
        _currentMaxTemp = runningMaxTemp; //<>//
      
      if(runningMaxTemp == _currentMaxTemp)
      {     
        pushMatrix();
          fill(255);
          rotateY(angle);
          text(year,     740, temp * -500 - 300, 0);
        popMatrix();
      }
    }
    
    color lerpColor = lerpColor(_coolColor, _warmColor, (float(year)-1880.0)/(2017.0-1880.0));
    float colorBrightness = modelZ - z;
    println(colorBrightness);
    
    
    stroke(lerpColor);
    strokeWeight(3);
    line(x, -temp*500-300, z, lastX, -lastTemp*500-300, lastZ);
    
    lastX = x;
    lastZ = z;
    lastTemp = temp;
  }
  videoExport.saveFrame();
  
  
  if(frameCount > 600){
    videoExport.endMovie();
    exit();
  }
}


void loadData()
{
  String[] lines = loadStrings("GLB.Ts+dSST.csv");
  
  for (String line : lines) {
    if(line.charAt(0) == 'L' || line.charAt(0) == 'Y') continue;
    
    String[] values = split(line, ',');
    String year = values[0];
    for(int month = 1;month<=12;month++)
    {
      float temp = float(values[month]);
      if(temp > _maxTemp) _maxTemp = temp;
      if(temp < _minTemp) _minTemp = temp;
      _data.set(year + "/" +month, values[month]);
    }
    
    _tempRange = _maxTemp - _minTemp;
    
  }

}


public void renderScales()
{
  textFont(helveticaLarge);
  pushMatrix();
  rotateX(PI/2);
  //text("January",0,600,0);
  
  text("January", 0,600,-200);
  rotateZ(-PI/6);
  text("February", 0,600,-200);
  rotateZ(-PI/6);
  text("March", 0,600,-200);
  rotateZ(-PI/6);
  text("April", 0,600,-200);
  rotateZ(-PI/6);
  text("May", 0,600,-200);
  rotateZ(-PI/6);
  text("June", 0,600,-200);
  rotateZ(-PI/6);
  text("July", 0,600,-200);
  rotateZ(-PI/6);
  text("August", 0,600,-200);
  rotateZ(-PI/6);
  text("September", 0,600,-200);
  rotateZ(-PI/6);
  text("October", 0,600,-200);
  rotateZ(-PI/6);
  text("November", 0,600,-200);
  rotateZ(-PI/6);
  text("December", 0,600,-200);
  
  popMatrix();
}

public static DateTime GetNonLeapYear()
{
  return new DateTime(2001,1,1,0,0,0,0);
}
  
public String GetData(int year, int month)
{
  if(year==2017 && month > 8) return "";
  if(year>=2018) return "";
  
  return _data.get(year + "/" + month);
}