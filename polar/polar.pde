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
float skew;

boolean cells[][] = new boolean[xcells][ycells];

float cellNoiseScale = 5;

void setup() {
  frameRate(rate);
  size(600, 600);
  noiseSeed(49152);
  stroke(255);

  for (int x = 0; x < xcells; x++) {
    for (int y = 0; y < ycells; y++) {
      cells[x][y] = noise(x * cellNoiseScale, y * cellNoiseScale) > .5;
    }
  }
}

void draw() {
  translate(width / 2, height / 2);

  skew = sin(TAU * millis() / skewPeriod) * skewAmount;

  for (int y = 0; y < ycells; y++) {
    for (int x = 0; x < xcells; x++) {
      float radius = y * cellWidth;
      float angle = x * cellAngle;

      fill(cells[x][y] ? 255 : 0);
      beginShape();
        for (float a = 0; a < segmentPoints; a++) {
          radius += pointWidth;
          polarVertex(angle, radius);
        }
        for (float a = 0; a < segmentPoints; a++) {
          angle += pointAngle;
          polarVertex(angle, radius);
        }
        for (float a = 0; a < segmentPoints; a++) {
          radius -= pointWidth;
          polarVertex(angle, radius);
        }
        for (float a = 0; a < segmentPoints; a++) {
          angle -= pointAngle;
          polarVertex(angle, radius);
        }
      endShape(CLOSE);
    }
  }
}

void polarVertex(float angle, float radius) {
  float skewAngle = angle + skew * radius / circleRadius;
  vertex(sin(skewAngle) * radius, cos(skewAngle) * radius);
}
