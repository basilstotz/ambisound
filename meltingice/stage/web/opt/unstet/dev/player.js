#!/usr/bin/env node

const fs = require('fs');
const { execSync } = require('child_process');

// utilty functions
function read(name){
    return fs.readFileSync(name,{encoding:'utf8', flag:'r'});
}

function write(name,data){
    fs.writeFileSync(name,data,{encoding:'utf8', flag:'w'});
}

function shell(command){
    //console.log(args);
    let opts= { encoding: 'utf8' };
    return execSync(command,[], opts);
}
// utility functions


const lineByLine = require('n-readlines');
const OSC = require('osc-js');



const config=JSON.parse(read('replay-conf.json'));
const file=config.file;
const hosts=config.hosts;
const port=config.port;

const liner = new lineByLine(file);
let line;

let bundle={ time: -1 };


/*
{"time":39,"message":{"offset":24,"address":"/beamer4/video","types":",i","args":[32]}}
{"time":41,"message":{"offset":24,"address":"/beamer3/video","types":",i","args":[13]}}
{"time":2424,"message":{"offset":24,"address":"/beamer1/video","types":",i","args":[41]}}
{"time":1575,"message":{"offset":24,"address":"/beamer4/video","types":",i","args":[32]}}
{"time":1050,"message":{"offset":24,"address":"/beamer1/video","types":",i","args":[43]}}
{"time":1750,"message":{"offset":24,"address":"/beamer2/video","types":",i","args":[21]}}
*/

/*
"time":100,"message":{"offset":20,"address":"/video","types":",ii","args":[11,1]}}
{"time":7,"message":{"offset":20,"address":"/video","types":",ii","args":[43,4]}}
*/

function play(){


    let video;
    let host;
    
    if(bundle.time >= 0){

	switch(bundle.message.address){
	case '/beamer1/video':
	    host=hosts[0];
	    break;
	case '/beamer2/video':
	    host=hosts[1];
	    break;
	case '/beamer3/video':
	    host=hosts[2];
	    break;
	case '/beamer4/video':
	    host=hosts[3];
	    break;
	}
	
        video = bundle.message.args[0];

	shell("oscsend "+host+" "+port+" /video i "+video);
    }
    
    if(line = liner.next()){
        bundle=JSON.parse(line.toString('ascii'));
	setTimeout(play,bundle.time);
    }else{
	console.log('end of file reached');
    }
}

play();    
