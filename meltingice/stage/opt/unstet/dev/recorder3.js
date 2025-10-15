#!/usr/bin/env node
const readline = require('readline');


const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
  terminal: false
})

const fs = require('fs');
function write(name,data){
    fs.writeFileSync(name,data,{encoding:'utf8', flag:'a'});
}

rl.on('line', (line) => {
    //console.log(line);
    record(JSON.parse(line));
});

rl.once('close', () => {
     // end of input
 });


let name;

const Args = process.argv.slice(2);

if(Args[0]){
    name=Args[0];
}

var last=-1;

function  record(message){
    let diff,now,bundle;
    
    now = new Date().getTime();    
    if(last>0){
        diff = now - last;
    }else{
	diff = 0
    }
    last = now;
    
    bundle= { clock: now, time: diff, message: message };
    if(name){
	write(name,JSON.stringify(bundle)+'\n');
    }
    //process.stderr.write(JSON.stringify(bundle)+'\n');
    process.stdout.write(JSON.stringify(message)+'\n');
};

