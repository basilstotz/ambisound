#!/usr/bin/env node


//https://github.com/adzialocha/osc-js                                                                                                      
const OSC = require('osc-js');
const osc = new OSC({ plugin: new OSC.DatagramPlugin() });

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


const config=JSON.parse(read('replay-conf.json'));
const file=config.file;
const hosts=config.hosts;
const port=config.port;

const liner = new lineByLine(file);
let line;

let bundle={ time: -1 };


/*
{"time":39,"message":{"offset":24,"address":"/beamer/4/video","types":",i","args":[32]}}
{"time":41,"message":{"offset":24,"address":"/beamer/3/video","types":",i","args":[13]}}
{"time":2424,"message":{"offset":24,"address":"/beamer/1/video","types":",i","args":[41]}}
{"time":1575,"message":{"offset":24,"address":"/beamer/4/video","types":",i","args":[32]}}
{"time":1050,"message":{"offset":24,"address":"/beamer/1/video","types":",i","args":[43]}}
{"time":1750,"message":{"offset":24,"address":"/beamer/2/video","types":",i","args":[21]}}
*/


function play(){

    if(bundle.time>=0){

	let message=bundle.message;
	
	let address=message.address.split("/");
	let host=hosts[address[2]-1];
        let destAddress="/"+address.slice(3).join("/");
	let destTypes=message.types.replace(",","");

	/*
	let destArgs="";
        for(let j=0;j<message.args.length;j++){
	    let arg=message.args[j]+"";
	    if(arg.indexOf(" ")==-1){
		destArgs+=arg+" ";
	    }else{
		destArgs+="\""+arg+"\" ";
	    }
	}
        */
	
        let response = new OSC.Message(destAddress);
        for(let j=0;j<message.args.length;j++){
            response.add(message.args[j]);
        }
        osc.send(response,{ port: port, host: host })

	
	//let destArgs=bundle.message.args.join(" ");

	//let cmd="oscsend "+host+" "+port+" "+destAddress+" "+destTypes+" "+destArgs;
	//console.log(cmd)
	//shell(cmd);
    }
    
    if(line = liner.next()){
        bundle=JSON.parse(line.toString('ascii'));
	setTimeout(play,bundle.time);
    }else{
	console.log('end of file reached');
    }
}

play();    
