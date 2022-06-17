import oscP5.*;
import netP5.*;
import controlP5.*;

OscP5 oscP5;

int ntrailSize = 100;
int newTrailSize = 100;
ArrayList <PVector> positionsBuffer = new ArrayList<PVector>();
NetAddress juliaServer = new NetAddress("127.0.0.1", 7770);
boolean showControls = true;

ControlP5 controlP5;
float multiplier = 10.0;

float cameraRotateX;
float cameraRotateY;
float cameraSpeed;
boolean showAsTrail = true  ;

void setup() {
  for (int i = 0; i < ntrailSize; i++) positionsBuffer.add(new PVector());
  size(640, 480, P3D);
  cameraSpeed = TWO_PI / width*2;
  cameraRotateY = -PI/6;
  smooth();
  oscP5 = new OscP5(this, 7779);

  controlP5 = new ControlP5(this);
  controlP5.addSlider("multiplier")
    .setRange(0.01, 2000.0)
    .setValue(100.0)
    .setPosition(10, 80)
    .setSize(10, 100)
    .setColorValue(0xffff88ff)
    .setColorLabel(0xffdddddd);
  controlP5.addSlider("trailSize")
    .setRange(1, 200)
    .setValue(100)
    .setPosition(60, 80)
    .setSize(10, 100)
    .setColorValue(0xffff88ff)
    .setColorLabel(0xffdddddd);
    sphereDetail(10);
}

void draw() {
  lights();
  background(0);
  fill(255);
  directionalLight(126, 126, 126, 0, 0, -1);
  ambientLight(146, 237, 213);
  
  if (newTrailSize != ntrailSize) {
    println("newTrailSize:"+newTrailSize);
    
    while (positionsBuffer.size() < newTrailSize) {
      positionsBuffer.add(0,new PVector());
    }
    while (positionsBuffer.size() > newTrailSize) {
      positionsBuffer.remove(0);
    }
    
    
  }

  pushMatrix();

  translate(width/2+30, height/2+10);
  rotateX(cameraRotateY);
  rotateY(cameraRotateX);
  
  PVector lastPosition = positionsBuffer.get(positionsBuffer.size()-1);
  
  if (showAsTrail) {
    stroke(255);
    noFill();
  
    beginShape();
    for (int i = 0; i < positionsBuffer.size(); i++) { //PVector position: positionsBuffer) {
      PVector position = positionsBuffer.get(i);
      curveVertex(position.x*multiplier, position.y*multiplier, position.z*multiplier*2);
    }
    endShape();
  
    pushMatrix();
    stroke(#34E8DD);    
    translate(lastPosition.x*multiplier, lastPosition.y*multiplier, lastPosition.z*multiplier*2);
    sphere(10);
    popMatrix();
  } else {
    stroke(255);
    noFill();
  
    beginShape();
    for (int i = 0; i < positionsBuffer.size(); i++) { //PVector position: positionsBuffer) {
      PVector position = positionsBuffer.get(i);
      pushMatrix();
      translate(position.x*multiplier, position.y*multiplier, position.z*multiplier*2);
      //ellipse(0,0,10,10);
      sphere(2);
      popMatrix();
    }
    endShape();
  }

  popMatrix();
  text(lastPosition.x, 10, 20);
  text(lastPosition.y, 10, 30);
  text(lastPosition.z, 10, 40);
}

void oscEvent(OscMessage mensajeOSC) {
  if (mensajeOSC.addrPattern().equals("/ode")) {
    positionsBuffer.remove(0);
    PVector newPos = new PVector(
      (float)mensajeOSC.get(0).doubleValue(),
      (float)mensajeOSC.get(1).doubleValue(),
      (float)mensajeOSC.get(2).doubleValue());
    positionsBuffer.add(newPos);
  } else if (mensajeOSC.addrPattern().equals("/odes")) {
    String jsonMsg = mensajeOSC.get(0).stringValue();
    JSONArray json = parseJSONArray(jsonMsg);
    positionsBuffer.clear();
    for (int i = 0; i < json.size(); i+= 3) {
      PVector newPos = new PVector(json.getFloat(i),json.getFloat(i+1),json.getFloat(i+2));
      positionsBuffer.add(newPos);
    }
    
  }
}
void mouseMoved() {
  cameraRotateX += (mouseX - pmouseX) * cameraSpeed;
  cameraRotateY += (pmouseY - mouseY) * cameraSpeed;
}

void keyPressed() {
  if (key==' ') {
    showControls = !showControls;
  } else if (key == 't')  {
    showAsTrail = !showAsTrail;
  }
}

void controlEvent(ControlEvent theEvent) {


  if (theEvent.isController()) {
    if (theEvent.getController().getName()=="multiplier") {
      multiplier = theEvent.getController().getValue();
    } else if (theEvent.getController().getName()=="trailSize") {
      newTrailSize = (int)theEvent.getController().getValue();
      println(newTrailSize);
    } else if (theEvent.getController().getName()=="mu") {
      float value = theEvent.getController().getValue();
      OscMessage reqForDataChange = new OscMessage("/newMu");
      reqForDataChange.add(value);
      oscP5.send(reqForDataChange, juliaServer);
    } else if (theEvent.getController().getName()=="A") {
      float value = theEvent.getController().getValue();
      OscMessage reqForDataChange = new OscMessage("/newA");
      reqForDataChange.add(value);
      oscP5.send(reqForDataChange, juliaServer);
    } else if (theEvent.getController().getName()=="om") {
      float value = theEvent.getController().getValue();
      OscMessage reqForDataChange = new OscMessage("/newOm");
      reqForDataChange.add(value);
      oscP5.send(reqForDataChange, juliaServer);
    }
  }
}
