#!/usr/bin/env node

function round(a){
    return Math.round(100*a)/100
}

function layoutToDsp(layout){

    //console.log(layout);
    let speakers = layout.LoudspeakerLayout.Loudspeakers;
    //console.log(speakers);
    let txt='';
    let N = speakers.length; 
    txt+='N = '+N+';\n';
    for(let i=0;i<N;i++){
	let spk=speakers[i];
	let x,y;
	if(Math.abs(spk.Elevation)>=88){
	    x=0;
	    y=0;
	}else{
	    x=Math.cos(spk.Azimuth*(Math.PI/180))*spk.Radius;
	    y=Math.sin(spk.Azimuth*(Math.PI/180))*spk.Radius;
	}
	let z=Math.sin(spk.Elevation*(Math.PI/180))*spk.Radius;
	txt+='speaker('+i+') = ( '+round(x)+', '+round(y)+', '+round(z)+' );\n';
    }
    return txt
}

function processInput(layout){   
    process.stdout.write(layoutToDsp(layout));
}

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

