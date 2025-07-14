#!/usr/bin/env node


class Prisma {
    constructor(n,anti=true){
	this.n = n;
	this.r = 1;
	this.anti = anti;
	this.globe=true;
	this.vertices = [];
	this.faces = [];
	this.edges = [];
	this.update();
    }

    update(){
	this.h = Math.sqrt( (Math.cos(Math.PI/this.n)-Math.cos(2*Math.PI/this.n)) / 2.0 )*this.r;
	this.R = Math.sqrt( this.r*this.r + (this.h*this.h)/4.0);
	let delta = 2*Math.PI/this.n;
	//vertices
	let north=2*this.n;
	let south=2*this.n+1;
	let pole;
	if(this.globe){ pole=this.R }else{ pole=this.h }
	for(let i=0;i<this.n;i++){
	    let x,y,z,alpha;
	    alpha=i*delta;
	    x=Math.cos(alpha)*this.r;
	    y=Math.sin(alpha)*this.r;
	    z=this.h
	    x=Math.round(100*x)/100;
	    y=Math.round(100*y)/100;
	    z=Math.round(100*z)/100;
	    this.vertices.push( { x:x, y:y, z:z } );
	    if(this.anti)alpha+=delta/2.0;
	    x=Math.cos(alpha)*this.r
	    y=Math.sin(alpha)*this.r
	    z=-this.h;
	    x=Math.round(100*x)/100;
	    y=Math.round(100*y)/100;
	    z=Math.round(100*z)/100;
	    this.vertices.push( { x:x, y:y, z:z } );
	}
	this.vertices.push( { x:0,y:0,z:Math.round(100*pole)/100 }); 
	this.vertices.push( { x:0,y:0,z:Math.round(-100*pole)/100 });
	
        //faces 
        for(let i=0;i<this.n;i++){
	    let m=2*i
	    //obere pyramide
	    this.faces.push(m+0,m+2,north);
	    //antiprisma
	    this.faces.push(m+0,m+1,m+3);
	    this.faces.push(m+0,m+3,m+2);
	    //untere pyramide

	    this.faces.push(m+1,m+3,south);
	}
	
	//lines
	for(let i=0;i<this.n;i++){
	    let m=2*i;
	    //obere pyramide
	    this.edges.push(north,m);
	    //oberer rand
	    this.edges.push(m,(m+2)%(2*this.n));
	    //band
	    this.edges.push(m+0,m+1);
	    if(this.anti)this.edges.push(m+0,m+3);
	    //untere rand
	    this.edges.push(m+1,(m+3)%(2*this.n));
	    //untere pyramide
            this.edges.push(south,m+1);
	}    
    }

    setN(n){
	this.n=n;
	this.update();
    }
    retR(r){
	this.r=r;
	this.update();
    }
    setAnti(anti){
	this.anti=anti;
	this.update();
    }
    setGlobe(globe){
	this.globe=globe;
	this.update();
    }
}


let n=5;
let anti=true;
if(process.argv[2])n=Number(process.argv[2]);
if(process.argv[3])anti=false;

let prisma= new Prisma(n,1,anti);

console.log(prisma);
console.log(prisma.vertices.length,prisma.faces.length/3,prisma.edges.length/2)
    
