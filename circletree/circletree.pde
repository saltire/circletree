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

float cycleTime = 1200;
float pauseTime = 300;
float animTime = 700;
float spreadTime = 400;
float spreadRandom = 50;

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
  float c = floor(millis() / ((cycleTime + pauseTime) * 2));
  float tt = millis() % ((cycleTime + pauseTime) * 2); // 0 -> ((ct + pt) * 2)
  float t = tt % (cycleTime + pauseTime); // 0 -> (ct + pt)
  boolean firstHalf = tt < cycleTime + pauseTime;

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
        float animStart = (cycleTime - animTime) / 2;
        for (int i = 0; i < 3; i++) {
          fill((light ? subColors : addColors)[i]);
          float cStart = animStart +
            map(noise(x, y, i), 0, 1, -spreadTime, spreadTime);
            // (i - 1) * spreadTime +
            // map(noise(x, y, i), 0, 1, -spreadRandom, spreadRandom);
          float w = constrain(norm(t, cStart, cStart + animTime), 0, 1);
          rect(0, 0, xs * ease(w), ys);
        }
      pop();
    }
  }


  // float dist = 100;
  // float radius = 300;
  // push();
  //   translate(width / 2, height / 2);
  //   for (int i = 0; i < 3; i++) {
  //     push();
  //       float angle = float(i) / 3 * TAU;
  //       translate(sin(angle) * dist, cos(angle) * dist);
  //       fill(subColors[i]);
  //       circle(0, 0, radius);
  //     pop();
  //   }
  // pop();
}
