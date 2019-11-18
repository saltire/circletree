int rate = 30;

float circleDiameterPct = .95;
float circleRadius;
int segmentPoints = 10;

int maxDepth = 8;
int maxDrawDepth = maxDepth;

float cellNoiseScale = 5;

float skewAmount = TAU / 8;
float skewPeriod = 2000;
float skew = 0;

float varyAmount = 1;
float varyPeriod = 6000;
float vary = 0;
float varyNoiseScale = .5;

float shutterPeriod = 1500; // window for on OR off animation
float shutterDuration = 700; // animation length within window
float shutterStart = (shutterPeriod - shutterDuration) / 2; // animation start time within window
float shutterMaxStartMod = 400; // max +/- variation of animation start time
float tt; // milliseconds into on AND off cycle
float t; // milliseconds into on OR off cycle
boolean firstHalf; // on or off

float getAnimPos(float startMod) {
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

class KDTree {
  float initX;
  float initY;
  int depth;

  boolean xAxis;
  boolean white;
  float thisVary;

  KDTree leftChild;
  KDTree rightChild;

  KDTree(float x, float y, float angle, float radius, int depth) {
    initX = x;
    initY = y;
    this.depth = depth;

    xAxis = depth % 2 == 0;
    white = noise(x * cellNoiseScale, y * cellNoiseScale) > .5;
    thisVary = getNoise(varyNoiseScale) * map(depth, 0, maxDepth, .25, 1); // Increase with depth

    if (depth < maxDepth) {
      if (xAxis) {
        leftChild = new KDTree(x, y, angle / 2, radius, depth + 1);
        rightChild = new KDTree(x + angle / 2, y, angle / 2, radius, depth + 1);
      }
      else {
        leftChild = new KDTree(x, y, angle, radius / 2, depth + 1);
        rightChild = new KDTree(x, y + radius / 2, angle, radius / 2, depth + 1);
      }
    }
  }

  float getNoise(float noiseScale) {
    return lerp(-1, 1, noise(initX * noiseScale, initY * noiseScale));
  }

  float getNoise(float noiseScale, float z) {
    return lerp(-1, 1, noise(initX * noiseScale, initY * noiseScale, z * noiseScale));
  }

  void draw(float x, float y, float angle, float radius) {
    if (depth < maxDrawDepth) {
      float currentVary = thisVary * vary;

      if (xAxis) {
        float angleVary = angle * currentVary;
        leftChild.draw(x, y, angle / 2 + angleVary, radius);
        rightChild.draw(x + angle / 2 + angleVary, y, angle / 2 - angleVary, radius);
      }
      else {
        float radiusVary = radius * currentVary;
        leftChild.draw(x, y, angle, radius / 2 + radiusVary);
        rightChild.draw(x, y + radius / 2 + radiusVary, angle, radius / 2 - radiusVary);
      }
    }
    else {
      if (white) {
        noStroke();
        fill(firstHalf ? 255 : 0);
        drawCell(x, y, angle, radius);

        push();
          blendMode(firstHalf ? MULTIPLY : SCREEN);
          for (int c = 0; c < 3; c++) {
            fill((firstHalf ? subColors : addColors)[c]);
            float startMod = lerp(-1, 1, noise(initX, initY, c));
            drawCell(x, y, angle * getAnimPos(startMod), radius);
          }
        pop();
      }

      stroke(255);
      noFill();
      drawCell(x, y, angle, radius);
    }
  }

  void drawCell(float x, float y, float angle, float radius) {
    float xx = x;
    float yy = y;

    float xInc = angle / segmentPoints;
    float yInc = radius / segmentPoints;

    beginShape();
      for (float a = 0; a < segmentPoints; a++) {
        yy += yInc;
        polarVertex(xx, yy);
      }
      for (float a = 0; a < segmentPoints; a++) {
        xx += xInc;
        polarVertex(xx, yy);
      }
      for (float a = 0; a < segmentPoints; a++) {
        yy -= yInc;
        polarVertex(xx, yy);
      }
      for (float a = 0; a < segmentPoints; a++) {
        xx -= xInc;
        polarVertex(xx, yy);
      }
    endShape(CLOSE);
  }
}

KDTree tree;

void setup() {
  frameRate(rate);
  size(1000, 1000);
  noiseSeed(49152);
  ellipseMode(RADIUS);

  circleRadius = min(width, height) * circleDiameterPct / 2;

  tree = new KDTree(0, 0, TAU, circleRadius, 0);
}

void draw() {
  background(32);
  translate(width / 2, height / 2);

  // skew = sin(TAU * millis() / skewPeriod) * skewAmount;
  vary = cos(TAU * millis() / varyPeriod) * varyAmount;

  tt = millis() % (shutterPeriod * 2); // 0 -> ((ct + pt) * 2)
  t = tt % shutterPeriod; // 0 -> (ct + pt)
  firstHalf = tt < shutterPeriod;

  fill(0);
  circle(0, 0, circleRadius);
  tree.draw(0, 0, TAU, circleRadius);
}

void polarVertex(float angle, float radius) {
  float skewAngle = angle + skew * radius / circleRadius;
  vertex(sin(skewAngle) * radius, cos(skewAngle) * radius);
}
