<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>
<CsInstruments>

sr = 48000
ksmps = 32
nchnls = 2
0dbfs = 1

; Global variables for control
gkPlay init 0
gkPause init 0
gkStop init 0
gSFile init "200119.aif" ; Replace with your soundfile path

; Instrument 1: Play control
instr 1
    gkPlay = 1
    gkPause = 0
    gkStop = 0
    event "i", 5, 0, -1  ; Start playback instrument
    turnoff  ; Turn off this control instrument
endin

; Instrument 2: Pause control
instr 2
    gkPause = 1
    gkPlay = 0
    gkStop = 0
    turnoff
endin

; Instrument 3: Stop control
instr 3
    gkStop = 1
    gkPlay = 0
    gkPause = 0
    turnoff2 5, 0, 0  ; Stop playback instrument
    turnoff
endin

; Instrument 5: Soundfile playback
instr 5
    ; Read soundfile with diskin2
    aSigL, aSigR diskin2 gSFile, 1, 0, 1, 0, 32
    
    ; Apply pause control
    aOutL = aSigL * (1 - gkPause)
    aOutR = aSigR * (1 - gkPause)
    
    outs aOutL, aOutR
endin

</CsInstruments>
<CsScore>
;i 5 0 -1
; Start control instruments at specific times for demonstration
i 1 0 0.1  ; Play at 0 seconds
i 2 5 0.1   ; Pause at 5 seconds
i 1 10 0.1 ; Resume (Play) at 10 seconds
i 3 15 0.1  ; Stop at 15 seconds
e 20      ; End score at 20 seconds
</CsScore>
</CsoundSynthesizer>