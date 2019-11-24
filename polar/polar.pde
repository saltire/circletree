int rate = 30;

boolean polarMode = true;

float sizePct = .95;
float totalXSize;
float totalYSize;

int segmentPoints = 10;

int maxDepth = 8;
int maxDrawDepth = maxDepth;

float twistPeriod = 6000;
float maxTwistAmount = TAU / 8;
float twistAmount = 0;

float splitPeriod = 6000;
float maxSplitAmount = 1;
float splitAmount = 0;

float shutterPeriod = 1500; // window for on OR off animation
float shutterDuration = 700; // animation length within window
float shutterStart = (shutterPeriod - shutterDuration) / 2; // animation start time within window
float shutterMaxStartMod = 400; // max +/- variation of animation start time
float tt; // milliseconds into on AND off cycle
float t; // milliseconds into on OR off cycle
boolean firstHalf; // on or off

float getShutterPos(float startMod) {
  float start = shutterStart + startMod * shutterMaxStartMod;
  return ease(constrain(norm(t, start, start + shutterDuration), 0, 1));
}

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
  size(1000, 1000);
  noiseSeed(49152);
  ellipseMode(RADIUS);

  if (polarMode) {
    totalXSize = TAU;
    totalYSize = min(width, height) * sizePct / 2;
    tree = new KDTree(maxDepth);
  }
  else {
    totalXSize = width * sizePct;
    totalYSize = height * sizePct;
    tree = new KDTree(maxDepth);
  }
}

void draw() {
  twistAmount = cos(TAU * millis() / twistPeriod) * maxTwistAmount;
  splitAmount = cos(TAU * millis() / splitPeriod) * maxSplitAmount;

  tt = millis() % (shutterPeriod * 2); // 0 -> ((ct + pt) * 2)
  t = tt % shutterPeriod; // 0 -> (ct + pt)
  firstHalf = tt < shutterPeriod;

  background(32);
  fill(0);

  if (polarMode) {
    translate(width / 2, height / 2);
    circle(0, 0, totalYSize);
  }
  else {
    translate((width - totalXSize) / 2, (height - totalYSize) / 2);
    rect(0, 0, totalXSize, totalYSize);
  }

  drawTree(tree, 0, 0, totalXSize, totalYSize);
}

void drawTree(KDTree tree, float x, float y, float xSize, float ySize) {
  if (tree.depth < maxDrawDepth) {
    float split = tree.splitNoise * splitAmount;

    if (tree.xAxis) {
      float xSplit = xSize * split;
      drawTree(tree.leftChild, x, y, xSize / 2 + xSplit, ySize);
      drawTree(tree.rightChild, x + xSize / 2 + xSplit, y, xSize / 2 - xSplit, ySize);
    }
    else {
      float ySplit = ySize * split;
      drawTree(tree.leftChild, x, y, xSize, ySize / 2 + ySplit);
      drawTree(tree.rightChild, x, y + ySize / 2 + ySplit, xSize, ySize / 2 - ySplit);
    }
  }
  else {
    if (tree.filled) {
      noStroke();
      fill(firstHalf ? 255 : 0);
      drawCell(x, y, xSize, ySize);

      push();
        blendMode(firstHalf ? MULTIPLY : SCREEN);
        for (int c = 0; c < 3; c++) {
          fill((firstHalf ? subColors : addColors)[c]);
          drawCell(x, y, xSize * getShutterPos(tree.colorNoise[c]), ySize);
        }
      pop();
    }

    stroke(255);
    noFill();
    drawCell(x, y, xSize, ySize);
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
  if (twistAmount != 0) {
    x += twistAmount * y / totalYSize;
  }

  if (polarMode) {
    vertex(sin(x) * y, cos(x) * y);
  }
  else {
    vertex(x, y);
  }
}
