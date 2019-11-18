// https://twitter.com/RavenKwok/status/999714584138104832

int xcells = 40;
int ycells = 40;
float xsize;
float ysize;

int rate = 30;

boolean cells[][] = new boolean[xcells][ycells];

color red = color(255, 0, 0);
color green = color(0, 255, 0);
color blue = color(0, 0, 255);
color cyan = color(0, 255, 255);
color magenta = color(255, 0, 255);
color yellow = color(255, 255, 0);
color[] addColors = { red, green, blue };
color[] subColors = { cyan, magenta, yellow };

float shutterPeriod = 1500; // window for on OR off animation
float shutterDuration = 700; // animation length within window
float shutterStart = (shutterPeriod - shutterDuration) / 2; // animation start time within window
float shutterMaxStartMod = 400; // max +/- variation of animation start time
float tt; // milliseconds into on AND off cycle
float t; // milliseconds into on OR off cycle
boolean firstHalf; // on or off

float colorSpread = 20;

float cellNoiseScale = 5;
float rotNoiseScale = .2;

void setup() {
  frameRate(rate);
  size(600, 600);
  xsize = width / xcells;
  ysize = height / ycells;
  noStroke();
  ellipseMode(CENTER);
  noiseSeed(49152);

  for (int x = 0; x < xcells; x++) {
    for (int y = 0; y < ycells; y++) {
      cells[x][y] = noise(x * cellNoiseScale, y * cellNoiseScale) > .5;
    }
  }
}

void draw() {
  tt = millis() % (shutterPeriod * 2); // 0 -> ((ct + pt) * 2)
  t = tt % shutterPeriod; // 0 -> (ct + pt)
  firstHalf = tt < shutterPeriod;

  for (int x = 0; x < xcells; x++) {
    for (int y = 0; y < ycells; y++) {
      push();
        translate((x + .5) * xsize, (y + .5) * ysize);

        int rotation = floor(noise(x * rotNoiseScale, y * rotNoiseScale) * 4);
        rotate(TAU * rotation / 4);
        float xs = rotation % 2 == 0 ? xsize : ysize;
        float ys = rotation % 2 == 0 ? ysize : xsize;
        translate(-.5 * xs, -.5 * ys);

        boolean light = cells[x][y] ^ firstHalf;

        fill(light ? 255 : 0);
        rect(0, 0, xs, ys);

        blendMode(light ? MULTIPLY : SCREEN);
        for (int c = 0; c < 3; c++) {
          fill((light ? subColors : addColors)[c]);
          float startMod = lerp(-1, 1, noise(x, y, c));
          rect(0, 0, xs * getAnimPos(startMod), ys);
        }
      pop();
    }
  }
}

float getAnimPos(float startMod) {
  float start = shutterStart + startMod * shutterMaxStartMod;
  return ease(constrain(norm(t, start, start + shutterDuration), 0, 1));
}
