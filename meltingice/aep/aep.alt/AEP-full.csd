<CsoundSynthesizer>
<CsOptions>
-odac -iadc 
</CsOptions>
<CsInstruments>
;sr      =  44100
sr = 48000
ksmps   =  sr/1000
nchnls  =  8
nchnls_i  = 8
0dbfs    = 1

#include "udos/AEP_udos.txt"


	 opcode aep_channel, aaaaaaaa,ak
ain,kchannel xin

kend table kchannel-1,10
know timeinsts

if know<kend then
    ;update pos
    kindex = 3*(kchannel-1)
    kt table kindex,8
    ka table kindex+1,8
    kd table kindex+2,8

    kdt table kindex,9
    kda table kindex+1,9
    kdd table kindex+2,9

    kt += kdt
    ka += kda
    kd += kdd

    tablew kt,kindex,8
    tablew ka,kindex+1,8
    tablew kd,kindex+2,8
endif


a1,a2,a3,a4,a5,a6,a7,a8 AEP  ain,6,17,kt,ka,kd
	xout a1,a2,a3,a4,a5,a6,a7,a8
	endop
	

	opcode zakwrite, 0,aaaaaaaa
a1,a2,a3,a4,a5,a6,a7,a8 xin
	zawm a1,1
	zawm a2,2
	zawm a3,3
	zawm a4,4
	zawm a5,5
	zawm a6,6
	zawm a7,7
	zawm a8,8
	endop

opcode subwrite,0,ak
ain, kchannel xin
aout1,aout2,aout3,aout4,aout5,aout6,aout7,aout8 aep_channel ain,kchannel
        zakwrite aout1,aout2,aout3,aout4,aout5,aout6,aout7,aout8
	endop
	
opcode soundouter,0,0
	outc zar(1),zar(2),zar(3),zar(4),zar(5),zar(6),zar(7),zar(8)
	zacl 0,8
        endop	

opcode soundin,aaaaaaaa,0
ain1,ain2,ain3,ain4,ain5,ain6,ain7,ain8 inch 1, 2, 3, 4, 5, 6, 7, 8
	xout ain1,ain2,ain3,ain4,ain5,ain6,ain7,ain8
	endop
	
;##############################################################	

giPortHandle OSCinit 47120
;gkt = 0
;gka = 0
;gkr = 1

zakinit 8,8


instr 88
ain1,ain2,ain3,ain4,ain5,ain6,ain7,ain8 soundin
        subwrite rand(1),1
        subwrite ain2,2
        subwrite ain3,3
        subwrite ain4,4
        subwrite ain5,5
        subwrite ain6,6
        subwrite ain7,7
        subwrite ain8,8
	soundouter
endin


instr 8
ain1,ain2,ain3,ain4,ain5,ain6,ain7,ain8 inch 1, 2, 3, 4, 5, 6, 7, 8

ain1 rand 1

aout1,aout2,aout3,aout4,aout5,aout6,aout7,aout8 aep_channel ain1,1
        zakwrite aout1,aout2,aout3,aout4,aout5,aout6,aout7,aout8
	
aout1,aout2,aout3,aout4,aout5,aout6,aout7,aout8 aep_channel ain2,2
        zakwrite aout1,aout2,aout3,aout4,aout5,aout6,aout7,aout8
	
aout1,aout2,aout3,aout4,aout5,aout6,aout7,aout8 aep_channel ain3,3
        zakwrite aout1,aout2,aout3,aout4,aout5,aout6,aout7,aout8
	
aout1,aout2,aout3,aout4,aout5,aout6,aout7,aout8 aep_channel ain4,4
        zakwrite aout1,aout2,aout3,aout4,aout5,aout6,aout7,aout8
	
aout1,aout2,aout3,aout4,aout5,aout6,aout7,aout8 aep_channel ain5,5
        zakwrite aout1,aout2,aout3,aout4,aout5,aout6,aout7,aout8
	
aout1,aout2,aout3,aout4,aout5,aout6,aout7,aout8 aep_channel ain6,6
        zakwrite aout1,aout2,aout3,aout4,aout5,aout6,aout7,aout8
	
aout1,aout2,aout3,aout4,aout5,aout6,aout7,aout8 aep_channel ain7,7
        zakwrite aout1,aout2,aout3,aout4,aout5,aout6,aout7,aout8
	
aout1,aout2,aout3,aout4,aout5,aout6,aout7,aout8 aep_channel ain8,8
        zakwrite aout1,aout2,aout3,aout4,aout5,aout6,aout7,aout8

	outc zar(1),zar(2),zar(3),zar(4),zar(5),zar(6),zar(7),zar(8)
	zacl 0,8
endin
					

/*
instr 1
;ain      rand    1
ain	  oscils 1,440,0
korder   init    4
a1,a2,a3,a4 AEP  ain,korder,17,gkt,gka,gkr
         outc    a1*0.1,a2*0.1,a3*0.1,a4*0.1
endin

instr 3
kt init 0
ka init 0
kradius init 1

kGotIt OSClisten giPortHandle, "/gunnar/move","fff",kt,ka,kradius
if kGotIt == 1 then
   schedule 13, 0, 1, gkt, kt
endif
endin

instr 13
gkt line p4,p3,p5
endin
*/

instr 2
kc init 0
kt init 0
ka init 0
kd init 1
kdur init 0
ktrig init 1
kGotIt OSClisten giPortHandle, "/gunnar/pos","iffff",kc,kt,ka,kd,kdur
if kGotIt == 1 then

   know timeinsts
; write endtime to table 10
   tablew know+kdur,kc-1,10

;calc rotation
   kindex = 3*(kc-1)

   ;get curent pos
   kct table kindex,8
   kca table kindex+1,8
   kcd table kindex+2,8
   
   tablew (kt-kct)/(kdur*1000),kindex,9
   tablew (ka-kca)/(kdur*1000),kindex+1,9
   tablew (kd-kcd)/(kdur*1000),kindex+2,9
   printf "position channel %i to %f %f %f in %f s\n",ktrig,kc,kt,ka,kd,kdur
   ktrig += 1
endif

kGotIt OSClisten giPortHandle, "/gunnar/rot","ifff",kc,kt,ka,kd
if kGotIt == 1 then
   kindex = 3*(kc-1)
   tablew kt,kindex,9
   tablew ka,kindex+1,9
   tablew kd,kindex+2,9
   printf "/gunnar/rotate %i %f %f %f %f\n",ktrig,kc,kt,ka,kd
   ktrig += 1
endif

endin

instr 30
;ain      rand    1
;ain,ain2            soundin "udos/ClassGuit.wav"
ain	  oscils 1,440,0
kt       line    0,p3,100*360
korder   init    14
;kdist  Dist kx, ky, kz
a1,a2,a3,a4 AEP  ain,korder,17,kt,0,1
         outc    a1*0.1,a2*0.1,a3*0.1,a4*0.1
endin

</CsInstruments>
<CsScore>

;fuction for speaker positions
; GEN -2, parameters: max_speaker_distance, xs1,ys1,zs1,xs2,ys2,zs2,...
;octahedron
;f17 0 32 -2 1 1 0 0  -1 0 0  0 1 0  0 -1 0  0 0 1  0 0 -1
;cube
;f17 0 32 -2 1,732 1 1 1  1 1 -1  1 -1 1  -1 1 1
;octagon
;f17 0 32 -2 1 0.924 -0.383 0 0.924 0.383 0 0.383 0.924 0 -0.383 0.924 0
;-0.924 0.383 0 -0.924 -0.383 0 -0.383 -0.924 0 0.383 -0.924 0
;f17 0 32 -2  1  0 0 1  45 0 1  90 0 1  135 0 1  180 0 1  225 0 1  270 0 1  315 0 1
;f17 0 32 -2 1 0 -90 1 0 -70 1 0 -50 1 0 -30 1 0 -10 1 0 10 1 0 30 1 0 50 1

; soundpos
f8 0 32 -2  0 0 1  10 0 1  20 0 1  30 0 1  40 0 1  50 0 1  60 0 1  70 0 1  0 0 0

;soundrot
f9 0 32 -2  0 0 0   0 0 0   0 0 0  0 0 0   0 0 0  0 0 0   0 0 0   0 0 0  0 0 0
;endtime
f10 0 32 -2   0 0 0 0 0 0 0 0

; speakerpos
;square
f17 0 32 -2 1   -45 0 1  45 0 1   135 0 1  225 0 1
;octagon
;f17 0 32 -2 1  0 0 1  45 0 1  90 0 1  135 0 1  180 0 1  225 0 1  270 0 1  315 0 1



i88 0 2000
i2 0 2000

;i1 0 2000
;i2 0 2000
;i3 0 2000
;i30 0 2000
</CsScore>
</CsoundSynthesizer>
;example by martin neukom
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>100</x>
 <y>100</y>
 <width>320</width>
 <height>240</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="background">
  <r>240</r>
  <g>240</g>
  <b>240</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>
