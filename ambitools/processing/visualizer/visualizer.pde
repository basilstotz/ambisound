/* Soundscape visualizer
 * Licence CC-BY-NC-SA-4.0
 * (c) Pierre Lecomte 
 */

// TODO: Add control with joysticks: http://lagers.org.uk/gamecontrol/index.html
// Changelog
// (2022-09-15) v1.1
// - Cartesian / Spherical coordinate choice at compilation
// 

//###Visualizer###
// This tool helps in the visualization of the sound scene. It shows the signal level in dBFS of each loudspeaker in space as well as the positions and trajectories of the spatialized sources. These parameters are updated from OSC messages.
// <div style="width:100%; margin:0 auto;" align="center" markdown="1">
// {% figure caption: "The Visualizer in action!" label:visualizer%}
// ![Image]({{site.baseurl}}/assets/docs/visualizer.gif){:.rounded.border.shadow}
// {%endfigure%}
// </div>
// An example is shown in Fig. {% figref visualizer %} for a Lebedev loudspeaker array with $N = 50$ loudspeakers and $s=5$ sources.
// Each loudspeaker is materialized by a ball whose color and size changes according to the dBFS signal level it receives. The low signal levels are green and the higher levels turn to red. Above 0 dBFs the color stays red and means that the signal is clipped.
// At the origin of the coordinate system stands a human head that faces the positive $x$ direction and whose ears are aligned in the horizontal plane.
// Each spatialized source is materialized by a colored ball. When the source moves, a fading trail is drawn to help visualize the trajectory.
// The sources trajectories can be materialized with discrete balls at the past positions of the sources or with continuous curves.
// It is possible to move the visualization by clicking and dragging the mouse and zooming in and out with the mouse wheel.
//
// ## Compilations parameters
// - `array`: CSV file containing the spherical coordinates of a $N$ loudspeaker array, for instance `my_array.csv`. This file should be placed in subfolder `/data/my_array.csv` of the Processing sketch. 
//    The file header, i.e. the first line, should be  `r,t,p`, (meaning $(r, \theta, \phi)$). On the following lines are given the spherical coordinates of each loudspeaker: radius $r$ in meters, azimuth angle $\theta$ in degrees, and elevation angle $\phi$ in degree.
//    One loudspeaker per line and a comma `,` separator between each coordinate is required.
// - `port`: OSC listening port, for instance `5511`.
// - `s`: number of sources to draw.
// - `memory` : The number of past positions for the source trajectory visualisation.
// - `coord` : Choice of coordinate system for the OSC messages : `0` => Spherical, `1` => Cartesian.
// - `trajectory` : Choice of the trajectory type : `0` => discrete balls, `1` => continuous curve
//
// ## OSC message syntax
// To make the viewer "alive", OSC messages should be sent to the port `port` with the following syntax for the $n$-th loudspeaker (with $0 < n < N-1$), and for the $i$-th source (with $0 < i < s$):
//
// |             Element                         |     OSC         | Min value | Max value |
// |:-------------------------------------------:|:---------------:|:---------:|:---------:|
// |          $n$-th Loudspeaker gain (dB)       | `loudspeaker_n` |    -70    |     6     |
// |       Radius $r$) (m) (`coord = 0`)         |  `radius_i`     |    0      | $+\infty$ |
// | Azimuth $\theta$ ($^\circ$) (`coord = 0`)   | `azimuth_i`     |    -180   |    180    |
// | Elevation $\phi$ ($^\circ$) (`coord = 0`)   |  `elevation_i`  |    -90    |    90     |
// |             $x$ (m) (`coord = 1`)           |       `x_i`     | $-\infty$ | $+\infty$ |
// |             $y$ (m) (`coord = 1`)           |       `y_i`     | $-\infty$ | $+\infty$ |
// |             $z$ (m) (`coord = 1`)           |       `z_i`     | $-\infty$ | $+\infty$ |
//
// Note that OSC messages for the `s` sources can be generated using the [Encoder]({% link docs/encoder.md %}) tool or [Joystick2OSC]({% link docs/joystick2osc.md %}) patch and for the loudspeakers with the tool [dB Meter]({% link docs/db_meter.md %}). For the Faust tools, the option `-xmit 2` should be activated to turn OSC message transmission on[^osc]
// {:.info}
//
// [^osc]:[https://faustdoc.grame.fr/manual/osc/#turning-transmission-on](https://faustdoc.grame.fr/manual/osc/#turning-transmission-on){:target="_blank"}
//###

/* Compilation Parameters:
---EDIT HERE---*/
String array = "lebedev.csv"; // the number of loudspeaker is deduced when reading the file
int port = 5511; // OSC port to listen to
int s = 2; // number of source to draw
int coord = 0; // Choice of coordinate system : `0` => Spherical, `1` => Cartesian.
int memory = 200; // Number of past positions the source fading trajectory.
int trajectory = 1; // Choice of the trajectory type : `0` => discrete balls, `1` => continuous curve

/*---DO NOT EDIT AFTER HERE---*/
// Libraries importation

/* toxiclibs to handle .stl mesh files
 * http://toxiclibs.org/
 */ 
import toxi.geom.*;
import toxi.geom.mesh.*;
import toxi.processing.*;
TriangleMesh mesh;
ToxiclibsSupport gfx;

/* PeasyCam to have a nice mouse-driven camera
 * http://mrfeinerg.com/peasycam/
 */
import peasy.*;
PeasyCam cam;

/* oscP5 to drive the loudspeakers level and sources position
http://www.sojamo.de/libraries/oscP5/
*/
import oscP5.*;
import netP5.*;
OscP5 oscP5;

/* Screen resolution retrieving */
import java.awt.Toolkit;
int resolution = Toolkit.getDefaultToolkit().getScreenResolution();

PFont f;
Atom loudspeakers[], sources[];
int hmin=20, hmax=120; // min an max heights for the dB meter.
float dBmin=-70, dBmax=6, rmin = 0.01, rmax = 0.1; // min and max deciBel value from OSC message, min and max radius value in meters for loudspeaker / source radius.
int n;
color[] colorList;

void settings() {
  System.setProperty("jogl.disable.openglcore", "true"); // Workaround for error "Profile GL4bc is not available on X11GraphicsDevice" with P3D renderer
  fullScreen(P3D,2);
  //size(1280,720,P3D);
}
  
void setup() {
  /* Rendering */
  //frameRate(30);
  //surface.setResizable(true);
  colorMode(HSB, 360,100,100);
  colorList = new color[]{color(0, 100, 100), color(180, 100, 100), color(119, 100, 100), color(59, 75, 100), color(209, 100, 100), color(299, 10, 50), color(0, 0, 75)}; // 7 different colors
  
  /* Font */
  f = createFont("Verdana",10,true);

  /* Human Head Mesh
   * https://www.thingiverse.com/thing:758647
   * Licence CC-BY-SA-3.0
   * https://creativecommons.org/licenses/by-sa/3.0/
   * With Cura slicer: scaled at 0.1m height, translated to have the ears at z=0, rotated to face positive x-axis.
   */
  mesh=(TriangleMesh)new STLReader().loadBinary(sketchPath("data/headstand.stl"),STLReader.TRIANGLEMESH);
  mesh.scale(pixels(0.0035)); // scale to 35cm height

  gfx=new ToxiclibsSupport(this);

  /* Perspective settings */
  float fov      = PI/3;  // field of view
  float nearClip = 1;
  float farClip  = pixels(50);
  float aspect   = float(width)/float(height); 
  perspective(fov, aspect, nearClip, farClip); 
  
  /* Camera settings */
  cam = new PeasyCam(this, pixels(3));
  cam.setMinimumDistance(pixels(0.5));
  cam.setRotations(1.157, 1, -2.82);
  cam.setMaximumDistance(pixels(15));
  cam.setCenterDragHandler(null); // deactivate center drag, i.e. pan
  
  /* Loudspeaker array settings */
  Table table;
  table = loadTable(array, "header"); // loudspeakers coordinates stored in a csv files with float radius r in meter, float azimuth \theta in degree and float elevation \vaprhi in degree.
  n = table.getRowCount();
  loudspeakers = new Atom[n]; 
  
  for (int i=0; i<n; i++) {
    TableRow row = table.getRow(i);
    float[] rtp = new float[] {row.getFloat("r"), row.getFloat("t") * PI / 180, row.getFloat("p") * PI / 180}; // change degree to radians
    float[] xyz = spher2cart(rtp);
    loudspeakers[i] = new Atom(new float[] {pixels(xyz[0]), pixels(xyz[1]), pixels(xyz[2])});
  }
   
  /* Sources array settings */
  sources = new Atom[s];
  
  for (int i=0; i < s; i++) {
    float[] rtp = new float[] {0.1*i + 1, 0, 0};//{random(1,2), random(0, 2 * PI), random(0,PI)}; // random position between 1 m and 10 m from origin
    float[] xyz = spher2cart(rtp);
    sources[i] = new Atom(new float[] {pixels(xyz[0]), pixels(xyz[1]), pixels(xyz[2])}); 
    sources[i].c = colorList[i % 7]; // 7 colors
  }
  
  /* OSC initialization */
  /* starts oscP5, telling it to listen for incoming messages at port 5001 */
  oscP5 = new OscP5(this,port);
}

void draw() {
  scale(1,-1,1); // y-axis is flipped in Processing
  background(0);
  cam.beginHUD(); // To have a 2D layer above the 3D
  drawPalette();
  cam.endHUD();
  lights();
  drawHead();
  drawSources();
  drawLoudspeakers();
}

/* pixels */
int pixels(float m) {
  return ceil(m * 1 / 0.0254 * resolution);
}

/* spher2cart */
float[] spher2cart(float[] rtp) {
  float[] xyz = new float[3];
  xyz[0] = rtp[0] * cos(rtp[1]) * cos(rtp[2]); 
  xyz[1] = rtp[0] * sin(rtp[1]) * cos(rtp[2]);
  xyz[2] = rtp[0] * sin(rtp[2]);
  return xyz;
}

/* cart2spher */
float[] cart2spher(float[] xyz) {
  float[] rtp = new float[3];
  rtp[0] = sqrt(pow(xyz[0],2) + pow(xyz[1],2) + pow(xyz[2],2));
  rtp[1] = ((atan2(xyz[1], xyz[0]) % (2 * PI)) + (2 * PI)) % (2 * PI); // modulo of negative number, see : https://torstencurdt.com/tech/posts/modulo-of-negative-numbers/
  rtp[2] = asin(xyz[2] / rtp[0]);
  return rtp;
}

/* deciBel2radius 
linear interpolation between deciBel value and radius in meter */
float deciBel2radius(float deciBel){
  float a = (rmax - rmin) / (dBmax - dBmin); 
  float b = rmax - a * dBmax;
  return a * deciBel + b;
}

/* deciBel2color
linear interpolation between deciBel value and color between green HSB(120, 100, 100) and red HSB(0, 100, 100). If deciBel > 0 => clipping HSB(0,100,100) */
color deciBel2color(float deciBel){
  float a = (0 - 120) / (0 - dBmin); // instead of dBmax, one puts 0, to have red value at 0
  float b = 0 - a * 0;
  return color(a * deciBel + b, 100, 100);
}

/* Drawing procedures */

void drawHead() {
  noStroke();
  fill(color(0,0, 80));
  gfx.mesh(mesh,true,0);
}

void drawLoudspeakers() {
  noStroke();
  for (int i = 0; i < n; i++) {
      loudspeakers[i].render(0);
      }
  }

void drawSources() {
  noStroke();
  for ( int i = 0; i < s; i++){
    sources[i].render(0);
    for (int j = 1; j < memory; j++) {
      if (trajectory == 0){
        sources[i].render(j);
      }
      else if (trajectory == 1){
       sources[i].render2(j);
      }
    }
    sources[i].fifo(sources[i].xyz[0]); // fifo at each frame
  }
}

void drawPalette() {
    textFont(f,15);
  for (int h=hmin; h< hmax; h++) { // dB = (dBmin-dBmax)/(hmax-hmin)*h + (dBmax*hmax-dBmin*hmin)/(hmax-hmin)
      if (h <= (dBmax*hmax - dBmin*hmin)/(dBmax - dBmin)){ // if dBmax >= dB >= 0
        fill(color(0,100,100));
        } 
      else { // else if 0 >= dB > dBmin
        fill(color(h,100,100));
      }
    noStroke();
    rect(10,10+6*(h-hmin),40,6);
    if (h%4==0){
    text(nfp(round((dBmin-dBmax)/(hmax-hmin)*h + (dBmax*hmax-dBmin*hmin)/(hmax-hmin)),0,0),55,15+6*(h-hmin));
    }
    }
}

void moveCam() {
  //cam.setRotations(radians(frameCount/frameRate),radians(frameCount/frameRate),radians(frameCount/frameRate));
  cam.rotateX(radians(0.1*sin(PI*frameCount/frameRate)));
  cam.rotateY(radians(0.1*sin(PI*frameCount/frameRate)));
  cam.rotateZ(radians(0.1*sin(PI*frameCount/frameRate)));
}
  
void oscEvent(OscMessage theOscMessage) {
  String v=theOscMessage.addrPattern();
  for ( int i = 0; i < n; i++) {
    if (v.equals("/loudspeaker_"+str(i))) {
      float msg = theOscMessage.get(0).floatValue();
      loudspeakers[i].r[0] = pixels(deciBel2radius(msg));
      loudspeakers[i].c = deciBel2color(msg);
    }
  }
  if (coord == 0) {
   for (int i = 0; i < s; i++) {
     if (v.equals("/radius_"+str(i)) || v.equals("/azimuth_"+str(i)) || v.equals("/elevation_"+str(i))){
       float[] xyz = sources[i].xyz[0];
       float[] rtp = cart2spher(xyz);
     if (v.equals("/radius_"+str(i))) {
         rtp[0] = pixels(theOscMessage.get(0).floatValue()); // OSC message in meters
     }
     if (v.equals("/azimuth_"+str(i))) {
         rtp[1] = theOscMessage.get(0).floatValue() * PI / 180; // OSC message in degree
     }
    if (v.equals("/elevation_"+str(i))) {
         rtp[2] = theOscMessage.get(0).floatValue() * PI / 180; // OsC message in degree
     }
     xyz = spher2cart(rtp);
     sources[i].xyz[0] = xyz;
    }
   }
  } else if (coord == 1) {
   for (int i = 0; i < s; i++) {
     if (v.equals("/x_"+str(i))) {
         sources[i].xyz[0][0] = pixels(theOscMessage.get(0).floatValue()); // OSC message in meters
     }
     if (v.equals("/y_"+str(i))) {
         sources[i].xyz[0][1] = pixels(theOscMessage.get(0).floatValue()); // OSC message in meters
     }
    if (v.equals("/z_"+str(i))) {
         sources[i].xyz[0][2] = pixels(theOscMessage.get(0).floatValue()); // OsC message in meters
     }
   }
  }

}
