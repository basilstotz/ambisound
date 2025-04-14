
class Atom { 
//attributes

float[][] xyz = new float[memory][3];
float[] r = new float[memory];
color c;

//constructor
Atom(float[] xyz) {
this.xyz[0] = xyz;
this.r[0] = pixels(0.025); // 2.5 cm radius ball
this.c = color(120,100,100); // green color
}

void render(int i) { // 0 < i < memory
  noStroke();
  pushMatrix(); 
  translate(xyz[i][0], xyz[i][1], xyz[i][2]);
  fill(c);
  sphere(r[i]);
  popMatrix();
}

void render2(int i) {
  pushMatrix();
  strokeWeight(2);
  stroke(c, -255/memory * i + 255);
  line(xyz[i][0], xyz[i][1], xyz[i][2], xyz[i-1][0], xyz[i-1][1], xyz[i-1][2]);
  popMatrix();
}

/* This procedure acts as a buffer of past coordinate in a FIFO mode */
void fifo(float[] xyz) {
 for (int i = memory - 1; i > 0; i--) {
   arrayCopy(this.xyz[i-1], this.xyz[i]);
   this.r[i] = -this.r[0] / memory * i + this.r[0] ; // linear interpolation from r[0] to 0 at i = memory
 }
}

} 
