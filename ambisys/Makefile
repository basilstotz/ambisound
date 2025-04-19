
simple : $${HOME}/bin/panner basis
complex: $${HOME}/bin/encoder $${HOME}/bin/sampling_decoder $${HOME}/bin/rotator $${HOME}/bin/mirroring basis 

basis: $${HOME}/bin/db_meter $${HOME}/bin/sound_checker $${HOME}/bin/router bin

bin: $${HOME}/bin/jackpatch  $${HOME}/bin/nsmd  $${HOME}/bin/nsm-legacy-gui  $${HOME}/bin/nsm-proxy  $${HOME}/bin/nsm-proxy-gui $${HOME}/bin/jackpatch-save

$${HOME}/bin/jackpatch-save:
	ln -sf $${PWD}/bin/jackpatch-save.sh $${HOME}/bin/jackpatch-save


$${HOME}/bin/jackpatch:
	ln -sf $${PWD}/nsm/jackpatch $${HOME}/bin/jackpatch

$${HOME}/bin/nsmd:
	ln -sf $${PWD}/nsm/nsmd $${HOME}/bin/nsmd

$${HOME}/bin/nsm-legacy-gui:
	ln -sf $${PWD}/nsm/nsm-legacy-gui $${HOME}/bin/nsm-legacy-gui

$${HOME}/bin/nsm-proxy:
	ln -sf $${PWD}/nsm/nsm-proxy $${HOME}/bin/nsm-proxy

$${HOME}/bin/nsm-proxy-gui:
	ln -sf $${PWD}/nsm/nsm-proxy-gui $${HOME}/bin/nsm-proxy-gui


$${HOME}/bin/panner: dsp/panner
	ln -sf $${PWD}/dsp/panner $${HOME}/bin/panner

$${HOME}/bin/db_meter: dsp/db_meter
	ln -sf $${PWD}/dsp/db_meter $${HOME}/bin/db_meter

$${HOME}/bin/sound_checker: dsp/sound_checker
	ln -sf $${PWD}/dsp/sound_checker $${HOME}/bin/sound_checker

$${HOME}/bin/router: dsp/router
	ln -sf $${PWD}/dsp/router $${HOME}/bin/router

$${HOME}/bin/encoder: dsp/encoder
	ln -sf $${PWD}/dsp/encoder $${HOME}/bin/encoder

$${HOME}/bin/rotator: dsp/rotator
	ln -sf $${PWD}/dsp/rotator $${HOME}/bin/rotator

$${HOME}/bin/mirroring: dsp/mirroring
	ln -sf $${PWD}/dsp/mirroring $${HOME}/bin/mirroring

$${HOME}/bin/sampling_decoder: dsp/sampling_decoder
	ln -sf $${PWD}/dsp/sampling_decoder $${HOME}/bin/sampling_decoder


speakers.cnf: speakers.json
	./bin/layout2dsp.js speakers.json


dsp/panner: dsp/panner.dsp order.cnf sources.cnf sinks.cnf speakers.cnf
	faust2jack -osc dsp/panner.dsp

dsp/db_meter: dsp/db_meter.dsp sinks.cnf 
	faust2jack -osc dsp/db_meter.dsp

dsp/sound_checker: dsp/sound_checker.dsp sinks.cnf
	faust2jack -osc dsp/sound_checker.dsp

dsp/router: dsp/router.dsp sinks.cnf
	faust2jackconsole  dsp/router.dsp

dsp/encoder: dsp/encoder.dsp order.cnf sources.cnf
	faust2jack -osc dsp/encoder.dsp

dsp/sampling_decoder: dsp/sampling_decoder.dsp order.cnf sinks.cnf speakers.cnf
	faust2jackconsole dsp/sampling_decoder.dsp

dsp/rotator: dsp/rotator.dsp order.cnf
	faust2jack -osc dsp/rotator.dsp

dsp/mirroring: dsp/mirroring.dsp order.cnf
	faust2jack -osc dps/mirroring.dsp
