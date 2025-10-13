#!/usr/bin/env node                                                                                                                         

//https://github.com/adzialocha/osc-js
const OSC = require('osc-js');

let host;
let port;
let address;
let args=[];


const argv = process.argv.slice(2);

host=argv[0];
port=argv[1];
address=argv[2];

if(argv[3]){
    let types=argv[3];
    for(let i=0;i<types.length;i++){
	args.push(argv[4+i]);
    }
}

const osc = new OSC({ plugin: new OSC.DatagramPlugin() });


osc.on('open', () => {
});

//osc.open();

    let message = new OSC.Message(address);
    for(let j=0;j<args.length;j++){
	message.add(args[j]);
    }
    //osc.send(message,{ port: port, host: host });
    osc.send(message,{ port: 8000, host: "192.168.1.108" });
    osc.close();
