#!/usr/bin/env node

let leb = [
      0  , 0    , 90  ,  //rot
     1  , 0    , 0   ,
     2  , 90   , 0   ,
     3  , 180  , 0   ,
     4  , -90  , 0   ,
     5  , 0    , -90 ,
    
     6  , 45   , 35  , //grun
     7  , 135  , 35  ,
     8  , -135 , 35  ,
     9  , -45  , 35  ,
     10 , 45   , -35 ,
     11 , 135  , -35 ,
     12 , -135 , -35 ,
     13 , -45  , -35 ,
    
     14 , 0    , 45  ,  //blau
     15 , 90   , 45  ,
     16 , 180  , 45  ,
     17 , -90  , 45  ,
     18 , 45   , 0   ,
     19 , 135  , 0   ,
     20 , -135 , 0   ,
     21 , -45  , 0   ,
     22 , 0    , -45 ,
     23 , 90   , -45 ,
     24 , 180  , -45 ,
     25 , -90  , -45 ,
    
     26 , 45   , 65  ,
     27 , 135  , 65  ,
     28 , -135 , 65  ,
     29 , -45  , 65  ,
     30 , 18   , 18  ,
     31 , 72   , 18  ,
     32 , 108  , 18  ,
     33 , 162  , 18  ,
     34 , -162 , 18  ,
     35 , -108 , 18  ,
     36 , -72  , 18  ,
     37 , -18  , 18  ,
     38 , 18   , -18 ,
     39 , 72   , -18 ,
     40 , 108  , -18 ,
     41 , 162  , -18 ,
     42 , -162 , -18 ,
     43 , -108 , -18 ,
     44 , -72  , -18 ,
     45 , -18  , -18 ,
     46 , 45   , -65 ,
     47 , 135  , -65 ,
     48 , -135 , -65 ,
     49 , -45  , -65
];


function rad2grd(r){
    return(r*180/Math.PI);
}

function grd2rad(g){
    return(g*Math.PI/180);
}

function cart2spher(c){
    let r = Math.sqrt(c.x*c.x+c.y*c.y+c.z*c.z);
    let a = Math.atan2(c.y,c.x);
    let e = Math.asin(c.z/r);
    return { a:a, e:e, r:r }
    
}

function spher2cart(s){
    let x = Math.cos(s.a)*Math.cos(s.e)*s.r;
    let y = Math.sin(s.a)*Math.cos(s.e)*s.r;
    let z = Math.sin(s.e)              *s.r;
    return { x:x, y:y, z:z }
}

let vertices;

let edges1
let edges2;
let edges3;
let edges4;
let lebedev;
let head;
let R;

let rad;
let radtext;
let orderslider;
let order=2;

function preload(){
    //head=loadModel('headstand.stl');
    head=loadModel('FullBody_Final_150mm.stl');
    //head=loadModel('LOWPOLYHUMAN_001.obj');
}

function setup(){
    createCanvas(600,600,WEBGL);
    //console.log(leb);
    R=100;
    
    rad=createSlider(0.2,5,1,0.05);
    rad.position(620,20);

    orderslider=createSlider(1,4,2,1);
    orderslider.position(620,40);
    
    radtext=createP('Radius:');
    radtext.position(750,10);
    
    head.computeNormals(SMOOTH);
    lebedev=[];
    vertices=[];
    for(let i=0;i<leb.length/3;i++){
	let ind=3*i;
	let a=leb[ind+1];
	let e=leb[ind+2];
	let r=1;
	lebedev.push( { a:a, e:e, r:r });
	let c=spher2cart( { a:grd2rad(a),e:grd2rad(e),r:r });
	vertices.push(c);
    }
    //console.log(lebedev,vertices);

    edges1=[ 0,1, 0,2, 0,3, 0,4,
	     1,2, 2,3, 3,4, 4,1,
	     5,1, 5,2, 5,3, 5,1
	   ];
    edges2=[ 0,6, 0,7, 0,8, 0,9,
	     6,7, 7,8, 8,9, 9,6,

	     6,1, 1,9, 9,4, 4,8, 8,3, 3,7, 7,2, 2,6,

             6,10, 7,11, 8,12, 9,13,

	     1,10, 10,2, 2,11, 4,12, 4,13, 3,12, 3,11, 1,13,
	     
	     10,11, 11,12, 12,13, 13,10,
	     5,10, 5,11, 5,12, 5,13
	   ];
    edges3=[ 0,14, 0,15, 0,16, 0,17,  //dach oben
	     0,6, 0,7, 0,8, 0,9,

	     14,6, 6,15, 15,7, 7,16, 16,8, 8,17, 17,9, 9,14,      //rand oben grün=6-9 blau= 14-17

	     14,1, 6,18, 15,2, 7,19, 16,3, 8,20, 17,4, 9,21,     // ||||band oben
	     14,18, 18,15, 15,19, 19,16, 16,20, 20,17, 17,21, 21,14,      // /\/\

             1,18, 18,2, 2,19, 19,3, 3,20, 20,4, 4,21, 21,1,    // aequator   rot=1-4, blau=18-21

	     18,10, 2,23, 19,11, 3,24, 20,12, 4,25, 21,13, 1,22,     // |||| band unten
	     22,18, 18,23, 23,19, 19,24, 24,20, 20,25, 25,21,21,22,

	     22,10, 10,23, 23,11, 11,24, 24,12, 12,25, 25,13, 13,22,     //rand unten  gruen=10-13 blau=22-25

             5,22, 5,23, 5,24, 5,25, //dach unten
	     5,10, 5,11, 5,12, 5,13
	   ];
    
}


let o=[6,14,26,50]


function drawEdges(edges){
   for(let i=0;i<edges.length/2;i++){
	let ind=2*i;
	let indA=edges[ind];
	let indB=edges[ind+1];
	let A=vertices[indA];
	let B=vertices[indB];
	line(A.x,A.y,A.z,B.x,B.y,B.z);
    }
}


function draw(){
    order=orderslider.value();
    radius=R*rad.value();
    radtext.elt.innerHTML='Radius: '+rad.value();
    let r;
    background(255);
    rotateX(Math.PI/2);
    lights();
    orbitControl();
    stroke(0);
    //debugMode();
    //stroke(255,0,0);
    push();
    scale(radius);
    for(let i=0;i<o[order-1];i++){
	let v=vertices[i];
	push();

        if(i>=26){ stroke(255,255,0) }else{
	    if(i>=14){stroke(0,0,255);r=i-14+1}else{
		if(i>=6){stroke(0,255,0);r=i-6+1}else{
		    stroke(255,0,0);r=i+1}
	    }
	}	
	translate(v.x,v.y,v.z);
	r=6;
	sphere(r/radius);
	pop();
	
    }

    stroke(0);
    switch(order){
    case 1:
	drawEdges(edges1);
	break;
    case 2:
	drawEdges(edges2);
	break;
    case 3:
	drawEdges(edges3);
	break;
    }
    pop();
    
    //fill(0,255,0,255);
    noFill();
    //noStroke();
    push();
    rotateX(-Math.PI/2);
    stroke(220);
    if(order==4)sphere(radius);
    pop();
    //push();
    //scale(0.4);
    let scala=0.7;
    translate(-27*scala,-22*scala,-138*scala);
    scale(scala);
    fill(255,128,0);
    model(head);
}



/*
    //order=1
    for(let i=0;i<edges1.length/2;i++){
	let ind=2*i;
	let indA=edges1[ind];
	let indB=edges1[ind+1];
	let A=vertices[indA];
	let B=vertices[indB];
	//line(A.x,A.y,A.z,B.x,B.y,B.z);
    }
    //order=2
    for(let i=0;i<edges2.length/2;i++){
	let ind=2*i;
	let indA=edges2[ind];
	let indB=edges2[ind+1];
	let A=vertices[indA];
	let B=vertices[indB];
	//line(A.x,A.y,A.z,B.x,B.y,B.z);
    }
    //order=3
    for(let i=0;i<edges3.length/2;i++){
	let ind=2*i;
	let indA=edges3[ind];
	let indB=edges3[ind+1];
	let A=vertices[indA];
	let B=vertices[indB];
	//line(A.x,A.y,A.z,B.x,B.y,B.z);
    }
*/
