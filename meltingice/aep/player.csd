<CsoundSynthesizer>
<CsOptions>
; Real-time audio output
-odac
</CsOptions>
<CsInstruments>

sr = 44100      ; Sample rate
ksmps = 32      ; Samples per control cycle
nchnls = 2      ; Stereo output
0dbfs = 1       ; Full-scale amplitude

; Global variables
gkPlayStatus init 0    ; 0 = stopped, 1 = playing, 2 = paused
gkPosition init 0      ; Current playback position (in seconds)
gkGain init 0.7        ; Output gain
gSFile = "200119.aif"  ; Replace with your soundfile path

; Instrument 1: Soundfile playback
instr 1
    ; Read control parameters
    kPlayStatus = gkPlayStatus
    kPosition = gkPosition
    kGain = gkGain

    ; Read soundfile with diskin2 (supports stereo, variable speed)
    aSigL, aSigR diskin2 gSFile, 1, kPosition ;, 0, 0, 0, 0

    ; Apply play/pause/stop logic
    aOutL = aSigL * kGain * (kPlayStatus == 1 ? 1 : 0)
    aOutR = aSigR * kGain * (kPlayStatus == 1 ? 1 : 0)

    ; Update playback position when playing
    if (kPlayStatus == 1) then
        gkPosition = kPosition + ksmps/sr
    endif

    ; Output audio
    outs aOutL, aOutR
endin

; Instrument 2: Control play
instr 2
    gkPlayStatus = 1    ; Set to playing
    ; If paused, resume from current position
    ; If stopped, position remains unchanged (likely 0)
endin

; Instrument 3: Control pause
instr 3
    gkPlayStatus = 2    ; Set to paused
    ; Position is preserved
endin

; Instrument 4: Control stop
instr 4
    gkPlayStatus = 0    ; Set to stopped
    gkPosition = 0      ; Reset position to start
endin

</CsInstruments>
<CsScore>
; Start playback instrument indefinitely
i 1 0 -1

; Simulate control events (play, pause, stop)
; Format: instrument start_time duration
i 2 0 0     ; Play at 0 seconds
i 3 5 0     ; Pause after 5 seconds
i 2 8 0     ; Resume playing at 8 seconds
i 4 12 0    ; Stop at 12 seconds
i 2 15 0    ; Play again at 15 seconds

e 20        ; End score after 20 seconds
</CsScore>
</CsoundSynthesizer>
