-- V-909 Step Sequencer for lpp-vita
-- Drums + Bass groove box with Track sequencer

Sound.init()

-- ============================================================
-- CONSTANTS & LAYOUT
-- ============================================================
local SW, SH      = 960, 544
local TOP_H       = 363
local BOT_H       = 181
local BOT_Y       = TOP_H
local TAB_H       = 30
local INST_AREA_Y = TAB_H
local INST_AREA_H = TOP_H - TAB_H
local CARD_W      = SW / 2
local CARD_H      = INST_AREA_H / 2
local PAD_MARGIN  = 4
local CTRL_ROW_H  = 30
local BTN_H       = 40
local BTN_W       = 80
local PREV_W      = 76
local PREV_H      = 40
local PAD_SIZE    = math.floor((SW - PAD_MARGIN * 17) / 16)
local PAD_H       = BOT_H - CTRL_ROW_H - PAD_MARGIN * 3
local TOTAL_PAD_W = 16 * PAD_SIZE + 15 * PAD_MARGIN
local PAD_START_X = math.floor((SW - TOTAL_PAD_W) / 2)
local PAD_Y       = BOT_Y + PAD_MARGIN

local KNOB_H      = 12
local KNOB_W      = 120
local KNOB_GAP    = 6

local NUM_TABS    = 5
local NUM_TRACKS  = 16

-- Track tab slot layout
local TSLOT_COLS  = 8
local TSLOT_ROWS  = 2
local TSLOT_W     = math.floor(SW / TSLOT_COLS)
local TSLOT_H     = math.floor(INST_AREA_H / TSLOT_ROWS)

-- Save popup
local POPUP_W     = 480
local POPUP_H     = 320
local POPUP_X     = math.floor((SW - POPUP_W) / 2)
local POPUP_Y     = math.floor((544 - POPUP_H) / 2)
local PSLOT_COLS  = 8
local PSLOT_ROWS  = 2
local PSLOT_W     = math.floor(POPUP_W / PSLOT_COLS)
local PSLOT_H     = math.floor((POPUP_H - 40) / PSLOT_ROWS)

-- ============================================================
-- COLORS
-- ============================================================
local C = {
    bg            = Color.new(15,  15,  15,  255),
    card          = Color.new(30,  30,  30,  255),
    card_sel      = Color.new(40,  40,  50,  255),
    tab           = Color.new(40,  40,  40,  255),
    tab_act       = Color.new(60,  60,  70,  255),
    tab_bass      = Color.new(50,  40,  60,  255),
    tab_track     = Color.new(30,  50,  40,  255),
    tab_track_act = Color.new(40,  80,  60,  255),
    green         = Color.new(40,  200, 80,  255),
    green_dim     = Color.new(20,  80,  35,  255),
    red           = Color.new(220, 50,  50,  255),
    red_dim       = Color.new(80,  20,  20,  255),
    preview       = Color.new(180, 140, 40,  255),
    step_on       = Color.new(220, 180, 40,  255),
    step_off      = Color.new(50,  50,  50,  255),
    step_off2     = Color.new(65,  65,  65,  255),
    step_play     = Color.new(255, 255, 255, 255),
    divider       = Color.new(60,  60,  60,  255),
    white         = Color.new(255, 255, 255, 255),
    grey          = Color.new(140, 140, 140, 255),
    black         = Color.new(0,   0,   0,   255),
    bpm_bg        = Color.new(25,  25,  35,  255),
    knob_bg       = Color.new(20,  20,  20,  255),
    knob_fill     = Color.new(80,  160, 220, 255),
    knob_lbl      = Color.new(160, 160, 160, 255),
    beat_lbl      = Color.new(180, 140, 40,  255),
    bass_fill     = Color.new(140, 80,  200, 255),
    track_fill    = Color.new(40,  180, 120, 255),
    track_dim     = Color.new(20,  60,  40,  255),
    track_sel     = Color.new(60,  220, 150, 255),
    popup_bg      = Color.new(20,  20,  28,  255),
    popup_brd     = Color.new(80,  80,  100, 255),
    song_on       = Color.new(40,  200, 80,  255),
    song_off      = Color.new(60,  60,  60,  255),
}

-- ============================================================
-- HELPERS
-- ============================================================
local function cardRect(slot)
    local col = (slot-1) % 2
    local row = math.floor((slot-1) / 2)
    return col*CARD_W, INST_AREA_Y + row*CARD_H, CARD_W, CARD_H
end

local function inRect(tx, ty, x, y, w, h)
    return tx >= x and tx <= x+w and ty >= y and ty <= y+h
end

local function tabInstruments(tab)
    local out = {}
    for i, inst in ipairs(instruments) do
        if inst.tab == tab then out[#out+1] = i end
    end
    return out
end

-- ============================================================
-- INSTRUMENTS
-- ============================================================
instruments = {
    -- Tab 1: Drums
    {
        name="KICK", tab=1, mute=false,
        tune_files  = { "BT0AADA.WAV","BT3AADA.WAV","BT7AADA.WAV","BTAAADA.WAV" },
        decay_files = { "BTAA0D0.WAV","BTAA0D3.WAV","BTAA0D7.WAV","BTAA0DA.WAV" },
        tune_idx=4, decay_idx=4, vol=32767,
    },
    {
        name="SNARE", tab=1, mute=false,
        tune_files  = { "ST0T7SA.WAV","ST3T7SA.WAV","ST7T7SA.WAV","STAT7SA.WAV" },
        decay_files = { "STAT0S0.WAV","STAT0S3.WAV","STAT0S7.WAV","STAT0SA.WAV" },
        tune_idx=1, decay_idx=3, vol=32767,
    },
    {
        name="CLAP", tab=1, mute=false,
        tune_files  = { "HANDCLP1.WAV" },
        decay_files = { "HANDCLP1.WAV" },
        tune_idx=1, decay_idx=1, vol=32767,
    },
    {
        name="RIM", tab=1, mute=false,
        tune_files  = { "RIM63.WAV","RIM127.WAV" },
        decay_files = { "RIM63.WAV","RIM127.WAV" },
        tune_idx=2, decay_idx=2, vol=32767,
    },
    -- Tab 2: Cymbals
    {
        name="HH CLS", tab=2, mute=false,
        tune_files  = { "HHCD0.WAV","HHCD2.WAV","HHCD4.WAV","HHCD6.WAV","HHCD8.WAV","HHCDA.WAV" },
        decay_files = { "HHCD0.WAV","HHCD2.WAV","HHCD4.WAV","HHCD6.WAV","HHCD8.WAV","HHCDA.WAV" },
        tune_idx=3, decay_idx=3, vol=32767,
    },
    {
        name="HH OPN", tab=2, mute=false,
        tune_files  = { "HHOD0.WAV","HHOD2.WAV","HHOD4.WAV","HHOD6.WAV","HHOD8.WAV","HHODA.WAV" },
        decay_files = { "HHOD0.WAV","HHOD2.WAV","HHOD4.WAV","HHOD6.WAV","HHOD8.WAV","HHODA.WAV" },
        tune_idx=3, decay_idx=3, vol=32767,
    },
    {
        name="CRASH", tab=2, mute=false,
        tune_files  = { "CSHD0.WAV","CSHD2.WAV","CSHD4.WAV","CSHD6.WAV","CSHD8.WAV","CSHDA.WAV" },
        decay_files = { "CSHD0.WAV","CSHD2.WAV","CSHD4.WAV","CSHD6.WAV","CSHD8.WAV","CSHDA.WAV" },
        tune_idx=3, decay_idx=3, vol=32767,
    },
    {
        name="RIDE", tab=2, mute=false,
        tune_files  = { "RIDED0.WAV","RIDED2.WAV","RIDED4.WAV","RIDED6.WAV","RIDED8.WAV","RIDEDA.WAV" },
        decay_files = { "RIDED0.WAV","RIDED2.WAV","RIDED4.WAV","RIDED6.WAV","RIDED8.WAV","RIDEDA.WAV" },
        tune_idx=3, decay_idx=3, vol=32767,
    },
    -- Tab 3: Toms
    {
        name="LO TOM", tab=3, mute=false,
        tune_files  = { "LT0D7.WAV","LT3D7.WAV","LT7D7.WAV","LTAD7.WAV" },
        decay_files = { "LT7D0.WAV","LT7D3.WAV","LT7D7.WAV","LT7DA.WAV" },
        tune_idx=3, decay_idx=3, vol=32767,
    },
    {
        name="MID TOM", tab=3, mute=false,
        tune_files  = { "MT0D7.WAV","MT3D7.WAV","MT7D7.WAV","MTAD7.WAV" },
        decay_files = { "MT7D0.WAV","MT7D3.WAV","MT7D7.WAV","MT7DA.WAV" },
        tune_idx=3, decay_idx=3, vol=32767,
    },
    {
        name="HI TOM", tab=3, mute=false,
        tune_files  = { "HT0D7.WAV","HT3D7.WAV","HT7D7.WAV","HTAD7.WAV" },
        decay_files = { "HT7D0.WAV","HT7D3.WAV","HT7D7.WAV","HT7DA.WAV" },
        tune_idx=3, decay_idx=3, vol=32767,
    },
    {
        name="OPCL", tab=3, mute=false,
        tune_files  = { "OPCL1.WAV","OPCL2.WAV","OPCL3.WAV","OPCL4.WAV" },
        decay_files = { "OPCL1.WAV","OPCL2.WAV","OPCL3.WAV","OPCL4.WAV" },
        tune_idx=1, decay_idx=1, vol=32767,
    },
    -- Tab 4: Bass
    {
        name="BASS", tab=4, mute=false,
        tune_files  = { "bass/BASS.WAV","bass/BASS_OD.WAV" },
        decay_files = { "bass/BASS.WAV","bass/BASS_OD.WAV" },
        tune_idx=1, decay_idx=1, vol=32767,
    },
    {
        name="SYNTH", tab=4, mute=false,
        tune_files  = { "bass/SYNTH.WAV","bass/SYNTH_OD.WAV" },
        decay_files = { "bass/SYNTH.WAV","bass/SYNTH_OD.WAV" },
        tune_idx=1, decay_idx=1, vol=32767,
    },
    {
        name="METAL", tab=4, mute=false,
        tune_files  = { "bass/METAL.WAV","bass/METAL_OD.WAV" },
        decay_files = { "bass/METAL.WAV","bass/METAL_OD.WAV" },
        tune_idx=1, decay_idx=1, vol=32767,
    },
    {
        name="ACCENT", tab=4, mute=false,
        tune_files  = { "bass/ACCENT.WAV","bass/ACCENT_OD.WAV" },
        decay_files = { "bass/ACCENT.WAV","bass/ACCENT_OD.WAV" },
        tune_idx=1, decay_idx=1, vol=32767,
    },
}

-- ============================================================
-- SOUND MANAGEMENT
-- ============================================================
local function currentFile(inst)
    return "app0:samples/" .. (inst.tune_files[inst.tune_idx] or inst.tune_files[1])
end

local function reloadInst(i)
    local inst = instruments[i]
    local path = currentFile(inst)
    if inst.sound then Sound.close(inst.sound) end
    inst.sound = Sound.open(path)
    if inst.sound then Sound.setVolume(inst.sound, inst.vol) end
end

local function triggerInst(i)
    local inst = instruments[i]
    if inst.mute then return end
    if not inst.sound then return end
    if Sound.isPlaying(inst.sound) then
        Sound.close(inst.sound)
        local path = currentFile(inst)
        inst.sound = Sound.open(path)
        if not inst.sound then return end
    end
    Sound.play(inst.sound, NO_LOOP)
    Sound.setVolume(inst.sound, inst.vol)
end

for i = 1, #instruments do
    local path = currentFile(instruments[i])
    instruments[i].sound = Sound.open(path)
    if instruments[i].sound then
        Sound.setVolume(instruments[i].sound, instruments[i].vol)
    end
end

-- ============================================================
-- SEQUENCER STATE
-- ============================================================
local NUM_STEPS      = 16
local steps          = {}
for i = 1, #instruments do
    steps[i] = {}
    for s = 1, NUM_STEPS do steps[i][s] = false end
end

local bpm            = 120
local selected_tab   = 1
local selected_inst  = 1
local current_step   = 0   -- 0 = not started; first tick advances to 1
local playing        = false
local step_timer     = 0
local beat_time      = 60 / bpm / 4
local bpm_hold_timer = 0
local BPM_REPEAT     = 0.08

-- ============================================================
-- TRACK BANK
-- ============================================================
local track_bank      = {}
local arrangement     = {}
local song_mode       = false
-- song_pos: which arrangement slot is currently active (1-based index into arrangement[])
-- 0 means not started
local song_pos        = 0
local current_track   = 0
local show_save_popup = false

for s = 1, NUM_STEPS do arrangement[s] = 0 end

local function snapshotPattern()
    local snap = { steps = {}, inst_state = {} }
    for i = 1, #instruments do
        snap.steps[i] = {}
        for s = 1, NUM_STEPS do snap.steps[i][s] = steps[i][s] end
        snap.inst_state[i] = {
            tune_idx  = instruments[i].tune_idx,
            decay_idx = instruments[i].decay_idx,
            vol       = instruments[i].vol,
            mute      = instruments[i].mute,
        }
    end
    return snap
end

-- loadSnapshot: copies snap data into the live steps[] table.
-- Does NOT touch Sound handles, does NOT reset current_step or step_timer.
local function loadSnapshot(snap)
    for i = 1, #instruments do
        for s = 1, NUM_STEPS do
            steps[i][s] = snap.steps[i][s]
        end
        if snap.inst_state[i] then
            local st = snap.inst_state[i]
            instruments[i].tune_idx  = st.tune_idx
            instruments[i].decay_idx = st.decay_idx
            instruments[i].vol       = st.vol
            instruments[i].mute      = st.mute
            if instruments[i].sound then
                Sound.setVolume(instruments[i].sound, st.vol)
            end
        end
    end
end

local function saveToSlot(slot)
    track_bank[slot] = snapshotPattern()
end

-- loadFromSlot: used only for manual preview loads, NOT during song playback.
-- Resets the sequencer position.
local function loadFromSlot(slot)
    if track_bank[slot] then
        loadSnapshot(track_bank[slot])
        current_track = slot
        current_step  = 0
        step_timer    = 0
    end
end

-- ============================================================
-- SONG MODE ENGINE
--
-- song_pos is the current index into arrangement[] (1..NUM_STEPS).
-- Each bar, we advance song_pos to the next occupied slot and call
-- loadSnapshot directly — no pending_track, no deferred loads,
-- no step/timer resets. The sequencer keeps running uninterrupted.
-- ============================================================

-- Find the first occupied arrangement slot at or after start_pos (wraps).
-- Returns the slot index (1..NUM_STEPS) or 0 if none found.
local function findNextSongPos(start_pos)
    for offset = 0, NUM_STEPS - 1 do
        local try = ((start_pos - 1 + offset) % NUM_STEPS) + 1
        if arrangement[try] ~= 0 and track_bank[arrangement[try]] then
            return try
        end
    end
    return 0
end

-- Called once when playback starts in song mode.
-- Loads the first track immediately so audio starts on bar 1.
local function initSongMode()
    song_pos = findNextSongPos(1)
    if song_pos ~= 0 then
        loadSnapshot(track_bank[arrangement[song_pos]])
        current_track = arrangement[song_pos]
    end
end

-- Called at each bar boundary during song playback.
-- Advances to the next arrangement slot and swaps the pattern.
local function advanceSong()
    local next_pos = findNextSongPos(song_pos + 1)
    if next_pos ~= 0 then
        song_pos = next_pos
        loadSnapshot(track_bank[arrangement[song_pos]])
        current_track = arrangement[song_pos]
    end
    -- If next_pos == 0, no tracks in arrangement, do nothing
end

-- ============================================================
-- ARRANGEMENT PAD CYCLING
-- Tap empty pad: assign lowest-numbered saved track.
-- Tap filled pad: advance to next saved track, or clear if none.
-- ============================================================
local function cycleArrangementSlot(s)
    local cur = arrangement[s]
    if cur == 0 then
        for try = 1, NUM_TRACKS do
            if track_bank[try] then
                arrangement[s] = try
                return
            end
        end
    else
        for try = cur + 1, NUM_TRACKS do
            if track_bank[try] then
                arrangement[s] = try
                return
            end
        end
        arrangement[s] = 0
    end
end

-- ============================================================
-- SAVE / LOAD (Project)
-- ============================================================
local SAVE_PATH = "ux0:data/v909_project.txt"

local function saveProject()
    local f = io.open(SAVE_PATH, "w")
    if not f then return end
    f:write("bpm=" .. bpm .. "\n")
    f:write("song_mode=" .. (song_mode and "1" or "0") .. "\n")
    local arr_str = ""
    for s = 1, NUM_STEPS do arr_str = arr_str .. arrangement[s] .. "," end
    f:write("arr=" .. arr_str .. "\n")
    f:write("live_start\n")
    for i = 1, #instruments do
        local inst = instruments[i]
        local row = ""
        for s = 1, NUM_STEPS do row = row .. (steps[i][s] and "1" or "0") end
        f:write(row .. "\n")
        f:write("v=" .. inst.vol .. ",t=" .. inst.tune_idx .. ",d=" .. inst.decay_idx
            .. ",m=" .. (inst.mute and "1" or "0") .. "\n")
    end
    f:write("live_end\n")
    for slot = 1, NUM_TRACKS do
        if track_bank[slot] then
            f:write("track_start=" .. slot .. "\n")
            local snap = track_bank[slot]
            for i = 1, #instruments do
                local row = ""
                for s = 1, NUM_STEPS do row = row .. (snap.steps[i][s] and "1" or "0") end
                f:write(row .. "\n")
                local st = snap.inst_state[i]
                f:write("v=" .. st.vol .. ",t=" .. st.tune_idx .. ",d=" .. st.decay_idx
                    .. ",m=" .. (st.mute and "1" or "0") .. "\n")
            end
            f:write("track_end\n")
        end
    end
    f:close()
end

local function loadProject()
    local f = io.open(SAVE_PATH, "r")
    if not f then return end
    local function readInstBlock()
        local snap = { steps = {}, inst_state = {} }
        for i = 1, #instruments do
            local row  = f:read("*l") or ""
            local meta = f:read("*l") or ""
            snap.steps[i] = {}
            for s = 1, NUM_STEPS do snap.steps[i][s] = (row:sub(s,s) == "1") end
            snap.inst_state[i] = {
                vol       = tonumber(meta:match("v=(%d+)"))  or 32767,
                tune_idx  = tonumber(meta:match("t=(%d+)"))  or 1,
                decay_idx = tonumber(meta:match("d=(%d+)"))  or 1,
                mute      = (meta:match("m=(%d)") == "1"),
            }
        end
        return snap
    end
    for line in f:lines() do
        if line:sub(1,4) == "bpm=" then
            bpm = tonumber(line:match("bpm=(%d+)")) or bpm
            beat_time = 60 / bpm / 4
        elseif line:sub(1,10) == "song_mode=" then
            song_mode = (line:sub(11,11) == "1")
        elseif line:sub(1,4) == "arr=" then
            local i = 1
            for n in line:sub(5):gmatch("(%d+),") do
                if i <= NUM_STEPS then arrangement[i] = tonumber(n) or 0 end
                i = i + 1
            end
        elseif line == "live_start" then
            local snap = readInstBlock()
            loadSnapshot(snap)
            f:read("*l")
        elseif line:sub(1,12) == "track_start=" then
            local slot = tonumber(line:sub(13))
            if slot then
                track_bank[slot] = readInstBlock()
                f:read("*l")
            end
        end
    end
    f:close()
end

local function newProject()
    for i = 1, #instruments do
        for s = 1, NUM_STEPS do steps[i][s] = false end
        instruments[i].mute = false
    end
    for s = 1, NUM_STEPS do arrangement[s] = 0 end
    track_bank    = {}
    song_mode     = false
    song_pos      = 0
    current_step  = 0
    step_timer    = 0
    bpm           = 120
    beat_time     = 60/bpm/4
    playing       = false
    current_track = 0
end

-- ============================================================
-- DRAW
-- ============================================================
local function drawKnob(label, x, y, val, max_val, color)
    local filled = math.floor((val / max_val) * KNOB_W)
    Graphics.debugPrint(x, y, label, C.knob_lbl)
    local bar_y = y + 10
    Graphics.fillRect(x, x+KNOB_W, bar_y, bar_y+KNOB_H, C.knob_bg)
    if filled > 0 then
        Graphics.fillRect(x, x+filled, bar_y, bar_y+KNOB_H, color)
    end
    Graphics.fillRect(x+filled, x+filled+2, bar_y-2, bar_y+KNOB_H+2, C.white)
end

local function drawTrackTab()
    Graphics.fillRect(1, SW-1, INST_AREA_Y+1, INST_AREA_Y+INST_AREA_H-1, C.card)
    Graphics.debugPrint(12, INST_AREA_Y+8, "TRACKS", C.white)

    local tog_x = SW - 130
    local tog_y = INST_AREA_Y + 6
    Graphics.fillRect(tog_x, tog_x+110, tog_y, tog_y+20,
        song_mode and C.song_on or C.song_off)
    Graphics.debugPrint(tog_x+10, tog_y+4,
        song_mode and "SONG: ON " or "SONG: OFF", C.white)

    for slot = 1, NUM_TRACKS do
        local col    = (slot-1) % TSLOT_COLS
        local row    = math.floor((slot-1) / TSLOT_COLS)
        local sx     = col * TSLOT_W
        local sy     = INST_AREA_Y + 32 + row * TSLOT_H
        local saved  = (track_bank[slot] ~= nil)
        local is_cur = (slot == current_track)

        Graphics.fillRect(sx+2, sx+TSLOT_W-2, sy+2, sy+TSLOT_H-2,
            saved and (is_cur and C.track_sel or C.track_fill) or C.track_dim)
        Graphics.fillEmptyRect(sx, sx+TSLOT_W, sy, sy+TSLOT_H, C.divider)
        Graphics.debugPrint(sx+6, sy+6, "T" .. slot, saved and C.white or C.grey)

        if saved then
            local pb_y = sy + TSLOT_H - 22
            Graphics.fillRect(sx+4,            sx+TSLOT_W-26, pb_y, pb_y+16, C.preview)
            Graphics.debugPrint(sx+8,          pb_y+3, "PREV", C.black)
            Graphics.fillRect(sx+TSLOT_W-22,   sx+TSLOT_W-4,  pb_y, pb_y+16, C.red_dim)
            Graphics.debugPrint(sx+TSLOT_W-18, pb_y+3, "X",   C.white)
        end
    end
end

local function drawSavePopup()
    Graphics.fillRect(0, SW, 0, 544, Color.new(0,0,0,180))
    Graphics.fillRect(POPUP_X, POPUP_X+POPUP_W, POPUP_Y, POPUP_Y+POPUP_H, C.popup_bg)
    Graphics.fillEmptyRect(POPUP_X, POPUP_X+POPUP_W, POPUP_Y, POPUP_Y+POPUP_H, C.popup_brd)
    Graphics.debugPrint(POPUP_X+12, POPUP_Y+10, "SAVE TO TRACK SLOT", C.white)
    for slot = 1, NUM_TRACKS do
        local col  = (slot-1) % PSLOT_COLS
        local row  = math.floor((slot-1) / PSLOT_COLS)
        local sx   = POPUP_X + col * PSLOT_W
        local sy   = POPUP_Y + 36 + row * PSLOT_H
        local saved = (track_bank[slot] ~= nil)
        Graphics.fillRect(sx+2, sx+PSLOT_W-2, sy+2, sy+PSLOT_H-2,
            saved and C.track_fill or C.step_off)
        Graphics.fillEmptyRect(sx, sx+PSLOT_W, sy, sy+PSLOT_H, C.divider)
        Graphics.debugPrint(sx+6, sy+8, "T" .. slot, C.white)
        if saved then
            Graphics.debugPrint(sx+6, sy+20, "OVR", C.grey)
        end
    end
    Graphics.debugPrint(POPUP_X+12, POPUP_Y+POPUP_H-18, "TOUCH OUTSIDE TO CANCEL", C.grey)
end

local function drawUI()
    Graphics.initBlend()
    Screen.clear(C.bg)

    local tab_w      = math.floor(SW / NUM_TABS)
    local tab_labels = { "DRUMS", "CYMBALS", "TOMS", "BASS", "TRACK" }
    for t = 1, NUM_TABS do
        local tx = (t-1) * tab_w
        local col
        if t == selected_tab then
            if     t == 4 then col = C.tab_bass
            elseif t == 5 then col = C.tab_track_act
            else             col = C.tab_act end
        else
            col = (t == 5) and C.tab_track or C.tab
        end
        Graphics.fillRect(tx, tx+tab_w-2, 0, TAB_H, col)
        local lbl = tab_labels[t]
        Graphics.debugPrint(tx + math.floor(tab_w/2) - (#lbl*4), 8, lbl, C.white)
    end

    if selected_tab == 5 then
        drawTrackTab()
    else
        local tab_insts   = tabInstruments(selected_tab)
        local is_bass_tab = (selected_tab == 4)
        for slot, inst_idx in ipairs(tab_insts) do
            local inst           = instruments[inst_idx]
            local cx, cy, cw, ch = cardRect(slot)
            local is_sel         = (inst_idx == selected_inst)

            Graphics.fillRect(cx+1, cx+cw-1, cy+1, cy+ch-1, is_sel and C.card_sel or C.card)
            Graphics.fillEmptyRect(cx, cx+cw, cy, cy+ch, C.divider)
            Graphics.debugPrint(cx+12, cy+8, inst.name, C.white)

            local kx, ky = cx+12, cy+28
            drawKnob("VOL", kx, ky, inst.vol, 32767, C.knob_fill)

            if is_bass_tab then
                local od_on = (inst.tune_idx == 2)
                local ob_x  = kx + KNOB_W + KNOB_GAP + 28
                local ob_y  = ky + 10
                Graphics.fillRect(ob_x, ob_x+BTN_W, ob_y, ob_y+KNOB_H+4,
                    od_on and C.red or C.red_dim)
                Graphics.debugPrint(ob_x+18, ob_y+2, od_on and "OD ON" or "OD OFF", C.white)
            elseif #inst.tune_files > 1 then
                drawKnob("TUNE", kx+KNOB_W+KNOB_GAP+28, ky,
                    inst.tune_idx-1, #inst.tune_files-1, Color.new(180,100,220,255))
            end

            if not is_bass_tab and #inst.decay_files > 1 then
                drawKnob("DCAY", kx+(KNOB_W+KNOB_GAP+28)*2, ky,
                    inst.decay_idx-1, #inst.decay_files-1, Color.new(220,100,100,255))
            end

            local btn_y  = cy + ch - BTN_H - 18
            local gb_x   = cx + 12
            local rb_x   = gb_x + BTN_W + 12
            local prev_x = cx + cw - PREV_W - 12
            local prev_y = cy + ch - PREV_H - 18

            Graphics.fillRect(gb_x, gb_x+BTN_W, btn_y, btn_y+BTN_H,
                is_sel and C.green or C.green_dim)
            Graphics.debugPrint(gb_x+22, btn_y+math.floor(BTN_H/2)-6, "SEL", C.black)
            Graphics.fillRect(rb_x, rb_x+BTN_W, btn_y, btn_y+BTN_H,
                inst.mute and C.red or C.red_dim)
            Graphics.debugPrint(rb_x+16, btn_y+math.floor(BTN_H/2)-6, "MUTE", C.black)
            Graphics.fillRect(prev_x, prev_x+PREV_W, prev_y, prev_y+PREV_H, C.preview)
            Graphics.debugPrint(prev_x+22, prev_y+math.floor(PREV_H/2)-6, "PLAY", C.black)

            local dot_y = cy + ch - 8
            local dot_w = math.floor((cw - 24) / NUM_STEPS)
            for s = 1, NUM_STEPS do
                local dot_x = cx + 12 + (s-1)*dot_w
                local dcol
                if s == current_step and playing then
                    dcol = C.step_play
                elseif steps[inst_idx][s] then
                    dcol = is_bass_tab and C.bass_fill or C.step_on
                else
                    dcol = C.step_off
                end
                Graphics.fillRect(dot_x, dot_x+dot_w-1, dot_y, dot_y+5, dcol)
            end
        end
    end

    Graphics.fillRect(0, SW, BOT_Y, BOT_Y+2, C.divider)

    local beat_labels  = {"1","2","3","4"}
    local is_track_tab = (selected_tab == 5)
    for s = 1, NUM_STEPS do
        local sx         = PAD_START_X + (s-1)*(PAD_SIZE+PAD_MARGIN)
        local beat_group = math.floor((s-1) / 4)
        local col

        if is_track_tab then
            local slot = arrangement[s]
            if s == song_pos and song_mode and playing then
                col = C.step_play
            elseif slot ~= 0 and track_bank[slot] then
                col = C.track_fill
            else
                col = (beat_group % 2 == 0) and C.step_off or C.step_off2
            end
        else
            if s == current_step and playing then
                col = C.step_play
            elseif steps[selected_inst][s] then
                col = (selected_tab == 4) and C.bass_fill or C.step_on
            else
                col = (beat_group % 2 == 0) and C.step_off or C.step_off2
            end
        end

        Graphics.fillRect(sx, sx+PAD_SIZE, PAD_Y, PAD_Y+PAD_H, col)
        if (s-1) % 4 == 0 then
            Graphics.debugPrint(sx+4, PAD_Y+4, beat_labels[beat_group+1], C.beat_lbl)
        end

        if is_track_tab then
            local slot = arrangement[s]
            Graphics.debugPrint(sx+4, PAD_Y+PAD_H-14,
                slot ~= 0 and ("T"..slot) or tostring(s),
                (slot ~= 0) and C.white or C.grey)
        else
            Graphics.debugPrint(sx+4, PAD_Y+PAD_H-14, tostring(s),
                s == current_step and C.black or C.grey)
        end
    end

    local ctrl_y = BOT_Y + BOT_H - CTRL_ROW_H
    Graphics.fillRect(PAD_START_X, PAD_START_X+150, ctrl_y, ctrl_y+CTRL_ROW_H-2, C.bpm_bg)
    Graphics.debugPrint(PAD_START_X+4, ctrl_y+7, "BPM: "..bpm.."  (^v)", C.white)

    local ps_x = PAD_START_X + 160
    Graphics.fillRect(ps_x, ps_x+90, ctrl_y, ctrl_y+CTRL_ROW_H-2,
        playing and C.green or C.red_dim)
    Graphics.debugPrint(ps_x+6, ctrl_y+7, playing and "[X] STOP" or "[X] PLAY", C.white)

    local sl_x = SW - 220
    Graphics.fillRect(sl_x,     sl_x+58,  ctrl_y, ctrl_y+CTRL_ROW_H-2, C.tab)
    Graphics.fillRect(sl_x+68,  sl_x+126, ctrl_y, ctrl_y+CTRL_ROW_H-2, C.tab)
    Graphics.fillRect(sl_x+136, sl_x+210, ctrl_y, ctrl_y+CTRL_ROW_H-2, C.tab)
    Graphics.debugPrint(sl_x+12,  ctrl_y+7, "SAVE", C.white)
    Graphics.debugPrint(sl_x+78,  ctrl_y+7, "LOAD", C.white)
    Graphics.debugPrint(sl_x+148, ctrl_y+7, "NEW",  C.white)

    if show_save_popup then drawSavePopup() end

    -- DEBUG line always visible so you can see what's happening
    local dbg_steps = ""
    for s = 1, 4 do dbg_steps = dbg_steps .. (steps[1][s] and "1" or "0") end
    Graphics.debugPrint(4, SH - 16,
        "sp=" .. song_pos .. " ct=" .. current_track .. " cs=" .. current_step
        .. " sm=" .. (song_mode and "1" or "0") .. " k=" .. dbg_steps,
        C.white)

    Graphics.termBlend()
    Screen.flip()
end

-- ============================================================
-- MAIN LOOP
-- ============================================================
local last_time = os.clock()
local pad       = Controls.read()
local oldpad    = pad
local touchLast = false

while true do
    oldpad = pad
    pad    = Controls.read()

    local now   = os.clock()
    local delta = now - last_time
    last_time   = now

    -- SEQUENCER ADVANCE
    if playing then
        step_timer = step_timer + delta
        if step_timer >= beat_time then
            step_timer = step_timer - beat_time
            local prev_step = current_step
            current_step = (current_step % NUM_STEPS) + 1

            -- Trigger instruments for this step
            for i = 1, #instruments do
                if steps[i][current_step] then triggerInst(i) end
            end

            -- Bar wrap: advance song if in song mode
            -- prev_step == NUM_STEPS means we just finished a full bar
            if song_mode and prev_step == NUM_STEPS then
                advanceSong()
            end
        end
    end

    -- X = play/stop
    if Controls.check(pad, SCE_CTRL_CROSS) and not Controls.check(oldpad, SCE_CTRL_CROSS) then
        playing = not playing
        if playing then
            current_step = 0
            step_timer   = 0
            if song_mode then
                initSongMode()
            end
        else
            current_step = 0
            step_timer   = 0
            song_pos     = 0
        end
    end

    -- SELECT = quit
    if Controls.check(pad, SCE_CTRL_SELECT) and not Controls.check(oldpad, SCE_CTRL_SELECT) then
        break
    end

    -- L/R triggers = cycle tabs
    if Controls.check(pad, SCE_CTRL_LTRIGGER) and not Controls.check(oldpad, SCE_CTRL_LTRIGGER) then
        selected_tab = ((selected_tab-2) % NUM_TABS) + 1
    end
    if Controls.check(pad, SCE_CTRL_RTRIGGER) and not Controls.check(oldpad, SCE_CTRL_RTRIGGER) then
        selected_tab = (selected_tab % NUM_TABS) + 1
    end

    -- DPAD UP/DOWN = BPM
    local du = Controls.check(pad, SCE_CTRL_UP)
    local dd = Controls.check(pad, SCE_CTRL_DOWN)
    if (du and not Controls.check(oldpad, SCE_CTRL_UP)) or
       (dd and not Controls.check(oldpad, SCE_CTRL_DOWN)) then
        bpm_hold_timer = 0
        if du then bpm = math.min(240, bpm+1) end
        if dd then bpm = math.max(40,  bpm-1) end
        beat_time = 60/bpm/4
    elseif du or dd then
        bpm_hold_timer = bpm_hold_timer + delta
        if bpm_hold_timer >= BPM_REPEAT then
            bpm_hold_timer = 0
            if du then bpm = math.min(240, bpm+1) end
            if dd then bpm = math.max(40,  bpm-1) end
            beat_time = 60/bpm/4
        end
    else
        bpm_hold_timer = 0
    end

    -- TOUCH
    local tx, ty    = Controls.readTouch()
    local touched   = tx ~= nil and tx > 0 and ty ~= nil and ty > 0
    local touchEdge = touched and not touchLast
    touchLast       = touched

    -- SAVE POPUP
    if touchEdge and show_save_popup then
        local hit = false
        for slot = 1, NUM_TRACKS do
            local col = (slot-1) % PSLOT_COLS
            local row = math.floor((slot-1) / PSLOT_COLS)
            local sx  = POPUP_X + col * PSLOT_W
            local sy  = POPUP_Y + 36 + row * PSLOT_H
            if inRect(tx, ty, sx, sy, PSLOT_W, PSLOT_H) then
                saveToSlot(slot)
                show_save_popup = false
                hit = true
                break
            end
        end
        if not hit then show_save_popup = false end
        goto continue
    end

    if touchEdge then

        -- TABS
        if ty >= 0 and ty <= TAB_H then
            local tab_w = math.floor(SW / NUM_TABS)
            local t = math.floor(tx / tab_w) + 1
            if t >= 1 and t <= NUM_TABS then selected_tab = t end
            goto continue
        end

        -- TRACK TAB
        if selected_tab == 5 then

            -- Song mode toggle
            if inRect(tx, ty, SW-130, INST_AREA_Y+6, 110, 20) then
                song_mode = not song_mode
                if song_mode and playing then
                    initSongMode()
                end
                if not song_mode then
                    song_pos = 0
                end
                goto continue
            end

            -- Track slot buttons
            for slot = 1, NUM_TRACKS do
                local col = (slot-1) % TSLOT_COLS
                local row = math.floor((slot-1) / TSLOT_COLS)
                local sx  = col * TSLOT_W
                local sy  = INST_AREA_Y + 32 + row * TSLOT_H
                if inRect(tx, ty, sx, sy, TSLOT_W, TSLOT_H) then
                    if track_bank[slot] then
                        local pb_y = sy + TSLOT_H - 22
                        if inRect(tx, ty, sx+TSLOT_W-22, pb_y, 18, 16) then
                            -- DELETE
                            track_bank[slot] = nil
                            if current_track == slot then current_track = 0 end
                            for s = 1, NUM_STEPS do
                                if arrangement[s] == slot then arrangement[s] = 0 end
                            end
                        else
                            -- PREVIEW / load
                            loadFromSlot(slot)
                        end
                    end
                    goto continue
                end
            end

        else
            -- INSTRUMENT CARD BUTTONS (tabs 1-4)
            local tab_insts   = tabInstruments(selected_tab)
            local is_bass_tab = (selected_tab == 4)
            for slot, inst_idx in ipairs(tab_insts) do
                local inst           = instruments[inst_idx]
                local cx, cy, cw, ch = cardRect(slot)
                if inRect(tx, ty, cx, cy, cw, ch) then
                    local btn_y  = cy + ch - BTN_H - 18
                    local gb_x   = cx + 12
                    local rb_x   = gb_x + BTN_W + 12
                    local prev_x = cx + cw - PREV_W - 12
                    local prev_y = cy + ch - PREV_H - 18
                    local kx, ky = cx+12, cy+28

                    if inRect(tx, ty, gb_x,   btn_y, BTN_W,  BTN_H)  then selected_inst = inst_idx end
                    if inRect(tx, ty, rb_x,   btn_y, BTN_W,  BTN_H)  then inst.mute = not inst.mute end
                    if inRect(tx, ty, prev_x, prev_y, PREV_W, PREV_H) then triggerInst(inst_idx) end

                    if is_bass_tab then
                        local ob_x = kx + KNOB_W + KNOB_GAP + 28
                        local ob_y = ky + 10
                        if inRect(tx, ty, ob_x, ob_y, BTN_W, KNOB_H+4) then
                            inst.tune_idx = (inst.tune_idx == 1) and 2 or 1
                            reloadInst(inst_idx)
                        end
                    end
                    goto continue
                end
            end
        end

        -- SEQUENCER STEPS
        if ty >= PAD_Y and ty <= PAD_Y+PAD_H then
            for s = 1, NUM_STEPS do
                local sx = PAD_START_X + (s-1)*(PAD_SIZE+PAD_MARGIN)
                if tx >= sx and tx <= sx+PAD_SIZE then
                    if selected_tab == 5 then
                        cycleArrangementSlot(s)
                    else
                        steps[selected_inst][s] = not steps[selected_inst][s]
                    end
                    break
                end
            end
            goto continue
        end

        -- CONTROLS ROW
        do
            local ctrl_y = BOT_Y + BOT_H - CTRL_ROW_H
            local ps_x   = PAD_START_X + 160
            if inRect(tx, ty, ps_x, ctrl_y, 90, CTRL_ROW_H) then
                playing = not playing
                if playing then
                    current_step = 0
                    step_timer   = 0
                    if song_mode then
                        initSongMode()
                    end
                else
                    current_step = 0
                    step_timer   = 0
                    song_pos     = 0
                end
            end
            local sl_x = SW - 220
            if inRect(tx, ty, sl_x,     ctrl_y, 58, CTRL_ROW_H) then show_save_popup = true end
            if inRect(tx, ty, sl_x+68,  ctrl_y, 58, CTRL_ROW_H) then loadProject() end
            if inRect(tx, ty, sl_x+136, ctrl_y, 74, CTRL_ROW_H) then newProject()  end
        end

    end

    -- KNOB DRAGGING
    if touched and not show_save_popup and selected_tab ~= 5 then
        local tab_insts   = tabInstruments(selected_tab)
        local is_bass_tab = (selected_tab == 4)
        for slot, inst_idx in ipairs(tab_insts) do
            local inst           = instruments[inst_idx]
            local cx, cy, cw, ch = cardRect(slot)
            if inRect(tx, ty, cx, cy, cw, ch) then
                local kx, ky = cx+12, cy+28

                if inRect(tx, ty, kx, ky+10, KNOB_W, KNOB_H) then
                    local frac = math.max(0, math.min(1, (tx-kx)/KNOB_W))
                    inst.vol = math.floor(frac * 32767)
                    if inst.sound then Sound.setVolume(inst.sound, inst.vol) end
                end

                if not is_bass_tab then
                    if #inst.tune_files > 1 then
                        local tkx = kx + KNOB_W + KNOB_GAP + 28
                        if inRect(tx, ty, tkx, ky+10, KNOB_W, KNOB_H) then
                            local frac = math.max(0, math.min(1, (tx-tkx)/KNOB_W))
                            local new_idx = math.floor(frac * (#inst.tune_files-1)) + 1
                            if new_idx ~= inst.tune_idx then
                                inst.tune_idx = new_idx
                                reloadInst(inst_idx)
                            end
                        end
                    end
                    if #inst.decay_files > 1 then
                        local dkx = kx + (KNOB_W + KNOB_GAP + 28)*2
                        if inRect(tx, ty, dkx, ky+10, KNOB_W, KNOB_H) then
                            local frac = math.max(0, math.min(1, (tx-dkx)/KNOB_W))
                            local new_idx = math.floor(frac * (#inst.decay_files-1)) + 1
                            if new_idx ~= inst.decay_idx and not Sound.isPlaying(inst.sound) then
                                inst.decay_idx = new_idx
                                Sound.close(inst.sound)
                                inst.sound = Sound.open("app0:samples/" .. inst.decay_files[inst.decay_idx])
                            end
                        end
                    end
                end
                break
            end
        end
    end

    ::continue::
    drawUI()
end

-- Cleanup
for i = 1, #instruments do
    if instruments[i].sound then Sound.close(instruments[i].sound) end
end
Sound.term()