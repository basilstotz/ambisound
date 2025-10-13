<CsoundSynthesizer>
<CsOptions>
-m 128 --nosound
</CsOptions>
<CsInstruments>

sr  = 48000
ksmps = 32
nchnls  = 2
0dbfs   = 1

giPort = 47120
gSHost = "192.168.1.103"

;giPortHandle OSCinit 47120

instr Pos
 kSendTrigger = 1                                            ;chan,a,e,d,duration
 OSCsend kSendTrigger, gSHost, giPort, "/gunnar/pos", "iffff",p4,p5,p6,p7,p3 
endin

instr Vol
 kSendTrigger = 1
                                                           ;channel,volume,duration
 OSCsend kSendTrigger, gSHost, giPort, "/gunnar/vol", "iff",p4,p5,p3 
endin

instr Play
 kSendTrigger = 1
 Sin = p4
 idur = p3
 OSCsend kSendTrigger, gSHost, giPort, "/gunnar/play", "s",Sin 
endin

instr Stop
 kSendTrigger = 1
 ;Sin = p4
 ;idur = p3
 OSCsend kSendTrigger, gSHost, giPort, "/gunnar/stop", "" 
endin

instr Exit
   exitnow
endin


</CsInstruments>
<CsScore>


i "Vol" 0 1        6 0 
i "Pos" 0 1        6 0 0 1 ;6 => Hihat
i "Pos" 1 200     6 -72000 0 1 
i "Vol" 1 200     6 -6 

i "Vol" 0 1        5 0 
i "Pos" 0 1        5 0 0 1
i "Pos" 1 200     5 72000 0 1 
i "Vol" 1 200     5 -6 

i "Play" 5 1 "200119.aif"
;i "Stop" 15 1

;i "Play" 20 1 "orgeltamtam-master.aif"
;i "Stop" 25 1


;i "Exit" 26 1

</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
/*
instr Receive
 kReceiveFloat init 0
 SReceiveString init ""
 kGotIt OSClisten giPortHandle, "/exmp_2/more", "fs",
                  kReceiveFloat, SReceiveString
 if kGotIt == 1 then
  printf "kReceiveFloat = %f\nSReceiveString = '%s'\n",
         1, kReceiveFloat, SReceiveString
 endif
endin
*/
