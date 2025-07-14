#!/usr/bin/env node

function round(a){
    return Math.round(100*a)/100
}

function layoutToDSP(layout){

    //console.log(layout);
    let speakers = layout.LoudspeakerLayout.Loudspeakers;
    //console.log(speakers);
    let txt = '';
    let N = speakers.length; 
    txt+='N = '+N+';\n';
    for(let i=0;i<N;i++){
	let spk = speakers[i];
	
	let a = spk.Azimuth*(Math.PI/180);
	let e = spk.Elevation*(Math.PI/180);
	let r = spk.Radius;
	
	let x = Math.cos(a)*Math.cos(e)*r;
	let y = Math.sin(a)*Math.cos(e)*r;
	let z = Math.sin(e)            *r;
	txt+='speaker('+i+') = ( '+round(x)+', '+round(y)+', '+round(z)+' );\n';
    }
    return txt
}

function layoutToOSC(layout){

    //console.log(layout);
    let speakers = layout.LoudspeakerLayout.Loudspeakers;
    //console.log(speakers);
    let style='';
    let txt = '';
    let N = speakers.length; 
    txt+='N = '+N+';\n';
    for(let i=0;i<N;i++){
	let spk = speakers[i];
	//txt+='speaker('+i+') = (nentry("v:speaker/h:'+i+'/x'+style+'",0,-50,50,0.1),nentry(\"v:speaker/h:'+i+'/y'+style+'",0,-50,50,0.1),nentry("v:speaker/h:'+i+'/z'+style+'",0,-50,50,0.1));\n';
	txt+='speaker('+i+') = (nentry("'+i+'/x'+style+'",0,-50,50,0.1),nentry("'+i+'/y'+style+'",0,-50,50,0.1),nentry("'+i+'/z'+style+'",0,-50,50,0.1));\n';
    }
    return txt
}



function processInput(layout){
    let txt;
    if(osc){
	txt=layoutToOSC(layout)
    }else{
	txt=layoutToDSP(layout)
    }
    process.stdout.write(txt);
}


let osc=false;
if(process.argv[2])osc=true;

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

