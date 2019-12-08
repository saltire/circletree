int rate = 30;

String mode = "sphere";

float sizePct = .95; // Percent of the viewport that the grid takes up.
float mainRadius;
float totalXSize;
float totalYSize;

int segmentPoints = 10; // Number of vertices in each line segment.

int maxDepth = 8; // Nesting depth of the tree.

int maxDrawDepth = maxDepth;

boolean doFill = true; // Whether to fill in individual cells.
float fillNoiseScale = 25;

boolean doTwist = true; // Whether to skew the Y-axis.
float twistPeriod = 6000;
float maxTwistAmount = TAU / 8;
float twistAmount = 0;

boolean doSplit = true; // Whether to vary the splitMod ratio of each cell.
float splitNoiseScale = 5; // Higher = more mixed
float splitNoiseEasing = 5; // Higher = more extreme
float splitPeriod = 6000;
float maxSplitAmount = 1;
float splitAmount = 0;

boolean doShutter = false; // Whether to use a shutter effect to cycle the fill on and off.
boolean doColorShutter = false; // Whether to shutter the RGB channels separately.
float colorNoiseScale = 3;
float shutterPeriod = 1500; // window for on OR off animation
float shutterDuration = 700; // animation length within window
float shutterStart = (shutterPeriod - shutterDuration) / 2; // animation start time within window
float shutterMaxStartMod = 400; // max +/- variation of animation start time
float tt; // milliseconds into on AND off cycle
float t; // milliseconds into on OR off cycle
boolean firstHalf; // on or off

color red = color(255, 0, 0);
color green = color(0, 255, 0);
color blue = color(0, 0, 255);
color cyan = color(0, 255, 255);
color magenta = color(255, 0, 255);
color yellow = color(255, 255, 0);
color[] addColors = { red, green, blue };
color[] subColors = { cyan, magenta, yellow };

KDTree tree;

void setup() {
  frameRate(rate);
  size(1000, 1000, P3D);
  ortho();
  noiseSeed(49152);
  ellipseMode(RADIUS);

  if (mode == "polar") {
    mainRadius = min(width, height) * sizePct / 2;
    totalXSize = TAU;
    totalYSize = mainRadius;
  }
  else if (mode == "sphere") {
    mainRadius = min(width, height) * sizePct / 2;
    totalXSize = TAU;
    totalYSize = TAU / 2;
  }
  else {
    totalXSize = width * sizePct;
    totalYSize = height * sizePct;
  }

  tree = new KDTree(maxDepth);
}

void draw() {
  if (doTwist) {
    twistAmount = cos(TAU * millis() / twistPeriod) * maxTwistAmount;
  }
  if (doSplit) {
    splitAmount = cos(TAU * millis() / splitPeriod) * maxSplitAmount;
  }

  tt = millis() % (shutterPeriod * 2); // 0 -> ((ct + pt) * 2)
  t = tt % shutterPeriod; // 0 -> (ct + pt)
  firstHalf = tt < shutterPeriod;

  background(32);
  fill(0);
  noStroke();

  if (mode == "polar") {
    translate(width / 2, height / 2);
    // circle(0, 0, totalYSize);
  }
  else if (mode == "sphere") {
    translate(width / 2, height / 2);
    rotateX(TAU / 4 - isoAngle); // upward for isometric projection with Z pointing up
    rotateZ(TAU / 2); // move seam to the back
    // sphere(mainRadius * .99); // sphere is drawn with its axis on the Y-axis
  }
  else {
    translate((width - totalXSize) / 2, (height - totalYSize) / 2);
    // rect(0, 0, totalXSize, totalYSize);
  }

  drawTree(tree, 0, 0, totalXSize, totalYSize);
}

void drawTree(KDTree tree, float x, float y, float xSize, float ySize) {
  if (tree.depth < maxDrawDepth) {
    float splitMod = doSplit ? tree.splitNoise * splitAmount : 0;

    if (tree.xAxis) {
      float xSplitMod = (xSize / 2) * splitMod;
      drawTree(tree.leftChild, x, y, xSize / 2 + xSplitMod, ySize);
      drawTree(tree.rightChild, x + xSize / 2 + xSplitMod, y, xSize / 2 - xSplitMod, ySize);
    }
    else {
      float ySplitMod = (ySize / 2) * splitMod;
      drawTree(tree.leftChild, x, y, xSize, ySize / 2 + ySplitMod);
      drawTree(tree.rightChild, x, y + ySize / 2 + ySplitMod, xSize, ySize / 2 - ySplitMod);
    }
  }
  else {
    if (doFill && doShutter && tree.filled) {
      noStroke();
      fill(firstHalf ? 255 : 0);
      drawCell(x, y, xSize, ySize);

      push();
        if (doColorShutter) {
          blendMode(firstHalf ? MULTIPLY : SCREEN);
          for (int c = 0; c < 3; c++) {
            fill((firstHalf ? subColors : addColors)[c]);
            drawCell(x, y, xSize * getShutterPos(tree.colorNoise[c]), ySize);
          }
        }
        else {
          fill(firstHalf ? 0 : 255);
          drawCell(x, y, xSize * getShutterPos(0), ySize);
        }
      pop();

      stroke(255);
      noFill();
      drawCell(x, y, xSize, ySize);
    }
    else {
      stroke(255);
      if (doFill) {
        fill(tree.filled ? 255 : 0);
      }
      else {
        noFill();
      }
      drawCell(x, y, xSize, ySize);
    }
  }
}

void drawCell(float x, float y, float xSize, float ySize) {
  float xx = x;
  float yy = y;

  float xInc = xSize / segmentPoints;
  float yInc = ySize / segmentPoints;

  beginShape();
    for (float a = 0; a < segmentPoints; a++) {
      yy += yInc;
      drawVertex(xx, yy);
    }
    for (float a = 0; a < segmentPoints; a++) {
      xx += xInc;
      drawVertex(xx, yy);
    }
    for (float a = 0; a < segmentPoints; a++) {
      yy -= yInc;
      drawVertex(xx, yy);
    }
    for (float a = 0; a < segmentPoints; a++) {
      xx -= xInc;
      drawVertex(xx, yy);
    }
  endShape(CLOSE);
}

void drawVertex(float x, float y) {
  if (doTwist && twistAmount != 0) {
    x += twistAmount * y / totalYSize;
  }

  if (mode == "polar") {
    PVector v = polarCoords(x, y);
    vertex(v.x, v.y);
  }
  else if (mode == "sphere") {
    PVector v = sphereCoords(x, y);
    vertex(v.x, v.y, v.z);
  }
  else {
    vertex(x, y);
  }
}

PVector polarCoords(float x, float y) {
  return new PVector(sin(x) * y, cos(x) * y);
}

PVector sphereCoords(float x, float y) {
  return new PVector(
    mainRadius * sin(y) * sin(x),
    mainRadius * sin(y) * cos(x),
    mainRadius * cos(y));
}

float getShutterPos(float startMod) {
  float start = shutterStart + startMod * shutterMaxStartMod;
  return ease(constrain(norm(t, start, start + shutterDuration), 0, 1));
}
