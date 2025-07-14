#!/usr/bin/env node

import { readFileSync,writeFileSync,existsSync } from 'node:fs';

function round(a){
    return Math.round(100*a)/100
}

function layoutToDSP(layout){

    //console.log(layout);
    let speakers = layout.LoudspeakerLayout.Loudspeakers;
    //console.log(speakers);
    let txt = '';
    let count=0;
    let N = speakers.length; 
    for(let i=0;i<N;i++){
	let spk = speakers[i];
	if(!spk.IsImaginay){
	    count++;	    
	    let a = spk.Azimuth*(Math.PI/180);

	    let e = spk.Elevation*(Math.PI/180);
	    let r = spk.Radius;

	    let x = Math.cos(a)*Math.cos(e)*r;
	    let y = Math.sin(a)*Math.cos(e)*r;
	    let z = Math.sin(e)            *r;
	    txt+='speaker('+i+') = ( '+round(x)+', '+round(y)+', '+round(z)+' );\n';
	}	    
    }
    return txt;
}
function layoutToNum(layout){

    //console.log(layout);
    let speakers = layout.LoudspeakerLayout.Loudspeakers;
    //console.log(speakers);
    let count=0;
    let N = speakers.length; 
    
    for(let i=0;i<N;i++){
	
	let spk = speakers[i];
	if(!spk.IsImaginay){
	    count++;
	}
    }
    return count;
}

function layoutToRoute(layout){
   //console.log(layout);
    let speakers = layout.LoudspeakerLayout.Loudspeakers;
    //console.log(speakers);
    let count=0;
    let N = speakers.length; 

    let list='';
    for(let i=0;i<N;i++){
	
	let spk = speakers[i];
	if(!spk.IsImaginay){
	    count++;
	    list+=','+count+','+spk.Channel;
	}
    }
    return 'process = route('+count+','+count+list+');\n';
}

function layoutToStartup(layout){
  //console.log(layout);
    let speakers = layout.LoudspeakerLayout.Loudspeakers;
    //console.log(speakers);
    let count=0;
    let N = speakers.length; 

    let shell='#!/usr/bin/sh\n';
    shell+='./panner & ./router &\n';
    //shell+=' ./sound_checker & ./db_meter &\n';
    shell+='sleep 2\n';
    for(let i=0;i<N;i++){	
	let spk = speakers[i];
	if(!spk.IsImaginay){
	    shell+='jack_connect panner:out_'+count+' router:in_'+count+'\n';
	    //shell+='jack_connect sound_ckecker:out_'+count+' db_meter:in_'+count+'\n';
	    //shell+='jack_connect db_meter:out_'+count+' router:in_'+count+'\n';
	    count++;
	}
    }
    return shell;
}


let file;

if(process.argv[2]){
    file=process.argv[2];
}else{
    process.stderr.write('usage: layout2dsp.js infile\n');
    process.exit(1);
}

let layout=JSON.parse(readFileSync(file));
writeFileSync('speakers.cnf',layoutToDSP(layout));

let numOut='N = '+layoutToNum(layout)+';\n';

if(existsSync('sinks.cnf')){
    let cont=readFileSync('sinks.cnf');
    if(cont!=numOut)writeFileSync('sinks.cnf',numOut);
}else{
    writeFileSync('sinks.cnf',numOut);
}

let routeOut=layoutToRoute(layout);
if(existsSync('router.dsp')){
    let cont=readFileSync('router.dsp');
    if(cont!=numOut)writeFileSync('router.dsp',routeOut);
}else{
    writeFileSync('route.dsp',routeOut);
}

console.log(layoutToStartup(layout))
writeFileSync('startup.sh',layoutToStartup(layout))
					    
/*
function layoutToDSP(layout){

    //console.log(layout);
    let speakers = layout.LoudspeakerLayout.Loudspeakers;
    //console.log(speakers);
    let txt = '';
    let count=0;
    let N = speakers.length; 
    for(let i=0;i<N;i++){
	let spk = speakers[i];
	if(!spk.IsImaginay){
	    count++;	    
	    let a = spk.Azimuth*(Math.PI/180);

	    let e = spk.Elevation*(Math.PI/180);
	    let r = spk.Radius;

	    let x = Math.cos(a)*Math.cos(e)*r;
	    let y = Math.sin(a)*Math.cos(e)*r;
	    let z = Math.sin(e)            *r;
	    txt+='speaker('+i+') = ( '+round(x)+', '+round(y)+', '+round(z)+' );\n';
	}	    
    }
    return txt;
}
*/

/*
var chunks = '';
process.stdin.on('readable', () => {
  let chunk;
  while (null !== (chunk = process.stdin.read())) {
      chunks+=chunk;
  }
});
process.stdin.on('end', () => {
    processInput(JSON.parse(chunks))
});
*/
