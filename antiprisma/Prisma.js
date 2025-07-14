#!/usr/bin/env node


class Prisma {
    constructor(n,anti=true){
	this.n = n;
	this.r = 100;
	this.anti = anti;
	this.north=false;
	this.south=false;
	this.flat=false;
	this.update();
    }

    update(){
	console.log('update');
	this.h = Math.sqrt( (Math.cos(Math.PI/this.n)-Math.cos(2*Math.PI/this.n)) / 2.0 )*this.r;
	if(this.flat)this.h=0;
	this.R = Math.sqrt( this.r*this.r + (this.h*this.h)/4.0);
	this.vertices = [];
	this.real=[];
	this.faces = [];
	this.edges = [];
	let delta = 2*Math.PI/this.n;
	//vertices
	for(let i=0;i<this.n;i++){
	    let x,y,z,alpha;
	    alpha=i*delta;
	    x=Math.cos(alpha)*this.r;
	    y=Math.sin(alpha)*this.r;
	    z=this.h
	    x=Math.round(100*x)/100;
	    y=Math.round(100*y)/100;
	    z=Math.round(100*z)/100;
	    this.vertices.push( createVector(x,y,z) );
	    this.real.push(true);
	    if(!this.flat){
		if(this.anti)alpha+=delta/2.0;
		x=Math.cos(alpha)*this.r
		y=Math.sin(alpha)*this.r
		z=-this.h;
		x=Math.round(100*x)/100;
		y=Math.round(100*y)/100;
		z=Math.round(100*z)/100;
		this.vertices.push(createVector(x,y,z)  );
		this.real.push(true);
	    }
	}
	if(!this.flat){
	    let northIndex=2*this.n;
	    let southIndex=2*this.n+1;
	    let north;
	    let south;
	    let real;
	    if(this.north){
		north=this.R;
		real=true;
	    }else{
		north=this.h;
		real=false;
	    }
	    this.real.push(real);
	    if(this.south){
		south=-this.R
		real=true;
	    }else{
		south=-this.h
		real=false;
	    }
	    this.real.push(real);
	    this.vertices.push( createVector(0,0,Math.round(100*north)/100)); 
	    this.vertices.push( createVector(0,0,Math.round(100*south)/100));
	}
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
	
	//edges
	for(let i=0;i<this.n;i++){
	    let m=2*i;
	    //obere pyramide
	    this.edges.push(northIndex,m);
	    //oberer rand
	    this.edges.push(m,(m+2)%(2*this.n));
	    //band
	    this.edges.push(m+0,(m+1)%(2*this.n));
	    if(this.anti)this.edges.push(m+1,(m+2)%(2*this.n));
	    //unterer rand
	    this.edges.push(m+1,(m+3)%(2*this.n));
	    //untere pyramide
            this.edges.push(southIndex,m+1);
	}    
    }

    drawVertices(){
	for(let i=0;i<this.vertices;i++){
	    if(this.real[i]){
		let v=this.vertices[i];
		push();
		//stroke(255,0,0);
		normalMaterial();
		translate(v.x,v.y,v.z);
		sphere(5);
		pop();
	    }
	}
    }

    drawEdges(){
	for(let i=0;i<this.edges.length/2;i++){
	    let indA=this.edges[2*i];
	    let indB=this.edges[2*i+1];
	    if(this.real[indA]&&this.real[indB]){
		let a=this.vertices[indA];
		let b=this.vertices[indB];
		stroke(200);
		line(a.x,a.y,a.z,b.x,b.y,b.z);
	    }
	}
    }
    
    setN(n){
	console.log(this.n);
	this.n=n;
	this.update();
    }
    setR(r){
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

