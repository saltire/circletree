int rate = 30;

int xcells = 20;
int ycells = 10;
float circleRadius = 275;
int segmentPoints = 5;
float cellAngle = TAU / xcells;
float cellWidth = circleRadius / ycells;
float pointAngle = cellAngle / segmentPoints;
float pointWidth = cellWidth / segmentPoints;

float skewAmount = TAU / 8;
float skewPeriod = 2000;
float skew = 0;

boolean cells[][] = new boolean[xcells][ycells];

float cellNoiseScale = 5;

class KDTree {
  float x;
  float y;
  float angle;
  float radius;

  boolean xAxis;
  boolean white;

  KDTree leftChild;
  KDTree rightChild;

  KDTree(float x, float y, float angle, float radius, int depth, int maxDepth) {
    this.x = x;
    this.y = y;
    this.angle = angle;
    this.radius = radius;

    xAxis = depth % 2 == 1;
    white = noise(x * cellNoiseScale, y * cellNoiseScale) > .5;

    if (depth < maxDepth) {
      if (xAxis) {
        leftChild = new KDTree(x, y, angle / 2, radius, depth + 1, maxDepth);
        rightChild = new KDTree(x + angle / 2, y, angle / 2, radius, depth + 1, maxDepth);
      }
      else {
        leftChild = new KDTree(x, y, angle, radius / 2, depth + 1, maxDepth);
        rightChild = new KDTree(x, y + radius / 2, angle, radius / 2, depth + 1, maxDepth);
      }
    }
  }

  void draw() {
    if (leftChild != null && rightChild != null) {
      leftChild.draw();
      rightChild.draw();
    }
    else {
      fill(white ? 255 : 0);

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
}

KDTree tree;

void setup() {
  frameRate(rate);
  size(600, 600);
  noiseSeed(49152);
  stroke(255);

  tree = new KDTree(0, 0, TAU, circleRadius, 0, 8);
}

void draw() {
  translate(width / 2, height / 2);

  tree.draw();

  // skew = sin(TAU * millis() / skewPeriod) * skewAmount;
}

void polarVertex(float angle, float radius) {
  float skewAngle = angle + skew * radius / circleRadius;
  vertex(sin(skewAngle) * radius, cos(skewAngle) * radius);
}
