class KDTree {
  float u;
  float v;
  int depth;

  boolean xAxis;

  boolean filled;
  float splitNoise;
  float[] colorNoise;

  KDTree leftChild;
  KDTree rightChild;

  KDTree(int maxDepth) {
    this(0, 0, 1, 1, 0, maxDepth);
  }

  KDTree(float u, float v, float uSize, float vSize, int depth, int maxDepth) {
    this.u = u; // x coordinate within the tree
    this.v = v; // y coordinate within the tree
    this.depth = depth;

    filled = noise(u * fillNoiseScale, v * fillNoiseScale) > .5;
    splitNoise = posNeg(ease(getNoise(splitNoiseScale), splitNoiseEasing)) *
      map(depth, 0, maxDepth, .25, 1); // Increase with depth
    colorNoise = new float[] {
      posNeg(getNoise(colorNoiseScale, 0)),
      posNeg(getNoise(colorNoiseScale, 1)),
      posNeg(getNoise(colorNoiseScale, 2)),
    };

    if (depth < maxDepth) {
      xAxis = depth % 2 == 1; // 1 = split vertically first instead of horizontally

      if (xAxis) {
        leftChild = new KDTree(u, v, uSize / 2, vSize, depth + 1, maxDepth);
        rightChild = new KDTree(u + uSize / 2, v, uSize / 2, vSize, depth + 1, maxDepth);
      }
      else {
        leftChild = new KDTree(u, v, uSize, vSize / 2, depth + 1, maxDepth);
        rightChild = new KDTree(u, v + vSize / 2, uSize, vSize / 2, depth + 1, maxDepth);
      }
    }
  }

  float getNoise(float noiseScale) {
    return noise(u * noiseScale, v * noiseScale);
  }

  float getNoise(float noiseScale, float w) {
    return noise(u * noiseScale, v * noiseScale, w * noiseScale);
  }
}
