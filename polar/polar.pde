int rate = 30;

int xcells = 20;
int ycells = 10;
float circleRadius = 275;
int cellCurvePoints = 5;
float cellAngle = TAU / xcells;
float pointAngle = cellAngle / cellCurvePoints;
float ringWidth = circleRadius / ycells;

float skewAmount = 0;
float skewPeriod = 2000;

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

  float skew = sin(TAU * millis() / skewPeriod) * skewAmount;

  for (int y = 0; y < ycells; y++) {
    for (int x = 0; x < xcells; x++) {
      float radius = y * ringWidth;
      float angle = x * cellAngle + y * skew;

      fill(cells[x][y] ? 255 : 0);
      beginShape();
        vertex(sin(angle) * radius, cos(angle) * radius);
        for (float a = 0; a < cellCurvePoints; a++) {
          angle += pointAngle;
          vertex(sin(angle) * radius, cos(angle) * radius);
        }
        radius += ringWidth;
        angle += skew;
        vertex(sin(angle) * radius, cos(angle) * radius);
        for (float a = 0; a < cellCurvePoints; a++) {
          angle -= pointAngle;
          vertex(sin(angle) * radius, cos(angle) * radius);
        }
      endShape(CLOSE);
    }
  }
}
