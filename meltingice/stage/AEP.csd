<CsoundSynthesizer>
<CsOptions>
-odac -iadc 
</CsOptions>
<CsInstruments>
;sr      =  44100
sr = 48000
ksmps   =  64
nchnls  =  8
nchnls_i  = 8
0dbfs    = 1

gifactor init sr/ksmps

#include "udos/AEP_udos.txt"


	 opcode aep_channel, aaaaaaaa,ak
ain,kchannel xin

kend table kchannel-1,10
know timeinsts

if know<kend then
    kindex = 3*(kchannel-1)

    ;get current
    kt table kindex,8
    ka table kindex+1,8
    kd table kindex+2,8

    ;get rot
    kdt table kindex,9
    ;kda table kindex+1,9
    ;kdd table kindex+2,9
    
    ;update pos
    kt += kdt
    ;ka += kda
    ;kd += kdd

    ;write new current
    tablew kt,kindex,8
    ;tablew ka,kindex+1,8
    ;tablew kd,kindex+2,8
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

opcode update_rot, kkk,kkkkk
kchan,kt,ka,kd,kdur xin

   ;calc rotation
   kindex = 3*(kchan-1)

   ;get curent pos
   kct table kindex,8
   kca table kindex+1,8
   kcd table kindex+2,8


   kdt = (kt-kct)/(gifactor*kdur)
   kda = (ka-kca)/(gifactor*kdur)
   kdd = (kd-kcd)/(gifactor*kdur)
   
   tablew kdt,kindex,9
   tablew kda,kindex+1,9
   tablew kdd,kindex+2,9

; write endtime to table 10
   know timeinsts
   kfut = know+kdur
   tablew kfut,kchan-1,10

   xout kdt,kda,kdd

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



instr 2
kchan init 0
kt init 0
ka init 0
kd init 1
kdur init 0
ktrig init 1
kcount init 0



kGotIt OSClisten giPortHandle, "/gunnar/pos","iffff",kchan,kt,ka,kd,kdur
if kGotIt == 1 then

   ;kdt,kda,kdd update_rot kchan,kt,ka,kd,kdur


   ;calc rotation
   kindex = 3*(kchan-1)

   ;get curent pos
   kct table kindex,8
   kca table kindex+1,8
   kcd table kindex+2,8


   kdt = (kt-kct)/(gifactor*kdur)
   kda = (ka-kca)/(gifactor*kdur)
   kdd = (kd-kcd)/(gifactor*kdur)
   
   tablew kdt,kindex,9
   tablew kda,kindex+1,9
   tablew kdd,kindex+2,9

; write endtime to table 10
   know timeinsts
   kfut = know+kdur
   tablew kfut,kchan-1,10


   printf "position channel %i to %f %f %f in %f s\n",ktrig,kchan,kt,ka,kd,kdur
   ;printf "delta    channel %i to %f %f %f in %f s\n",ktrig,kchan,kdt,kda,kfut,know
   ktrig += 1



endif

/*
kcount +=1
if kcount%1000 == 0 then
;   printf "actual channel %i is %f %f %f\n",kcount,kchan,kct,kca,kcd
endif



kGotIt OSClisten giPortHandle, "/gunnar/rot","ifff",kchan,kt,ka,kd
if kGotIt == 1 then
   kindex = 3*(kchan-1)
   tablew kt,kindex,9
   tablew ka,kindex+1,9
   tablew kd,kindex+2,9
   printf "/gunnar/rotate %i %f %f %f %f\n",ktrig,kchan,kt,ka,kd
   ktrig += 1
endif
*/

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
f17 0 32 -2 1   -45 0 1  45 0 1   135 0 1  225 0 1 -45 0 1  45 0 1   135 0 1  225 0 1
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
