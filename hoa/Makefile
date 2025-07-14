all: panner decoder panner-decoder

panner: panner.dsp ambi.cnf
	faust2jack -httpd -osc panner.dsp
decoder: decoder.dsp ambi.cnf
	faust2jack -httpd -osc decoder.dsp
panner-decoder: panner-decoder.dsp ambi.cnf
	faust2jack -httpd -osc panner-decoder.dsp
