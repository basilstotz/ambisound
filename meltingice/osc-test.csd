<CsoundSynthesizer>
<CsOptions>
-m 128 
</CsOptions>
<CsInstruments>

sr  = 48000
ksmps = 32
nchnls  = 0
0dbfs   = 1


#include "udos/ambisonics_utilities.txt"

giPort = 47140
gSHost = "192.168.1.103"

giPortHandle OSCinit 9000


instr 1
 ktrigger init 0
 krx init 0.5
 kry init 0.5
 kGotIt OSClisten giPortHandle, "/oscControl/slider2Dx", "f",krx
 kGotIt OSClisten giPortHandle, "/oscControl/slider2Dy", "f",kry
 if kGotIt == 1 then
   kxx = 4*(krx-0.5)
   kyy = 4*(kry-0.5)
   kt taninv2 kyy,kxx
   kt = kt * (180/3.1415926)
   ;ka = 0
   kd dist kxx,kyy
   ktrigger = ktrigger + 1
   ;printf "%f %f\n",ktrigger,kxx,kyy
   printf "%f %f %f\n",ktrigger,kt,0,kd
   OSCsend ktrigger, "192.168.1.103", 47120, "/gunnar/set", "ifff",1,kt,0.0,kd 
endif
endin


</CsInstruments>
<CsScore>
i1 0 2000 ;start listening process first

</CsScore>
</CsoundSynthesizer>
;example by joachim heintz

/*

instr Pos
 kSendTrigger = 1
 OSCsend kSendTrigger, "192.168.1.103", 47120, "/gunnar/pos", "iffff",p4,p5,p6,p7,p3 
endin

instr Vol
 kSendTrigger = 1
 OSCsend kSendTrigger, "192.168.1.103", 47120, "/gunnar/vol", "iff",p4,p5,p3 
endin

instr Play
 kSendTrigger = 1
 Sin = p4
 idur = p3
 OSCsend kSendTrigger, "192.168.1.103", 47120, "/gunnar/play", "s",Sin 
endin
*/
