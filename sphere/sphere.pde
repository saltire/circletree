float radius = 300;
int uSize = 16;
int vSize = 16;

// rotation angle on x-axis for isometric projection: 35.26439 deg
float isoAngle = atan(1 / sqrt(2));

void setup() {
  size(1000, 1000, P3D);
  ortho();
}

void draw() {
  background(0);
  noFill();
  ellipseMode(RADIUS);

  translate(width / 2, height / 2);
  rotateX(TAU / 4 - isoAngle); // upward for isometric projection with Z pointing up
  rotateZ(-frameCount * TAU / 720);

  // Draw a blue bounding box.
  stroke(color(0, 0, 255));
  strokeWeight(1);
  box(radius * 2);

  // Draw red dots at each intersection.
  stroke(color(255, 0, 0));
  strokeWeight(8);
  for (float u = 0; u <= uSize; u++) {
    for (float v = 0; v <= vSize; v++) {
      drawPoint(u / uSize, v / vSize);
    }
  }

  // Draw white grid lines (with the prime meridian emphasized).
  stroke(255);
  for (float u = 0; u <= uSize; u++) {
    strokeWeight(u == 0 ? 5 : 1);
    drawMeridian(u / uSize);
  }
  for (float v = 0; v <= vSize; v++) {
    drawParallel(v / vSize);
  }

  // Draw a big green dot where the mouse coordinates map onto the sphere.
  strokeWeight(15);
  stroke(color(0, 255, 0));
  drawPoint(float(mouseX) / width, float(mouseY) / height);
}

float phi(float u) {
  return lerp(0, TAU, u);
}

float theta(float v) {
  return lerp(0, TAU / 2, v);
}

void drawPoint(float u, float v) {
  float ph = phi(u);
  float th = theta(v);

  float x = radius * sin(th) * sin(ph);
  float y = radius * sin(th) * cos(ph);
  float z = radius * cos(th);

  point(x, y, z);
}

void drawMeridian(float u) {
  float ph = phi(u);

  pushMatrix();
  rotateZ(-ph);
  rotateY(TAU / 4);
  arc(0, 0, radius, radius, 0, TAU / 2);
  popMatrix();
}

void drawParallel(float v) {
  float th = theta(v);

  float z = radius * cos(th);
  float r = radius * sin(th);

  pushMatrix();
  translate(0, 0, z);
  ellipse(0, 0, r, r);
  popMatrix();
}
