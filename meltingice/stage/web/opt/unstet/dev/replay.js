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

/*
let file;
const myArgs = process.argv.slice(2);
if(myArgs[0]){
    file=myArgs[0];
}else{
    file='messages.txt';
}
*/


const config=JSON.parse(read('replay-conf.json'));
const file=config.file;
const hosts=config.hosts;
const port=config.port;


const options = {
  type: 'udp4',
  open: {
    host: 'localhost',
    port: 9010,
    exclusive: false
  },
  send: {
    host: 'localhost', 
    port: port
  }
}



const osc = new OSC({ plugin: new OSC.DatagramPlugin() })
osc.open() // bind udp socket to port 41234




const liner = new lineByLine(file);
 
let line;
let lineNumber = 0;
let bundle={ time: -1 };

/*
{"time":308,"message":{"offset":20,"address":"/video","types":",ii","args":[23,2]}}
{"time":794,"message":{"offset":20,"address":"/video","types":",ii","args":[32,2]}}
{"time":742,"message":{"offset":20,"address":"/video","types":",ii","args":[31,1]}}
{"time":309,"message":{"offset":20,"address":"/video","types":",ii","args":[22,1]}}
*/

function play(){
    if(bundle.time >= 0){

	//console.log(JSON.stringify(bundle.message));
        m=new OSC.Message(bundle.message.address,bundle.message.args[0]);
	//	osc.send(m , { host: 'localhost', hostport: 9000 });
	console.log(hosts[bundle.message.args[1]]+':' + port + ' => ' + JSON.stringify(m));
	osc.send(m , { host: hosts[bundle.message.args[1]-1], hostport: port });
    }
    
    if(line = liner.next()){
        bundle=JSON.parse(line.toString('ascii'));
	setTimeout(play,bundle.time);
    }else{
	osc.close();
	console.log('end of file reached');
    }
}

play();    
