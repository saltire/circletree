// rotation angle on x-axis for isometric projection: 35.26439 deg
float isoAngle = atan(1 / sqrt(2));

void rotateIsometric() {
  rotateX(-TAU / 4 + isoAngle); // upward for isometric projection with Z pointing up
}

void push() {
  pushMatrix();
  pushStyle();
}

void pop() {
  popMatrix();
  popStyle();
}

// Ease in and out.
float ease(float value) {
  return 3 * pow(value, 2) - 2 * pow(value, 3);
}

// Ease in and out, with a variable.
float ease(float value, float exp) {
  return value < 0.5 ?
    pow(value * 2, exp) / 2 :
    1 - pow((1 - value) * 2, exp) / 2;
}

float posNeg(float value) {
  return lerp(-1, 1, value);
}
