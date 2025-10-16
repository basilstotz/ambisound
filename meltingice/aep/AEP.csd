<CsoundSynthesizer>
<CsOptions>
-odac -iadc -+rtaudio=jack -+jack_client=Panner 
</CsOptions>
<CsInstruments>
;sr      =  44100
sr = 48000
ksmps   =  64

nchnls  =  12
nchnls_i  = 10

0dbfs    = 1

gifactor init sr/ksmps

gainput[] init 8
gamix[] init 8

gasubbass init 0

gkvol_act[] fillarray -18, -18, -18, -18, -18, -18, -18, -18
gkvol_delta[] fillarray 0, 0, 0, 0, 0, 0, 0, 0
gkvol_end[] init 8

gkspvol[] fillarray 0, 0, 0, 0, 0, 0, 0, 0

gkmaster init 0

#include "udos/AEP_udos.txt"
#include "udos/ambisonics_utilities.txt"
#include "udos/ambisonics_udos.txt"

/*
;**************************** xyz_to_aed *****************************************************
; is in "udos/ambisonics_udos.txt"!

opcode xyz_to_aed,kkk,kkk
kx,ky,kz xin
     kt  taninv2 ky,kx
     kt  degree kt
     kpro = sqrt(kx*kx+ky*ky)
     ka  taninv2 kz,kpro
     ka degree ka
     kd  dist kx,ky,kz
     xout kt,ka,kd
     endop
*/

;******************************update automation********************************************
	opcode automation,0,k
kchannel xin

know times
kend table kchannel-1,10

if know<kend then ;update position

    ;get current
    kindex = 3*(kchannel-1)
    kt table kindex,8
    ka table kindex+1,8
    kd table kindex+2,8

    ;get rot
    kdt table kindex,9
    kda table kindex+1,9
    kdd table kindex+2,9
    
    ;update pos
    kt += kdt
    ka += kda
    kd += kdd

;write new current
    tablew kt,kindex,8
    tablew ka,kindex+1,8
    tablew kd,kindex+2,8
endif

kch = kchannel-1
if know<gkvol_end[kch] then
   gkvol_act[kch] = gkvol_act[kch]+gkvol_delta[kch]
endif

endop	


opcode update_rot, 0, kkkkk
   kchan,kt,ka,kd,kdur xin

   ;update_rot kchan,kt,ka,kd,kdur


   ;calc rotation
   kindex = 3*(kchan-1)

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
   know times
   kfut = know+kdur
   ;println "gifactor %f",gifactor
   ;println "know %f",know
   ;println "kdur %f",kdur
   ;println "kfut %f",kfut
   tablew kfut,kchan-1,10
endop

;**************************aep_channel **************************************************

	 opcode aep_channel, aaaaaaaa,ak
ain,kchannel xin


   automation kchannel

    ;get current
    kindex = 3*(kchannel-1)
kt table kindex,8
ka table kindex+1,8
kd table kindex+2,8


if kd<1.0 then
   korder=5*kd
else
   korder=5
endif

kkorr = 0.05 * (korder/5.0)*(1-0.1)

a1,a2,a3,a4,a5,a6,a7,a8 AEP  kkorr*ain,korder,17,kt,ka,kd
	xout a1,a2,a3,a4,a5,a6,a7,a8
	endop
	
; subwrite **************************************************

opcode subwrite,0,ak
ain, kchannel xin
aout0,aout1,aout2,aout3,aout4,aout5,aout6,aout7 aep_channel ain,kchannel
        zawm aout0,0
	zawm aout1,1
	zawm aout2,2
	zawm aout3,3
	zawm aout4,4
	zawm aout5,5
	zawm aout6,6
	zawm aout7,7        
	endop


; sounouter **********************************************************

opcode soundouter,0,0
ao=0
;ar = rand(1)*0.1
;alpf = butterlp(ar,80)

	outc ao,ao,gasubbass,gasubbass,db(gkspvol[0])*zar(0),db(gkspvol[1])*zar(1),db(gkspvol[2])*zar(2),db(gkspvol[3])*zar(3),db(gkspvol[4])*zar(4),db(gkspvol[5])*zar(5),gasubbass,db(gkspvol[7])*zar(7)
	zacl 0,8
        endop	

opcode soundtofile,0,0
;Sfilename xin
ao=0
       fout "ambisonic.ogg",50,ao,ao,gasubbass,gasubbass,db(gkspvol[0])*zar(0),db(gkspvol[1])*zar(1),db(gkspvol[2])*zar(2),db(gkspvol[3])*zar(3),db(gkspvol[4])*zar(4),db(gkspvol[5])*zar(5),gasubbass,db(gkspvol[7])*zar(7)
       endop

; soundinner **********************************************************

opcode soundinner,aaaaaaaa,0
ain1,ain2,ain3,ain4,ain5,ain6,ain7,ain8 inch 3, 4, 5, 6, 7, 8, 9, 10
;ain1	rand 1

	xout ain1,ain2,ain3,ain4,ain5,ain6,ain7,ain8
	endop


;##############################################################	
;##############################################################
;##############################################################	
;##############################################################
;##############################################################	
;##############################################################

giPortHandle OSCinit 47120

gkinstance init 0 

zakinit 8,8

gSfilename init "sounds/100319-master.ogg"
gksoundpos init 0


; ***************************input external****************************************************************
instr 11
      gainput[0],gainput[1],gainput[2],gainput[3],gainput[4],gainput[5],gainput[6],gainput[7] inch 3, 4, 5, 6, 7, 8, 9, 10
;gainput[0]       oscils 1,440,0
;gainput[1] rand 1
endin

;**************************play soundfile*****************************************
instr 12

ilen filelen p4
;p3 = ilen



ichn filenchnls  p4
if ichn>4 then
   ic=4
else
   ic=ichn
endif

ainput[] diskin p4,1,0

kindx = 0
while kindx<ic do
    gainput[4+kindx]=ainput[kindx]
    kindx = kindx+1
od

kduration timeinsts
gksoundpos = kduration

if kduration > ilen then
   gksoundpos = 0
   turnoff
endif

;soundtofile

endin




;******************************input volume***********************************************
instr 18
    kidx=0
    while kidx<8 do
      gamix[kidx] = db(gkmaster+gkvol_act[kidx])*gainput[kidx]
      kidx = kidx+1
    od
endin

;************************subbass****************************************
instr 52
   gasubbass = 0
   kidx = 0
   while kidx<8 do
     gasubbass = gasubbass + gamix[kidx]
     kidx = kidx+1
   od
endin

; ***************************panner****************************************
instr 53
        kidx=0
	while kidx<8 do
	   subwrite gamix[kidx],kidx+1
	   kidx=kidx+1
	od
	
;	soundouter

endin

; ***********************output*****************************************************
instr 99
    soundtofile
endin

;instr 100
;endin

; analog out
instr 101
    soundouter
endin

instr 1
  p3 = 1
  update_rot p4,p5,p6,p7,p8
endin

 

; osc %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
instr 2
kchan init 0
kt init 0
ka init 0
kd init 1
kdur init 0
kvol init 1.0

ktrig init 1
kcount init 0

kGotIt OSClisten giPortHandle, "/gunnar/set","ifff",kchan,kt,ka,kd
if kGotIt == 1 then
   kindex = 3*(kchan-1)
   tablew kt,kindex,8
   tablew ka,kindex+1,8
   tablew kd,kindex+2,8
   ktrig = ktrig+1
   ;printf "set channel %i to %f %f %f\n",ktrig,kchan,kt,ka,kd
endif

kGotIt OSClisten giPortHandle, "/gunnar/pos","ifff",kchan,kt,ka,kd     ;,kdur
if kGotIt == 1 then
   ;println "kdur %f",kdur

   update_rot kchan,kt,ka,kd,0.05
if kchan == 1 then
   ;printf "position channel %i to %f %f %f in %f s\n",ktrig,kchan,kt,ka,kd,kdur
   ;printf "delta    channel %i to %f %f %f in %f s\n",ktrig,kchan,kdt,kda,kdd,know
endif
   ktrig += 1
endif

/*
kGotIt OSClisten giPortHandle, "/gunnar/vol","iff",kchan,kvol,kdur
if kGotIt == 1 then
   kindex = kchan-1

   gkvol_delta[kindex] = (kvol-gkvol_act[kindex])/(gifactor*kdur)
   
; write endtime 
   know times
   gkvol_end[kindex] = know+kdur

   printf "/gunnar/vol %i auf %f in %f s\n",ktrig,kchan,kvol,kdur
   ktrig += 1
endif
*/

kGotIt OSClisten giPortHandle, "/gunnar/vol","if",kchan,kvol
if kGotIt == 1 then
   kindex = kchan-1
   gkvol_act[kindex] = kvol

/*
   gkvol_delta[kindex] = (kvol-gkvol_act[kindex])/(gifactor*kdur)
   
; write endtime 
   know times
   gkvol_end[kindex] = know+kdur
*/
   printf "/gunnar/vol %i auf %f in %f s\n",ktrig,kchan,kvol,kdur
   ktrig += 1
endif


;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Sfile init ""
kGotIt OSClisten giPortHandle, "/gunnar/file","s",Sfile
if kGotIt == 1 then
  gSfilename strcpyk Sfile
  println "file %s",gSfilename
  println "lfile %s",Sfile
endif

kGotIt OSClisten giPortHandle, "/gunnar/play",""
if kGotIt == 1 then
  ktrig +=1
  ;ilen filelen Sfile
String init ""
  ;gksoundpos = 0;
  String sprintfk {{i 12 0 -1 "%s"}},gSfilename
  println "play file %s",String
  scoreline String,ktrig
endif

kGotIt OSClisten giPortHandle, "/gunnar/stop",""
if kGotIt == 1 then
  ktrig +=1
  ;String sprintfk {{i -12 0 0}}
  println "stop file"
  gksoundpos = 0
  ;turnoff 12
  scoreline "i -12.0 0 1",ktrig
endif

kGotIt OSClisten giPortHandle, "/gunnar/pause",""
if kGotIt == 1 then
  ktrig +=1
  ;String sprintfk {{i -12 0 0}}
  println "pause file"
  ;turnoff 12
  scoreline "i -12.0 0 1",ktrig
endif

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

endin

instr 9
  kcount init 0
  ktrig init 0
  if kcount%gifactor == 0 then
     ktrig=ktrig+1
     kfut table 4,10
     know times
     kdt table 4*3,9
     kt5 table 4*3,8
     kt6 table 5*3,8
     kv5 = gkvol_act[4]
     kv6 = gkvol_act[5]
     ;ktrig changed kt5,kt6,kv5,kv6
     ;printf "%f %f  %f %f",ktrig,kt5,kv5,kt6,kv6
     ;println "%f %f  %f %f  %f %f  %f",kt5,kv5,kt6,kv6,kfut,know,kdt
     //OSCsend ktrig, "192.168.1.112", 47130, "/status", "ffff",kt5,kv5,kt6,kv6
  endif
  kcount=kcount+1
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
f10 0 32 -2   0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0

; speakerpos
;square
f17 0 32 -2 1   -45 0 1  45 0 1   135 0 1  225 0 1 -45 0 1  45 0 1   135 0 1  225 0 1
;octagon
;f17 0 32 -2 1  0 0 1  45 0 1  90 0 1  135 0 1  180 0 1  225 0 1  270 0 1  315 0 1

;speaker volume
f18 0 32 -2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0

;i1 0 1 4 6000 0 1 300
i2 0 20000   ;osc
i9 0 20000   ;print

i11 0 20000  ;analog in
i18 0 20000  ;input volume

i52 0 20000  ;subbass
i53 0 20000  ;panner

;i100 0 60 ;"ambitest.ogg"
i101 0 20000 ;analog out


;i15 0 1 "200119.aif"
;1 60 "JungfrauundMensch.mp3"

</CsScore>
</CsoundSynthesizer>
;example by martin neukom
