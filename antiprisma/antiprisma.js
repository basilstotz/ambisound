#!/usr/bin/env node

let outer = {
  Name: "fdgdf",
  Description: "dfgdfg",
  LoudspeakerLayout: {
    Name: "",
    Loudspeakers: [ ]
  }
};

let layout = outer["LoudspeakerLayout"];
//console.log(outer);
//console.log(layout);

let n=5;
if(process.argv[2])n=process.argv[2];

let r=1;
if(process.argv[3])r=process.argv[3];

let h=Math.sqrt( (Math.cos(Math.PI/n)-Math.cos(2*Math.PI/n)) / 2.0 )*r;
if(process.argv[4])h=process.argv[4];

let R=Math.sqrt( r*r + (h*h)/4.0);
let a=2*r*Math.sin(Math.PI/(2*n));

function cartesianToSpeaker(channel,x,y,z){
    let radius = Math.sqrt(x*x+y*y+z*z);
    let elevation = Math.atan2(z,Math.sqrt(x*x+y*y))*(180/Math.PI);
    let azimuth = Math.atan2(y,x)*(180/Math.PI);

    let speaker = {
	Azimuth: Math.round(100*azimuth)/100,
	Elevation: Math.round(100*elevation)/100,
	Radius: Math.round(100*radius)/100,
	X: Math.round(100*x)/100,
	Y: Math.round(100*y)/100,
	Z: Math.round(100*z)/100,
	IsImaginary: false,
	Channel: channel,
	Gain: 1.0
    };
    return speaker;
}


layout.Name="Antiprisma with "+n+" edges ( r="+r+", h="+h+", a="+Math.round(100*a)/100+" R="+Math.round(100*R)/100+" )";

//console.log(layout.LoudspeakerLayout.Loudspeakers);

for(let k=0;k<2*n;k++){
    let x = Math.cos(k*Math.PI/n)*r;
    let y = Math.sin(k*Math.PI/n)*r;
    let z = Math.pow(-1,k)*h;

    let speaker=cartesianToSpeaker(k+1,x,y,z);

    layout.Loudspeakers.push(speaker);
}


layout.Loudspeakers.push(cartesianToSpeaker(2*n+1,0,0,R));
layout.Loudspeakers.push(cartesianToSpeaker(2*n+2,0,0,-R));


process.stdout.write(JSON.stringify(outer,null,2));

