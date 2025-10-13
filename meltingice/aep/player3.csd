<CsoundSynthesizer>
<CsOptions>
-odac ; Real-time audio output
</CsOptions>
<CsInstruments>
sr = 48000
ksmps = 32
nchnls = 2
0dbfs = 1

; Global variables
gkPlay init 0 ; Playback state (0 = stopped, 1 = playing, -1 = paused)
gkPos init 0  ; Current playback position (k-rate)
gSFile init "150119.aif"

gaOutL init 0 ; Left channel audio
gaOutR init 0 ; Right channel audio

; Instrument 10: Soundfile playback using diskin2
instr 10
  SFile init gSFile
  iSpeed = 1
  iFormat = 0
  iSkipTime = p4 ; Get initial skip time from p4 (set by score or control)

  iLen filelen SFile
  ;iDur = iLen - iSkipTime
  ;p3 = iDur

  ; Read audio file
  aL, aR diskin2 SFile, iSpeed, iSkipTime, 0, iFormat
  
  ; Apply playback state
  if (gkPlay == 1) then
    gaOutL = aL
    gaOutR = aR
    gkPos = gkPos + (ksmps/sr) * iSpeed ; Update position
  else
    gaOutL = 0
    gaOutR = 0
  endif
  
  ; Output audio
  outs gaOutL, gaOutR

  kinsts timeinsts

  if kinsts > iLen then
    println "auto turnoff 10"
    gkPos = 0
    turnoff
  endif
endin

; Instrument 5: File control
instr 1
  p3 = 1
  gSFile = p4
  turnoff
endin


; Instrument 2: Play control
instr 2
  p3 = 1
  if (gkPlay == 0 || gkPlay == -1) then
    ; Start or resume playback with current gkPos
    gkPlay = 1
    ; Turn off any existing instance of instr 1
    turnoff2 10, 0, 0
    ; Start new instance with current position
    event "i", 10, 0, -1, gkPos
  endif
  turnoff
endin

; Instrument 3: Pause control
instr 3
  p3 = 1
  if (gkPlay == 1) then
    gkPlay = -1 ; Pause playback
    ; Turn off playback instrument but keep gkPos
    turnoff2 10, 0, 0
  endif
  turnoff
endin

; Instrument 4: Stop control
instr 4
  p3 = 1
  gkPlay = 0  ; Stop playback
  gkPos = 0   ; Reset position
  turnoff2 10, 0, 0 ; Turn off playback instrument
  turnoff
endin


</CsInstruments>
<CsScore>
; Example control events
i 1 0 0 "150119.aif"
i 2 0 0   ; Play at start
i 3 5 0   ; Pause after 5 seconds
i 2 10 0  ; Resume after 5 more seconds
i 4 20 0  ; Stop after 5 more seconds
i 1 21 0 "200119.aif"
i 2 23 0
i 4 40 0
;e
</CsScore>
</CsoundSynthesizer>