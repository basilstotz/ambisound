<CsoundSynthesizer>
<CsOptions>
-m 128 --nosound
</CsOptions>
<CsInstruments>

sr  = 48000
ksmps = 32
nchnls  = 2
0dbfs   = 1

giPort = 47130
;gSHost = "192.168.1.112"

;giPortHandle OSCinit 47120

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

</CsInstruments>
<CsScore>
i "Pos" 0 1    5 0 0 0.1
i "Vol" 0 1    5 0 1

i "Pos" 0 1    6 0 0 1
i "Play" 2 1 "udos/ClassGuit.wav"
i "Play" 8 1 "JungfrauundMensch.mp3"
i "Pos" 8 2000 6 72000 0 1 


;i "Receive" 0 3 ;start listening process first
;i "Send" 1 1    ;then after one second send message
</CsScore>
</CsoundSynthesizer>
;example by joachim heintz
