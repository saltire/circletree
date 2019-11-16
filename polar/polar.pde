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
float varyPeriod = 1600;
float vary = 0;
float varyNoiseScale = .5;

float shutterPeriod = 3000;
float shutterTime = 600;
float shutterModAmount = .5;
float shutterNoiseScale = .5;
float shutterPhase;
boolean shutterClosing;
float shutterPos;


class KDTree {
  float initX;
  float initY;
  int depth;

  boolean xAxis;
  boolean white;
  float thisVary;
  // float shutterModR;
  // float shutterModG;
  // float shutterModB;

  KDTree leftChild;
  KDTree rightChild;

  KDTree(float x, float y, float angle, float radius, int depth) {
    initX = x;
    initY = y;
    this.depth = depth;

    xAxis = depth % 2 == 0;
    white = noise(x * cellNoiseScale, y * cellNoiseScale) > .5;
    thisVary = getNoise(varyNoiseScale) * map(depth, 0, maxDepth, .25, 1); // Increase with depth
    // shutterModR = getNoise(shutterNoiseScale, 0);
    // shutterModG = getNoise(shutterNoiseScale, 1);
    // shutterModB = getNoise(shutterNoiseScale, 2);

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
      fill(white ? 255 : 0);
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
  stroke(255);

  circleRadius = min(width, height) * circleDiameterPct / 2;

  tree = new KDTree(0, 0, TAU, circleRadius, 0);
}

void draw() {
  background(32);
  translate(width / 2, height / 2);

  // skew = sin(TAU * millis() / skewPeriod) * skewAmount;
  vary = sin(TAU * millis() / varyPeriod) * varyAmount;

  shutterPhase = (millis() / shutterPeriod) % 1;
  shutterClosing = shutterPhase >= .5;
  float shutterMS = millis() % (shutterPeriod / 2);
  float shutterStart = (shutterPeriod / 2 - shutterTime) / 2;
  shutterPos = constrain(norm(shutterMS, shutterStart, shutterStart + shutterTime), 0, 1);

  tree.draw(0, 0, TAU, circleRadius);
}

void polarVertex(float angle, float radius) {
  float skewAngle = angle + skew * radius / circleRadius;
  vertex(sin(skewAngle) * radius, cos(skewAngle) * radius);
}
