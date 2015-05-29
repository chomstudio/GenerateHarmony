local VS_TRUE = 1
local VS_FALSE = 0
local CONTINUOUS_PHENOM = "-"
local VOWEL = {
"a", "i", "M", "e", "o",
CONTINUOUS_PHENOM,
"@", "V", "I", "i:", "{", "O:", "Q", "U", "u:", "@r", "eI", "aI", "OI", "@U", "aU", "I@", "e@", "U@", "O@", "Q@",
}
local VOWEL_PATTERN = table.concat(VOWEL, " ")
local vsutils ={}
do
function vsutils.clone(src, dest)
local cpy = dest or {}
for key, value in pairs(src) do
cpy[key] = value
end
return cpy
end
function vsutils.cloneDeep(src, dest)
local cpy = dest or {}
for key, value in pairs(src) do
if type(value) == "table" then
value = vsutils.cloneDeep(value)
end
cpy[key] = value
end
return cpy
end
function vsutils.cloneObject(src, dest)
local cpy = dest or {}
for key, value in pairs(src) do
if type(value) == "table" and key ~= "_class" then
value = vsutils.cloneObject(value)
end
cpy[key] = value
end
local metatable = getmetatable(src)
if metatable then
setmetatable(cpy, metatable)
end
return cpy
end
function vsutils.ipairs(table, from, step)
local function itrnext(t, i)
i = i + step
local o = t[i]
if o ~= nil then 
return i, o
end
end
return itrnext, table, from
end
function vsutils.split(s, delimPattern)
local t={}
s:gsub("([^" .. delimPattern .. "]+)", function (subs)
table.insert(t, subs)
end)
return t
end
function vsutils.safecall(f, ...)
return f and f(...)
end
function vsutils.toVSBool(bool)
local typ = type(bool)
if typ == "boolean" then
if bool then
return VS_TRUE
else
return VS_FALSE
end
elseif typ == "string" then
bool = tonumber(bool)
elseif typ == "number" then
else
error("arg type mismatch")
end
assert(bool == VS_TRUE or bool == VS_FALSE)
return bool
end
function vsutils.toBool(vsBool)
local typ = type(vsBool)
if typ == "number" then
elseif typ == "string" then
vsBool = tonumber(vsBool)
elseif typ == "boolean" then
return vsBool
else
error("arg type mismatch")
end
if vsBool == VS_TRUE then
return true
elseif vsBool == VS_FALSE then
return false
else
error("arg type mismatch")
end
end
function vsutils.isVowel(phenome)
local ret = VOWEL_PATTERN:find(phenome)
return ret and true or false
end
local function createSubMethodtable(self, methodsf)
local methodtable methodtable = {}
if self then
setmetatable(methodtable, {__index = self})
end
vsutils.safecall(methodsf, methodtable)
return methodtable
end
local function createInitFunc(self, initft)
local initf 
local typ = type(initft)
if typ == "function" then
initf = initft
elseif typ == "table" then
initf = function() 
return initft 
end
elseif initft == nil then
return function(obj, ...)
return obj
end
end
return function(obj, ...)
obj.superinit = self and
self._class and
self._class._instanceMethodtable and
self._class._instanceMethodtable._init 
local fields, msg = initf(obj, ...)
if fields then
if obj ~= fields then
vsutils.clone(fields, obj)
end
end
if msg then
error(msg)
end
obj.superinit = nil
return obj
end
end
local function createSubobject(self, initft, methodsft, callfretf, ...)
local subprototype
local typ = type(methodsft)
if typ == "function" or methodsft == nil then
subprototype = createSubMethodtable(self, methodsft)
elseif typ == "table" then
subprototype = methodsft
end
local obj = {}
obj._class = self
setmetatable(obj, {__index = subprototype})
local initf = createInitFunc(self, initft)
obj = initf(obj, ...)
if callfretf then
local callf = callfretf(obj, ...)
setmetatable(obj, {__index = subprototype, __call = callf})
end
return obj
end
local rootobject = createSubobject(nil, nil, function(obj)
function obj:subobject(argt)
local initft, methodsft, callfretf = argt.init, argt.methods, argt.call
return createSubobject(self, initft, methodsft, callfretf)
end
function obj:instance(argt)
local initft, methodsft, callfretf = argt.init, argt.methods, argt.call
local nearestInstanceMethodtable
do
local currentInstanceMethodtable
local class = self._class
while class do 
if class._instanceMethodtable then
local parentInstanceMethodtable = vsutils.clone(class._instanceMethodtable)
if not nearestInstanceMethodtable then
nearestInstanceMethodtable = parentInstanceMethodtable
end
if currentInstanceMethodtable then
setmetatable(currentInstanceMethodtable, {__index = parentInstanceMethodtable})
end
currentInstanceMethodtable = parentInstanceMethodtable
end
class = class._class
end
if currentInstanceMethodtable then
setmetatable(currentInstanceMethodtable, {__index = self}) 
end
end
local parentOfMethodtable = nearestInstanceMethodtable or self
local childInstanceMethodtable = createSubMethodtable(parentOfMethodtable, methodsft)
self._instanceMethodtable = childInstanceMethodtable
self._instanceMethodtable._init = createInitFunc(self, initft)
self._instanceMethodtable._callret = callfretf
return self
end
function obj:new(...)
return createSubobject(
self,
self._instanceMethodtable._init,
self._instanceMethodtable,
self._instanceMethodtable._callret,
...)
end
function obj:getMethodTable()
local methodtable = getmetatable(self)
if methodtable then
return methodtable.__index
end
end
end)
function vsutils.object(argt)
return rootobject:subobject(argt)
end
end
local VSObject = vsutils.object{
init= {
BOOL = {
TRUE = VS_TRUE,
FALSE = VS_FALSE,
},
},
methods= function(cls)
function cls:callRetfunc(ret, successf, failf)
if ret == self.BOOL.TRUE then
vsutils.safecall(successf)
else
vsutils.safecall(failf)
end
return vsutils.toBool(ret)
end
end
}
local CTRL_TYPE = {
DYN = "DYN",
BRE = "BRE",
BRI = "BRI",
CLE = "CLE",
GEN = "GEN",
PIT = "PIT",
PBS = "PBS",
POR = "POR",
}
local CTRL_TYPE_MAP = {
dyn = CTRL_TYPE.DYN,
bre = CTRL_TYPE.BRE,
bri = CTRL_TYPE.BRI,
cle = CTRL_TYPE.CLE,
gen = CTRL_TYPE.GEN,
pit = CTRL_TYPE.PIT,
pbs = CTRL_TYPE.PBS,
por = CTRL_TYPE.POR,
}
VSWrapper = VSObject:subobject{
init=function(cls)
local n1 = VSGetResolution() * 4
local TICK = {}
local j = 1
for i=1, 7 do
TICK["N" .. j] = n1 / j
TICK["N" .. j .. "D"] = n1 / j + n1 / j / 2
TICK["N" .. (j * 2) .. "T"] = n1 / (j * 3)
j = j * 2
end
cls.TICK = TICK 
return cls
end,
methods= function(cls)
function cls:import()
_G.vsutils = vsutils
_G.BOOL = self.BOOL
for name, obj in pairs(self) do
if name:match("^%u") then 
_G[name] = obj
end
end
end
function cls:getControlAt(controlType, posTick)
local ret, value = VSGetControlAt(controlType, posTick)
if ret ~= self.BOOL.TRUE then
error("VSGetControlAt call failed")
end
local ctrl = {
type = controlType,
posTick = posTick,
value = value,
}
return VSWrapper.ControlAtTick:new(ctrl)
end
function cls:getControlsAt(posTick)
local ctrl = {
posTick = posTick,
}
for field, controlType in pairs(CTRL_TYPE_MAP) do
ctrl[field] = self:getControlAt(controlType, posTick):value()
end
return VSWrapper.ControlsAtTick:new(ctrl)
end
function cls:updateControlAt(controlType, posTick, value, successf, failf)
local ret = VSUpdateControlAt(controlType, posTick, value)
return self:callRetfunc(ret, successf, failf)
end
function cls:defaultControlValue(controlType)
local ret, value = VSGetDefaultControlValue(controlType)
if ret ~= self.BOOL.TRUE then
error("VSGetDefaultControlValue call failed")
end
return value
end
function cls:listNote(filterf)
return VSWrapper.NoteDataList:newWithIterator(VSWrapper.NoteIterator:new(), filterf)
end
function cls:listNoteEx(filterf)
return VSWrapper.NoteDataList:newWithIterator(VSWrapper.NoteExIterator:new(), filterf)
end
function cls:listControl(controlType, filterf)
return VSWrapper.ControlDataList:newWithIterator(VSWrapper.ControlIterator:new(controlType), filterf)
end
function cls:listStepControl(controlType, startTick, limitTick, tickStep)
return VSWrapper.ControlDataList:newWithIterator(
VSWrapper.ControlAtTickIterator:new(controlType, startTick, limitTick, tickStep))
end
function cls:listStepControls(startTick, limitTick, tickStep)
return VSWrapper.ControlsDataList:newWithIterator(VSWrapper.ControlsAtTickIterator:new(startTick, limitTick, tickStep))
end
function cls:eachNote(filterf)
return VSWrapper.NoteIterator:new():each(filterf)
end
function cls:eachNoteEx(filterf)
return VSWrapper.NoteExIterator:new():each(filterf)
end
function cls:eachControl(controlType, filterf)
return VSWrapper.ControlIterator:new(controlType):each(filterf)
end
function cls:eachStepControl(controlType, startTick, limitTick, tickStep)
return VSWrapper.ControlAtTickIterator:new(controlType, startTick, limitTick, tickStep):each()
end
function cls:eachStepControls(startTick, limitTick, tickStep)
return VSWrapper.ControlsAtTickIterator:new(startTick, limitTick, tickStep):each()
end
end
}
local Enum = vsutils.object{
methods=function(cls)
function cls:valueOf(ordinal)
return self[ordinal]
end
end
}:instance{
init= function(self, ordinal)
self.value = ordinal
self._class[ordinal] = self
return self
end,
methods= function(obj)
function obj:equals(other)
if self == other then
return true
elseif self.value == other then
return true
else
return false
end
end
function obj:ordinal()
return self.value
end
end
}
VSWrapper.Answer = Enum:subobject{
init= {
IDOK = 1,
IDCANCEL = 2,
IDABORT = 3,
IDRETRY = 4,
IDIGNORE = 5,
IDYES = 6,
IDNO = 7,
}
}:instance{
init= function(self, id)
return self:superinit(id)
end,
methods= function(obj)
function obj:isOk()
return self:ordinal() == self.IDOK
end
function obj:isCancel()
return self:ordinal() == self.IDCANCEL
end
function obj:isAbort()
return self:ordinal() == self.IDABORT
end
function obj:isRetry()
return self:ordinal() == self.IDRETRY
end
function obj:isIgnore()
return self:ordinal() == self.IDIGNORE
end
function obj:isYes()
return self:ordinal() == self.IDYES
end
function obj:isNo()
return self:ordinal() == self.IDNO
end
end
}
VSWrapper.Answer.OK = VSWrapper.Answer:new(VSWrapper.Answer.IDOK)
VSWrapper.Answer.CANCEL = VSWrapper.Answer:new(VSWrapper.Answer.IDCANCEL)
VSWrapper.Answer.ABORT = VSWrapper.Answer:new(VSWrapper.Answer.IDABORT)
VSWrapper.Answer.RETRY = VSWrapper.Answer:new(VSWrapper.Answer.IDRETRY)
VSWrapper.Answer.IGNORE = VSWrapper.Answer:new(VSWrapper.Answer.IDIGNORE)
VSWrapper.Answer.YES = VSWrapper.Answer:new(VSWrapper.Answer.IDYES)
VSWrapper.Answer.NO = VSWrapper.Answer:new(VSWrapper.Answer.IDNO)
VSWrapper.Dialog = VSObject:subobject{
init= {
FIELD_TYPE = {
INT = 0,
BOOL = 1,
FLOAT = 2,
STRING = 3,
LIST = 4,
},
}
}:instance{
init= function(self)
return {
title,
fields = {},
returnValues,
}
end,
methods= function(obj)
function obj:setTitle (title)
self.title = title
end
local function addField(self, name, caption, initValue, fieldType)
table.insert(self.fields, {
name = name,
caption = caption,
initialVal = tostring(initValue),
type = fieldType,
})
end
function obj:addIntfield(name, caption, initValue)
addField(self, name, caption, initValue, self.FIELD_TYPE.INT)
return self
end
function obj:addCheckbox(name, caption, initValue)
addField(self, name, caption, vsutils.toVSBool(initValue), self.FIELD_TYPE.BOOL)
return self
end
function obj:addFloatfield(name, caption, initValue)
addField(self, name, caption, initValue, self.FIELD_TYPE.FLOAT)
return self
end
function obj:addTextfield(name, caption, initValue)
addField(self, name, caption, initValue, self.FIELD_TYPE.STRING)
return self
end
function obj:addList(name, caption, initValues, ...)
local initValText
local typ = type(initValues)
if typ == "string" then
initValText = table.concat({initValues, ...}, ",")
elseif typ == "table" then
initValText = table.concat(initValues, ",")
else
error("arg type mismatch")
end
addField(self, name, caption, initValText, self.FIELD_TYPE.LIST)
return self
end
local function createValues(self)
local values = {}
for i, field in ipairs(self.fields) do
local ret, value
if field.type == self.FIELD_TYPE.INT then
ret, value = VSDlgGetIntValue(field.name)
elseif field.type == self.FIELD_TYPE.BOOL then
ret, value = VSDlgGetBoolValue(field.name)
if ret == self.BOOL.TRUE then
value = vsutils.toBool(value)
end
elseif field.type == self.FIELD_TYPE.FLOAT then
ret, value = VSDlgGetFloatValue(field.name)
elseif field.type == self.FIELD_TYPE.STRING or field.type == self.FIELD_TYPE.LIST then
ret, value = VSDlgGetStringValue(field.name)
end
if ret == self.BOOL.TRUE then
values[field.name] = value
else
error("VSDlgGet*Value call failed")
end
end
return values
end
function obj:show(okf, cancelf)
VSDlgSetDialogTitle(self.title)
for i, field in ipairs(self.fields) do
local ret = VSDlgAddField(field)
if ret ~= self.BOOL.TRUE then
error("VSDlgAddField call failed (field.name=" .. field.name .. ")")
end
end
local ret = VSDlgDoModal()
if ret == VSWrapper.Answer.IDOK then
self.returnValues = createValues(self)
if self.returnValues then
vsutils.safecall(okf)
end
elseif ret == VSWrapper.Answer.IDCANCEL then
vsutils.safecall(cancelf)
end
return VSWrapper.Answer:valueOf(ret)
end
function obj:values()
return self.returnValues
end
end
}
local Record = VSObject:subobject{
methods= function(cls)
function cls:defineDelegateGetter(fieldNames, delegate)
delegate = delegate or "data"
for i, name in ipairs(fieldNames) do
self[name] = function(self)
return self[delegate][name]
end
end
end
end
}:instance{
init= function(self, data)
return {
data = data,
}
end,
methods= function(obj)
function obj:get()
return self.data
end
end
}
local MutableRecord = Record:subobject{
methods= function(cls)
function cls:defineDelegateAccessor(fieldNames, delegate)
delegate = delegate or "data"
for i, name in ipairs(fieldNames) do
self[name] = function(self, value)
if value == nil then
self:preGetFieldValue(name)
return self[delegate][name]
else
self:preSetFieldValue(name)
self[delegate][name] = value
return self
end
end
end
end
end
}:instance{
init= function(self, data)
self.notyet = (data == nil) and true or nil
return self:superinit(data or {})
end,
methods= function(obj)
function obj:set(data)
self.data = data
end
function obj:preSetFieldValue(name, value)
end
function obj:preGetFieldValue(name)
end
end
}
VSWrapper.Note = MutableRecord:subobject{
}:instance{
init= function(self, note)
return self:superinit(note)
end,
methods= function(obj)
function obj:insert(successf, failf)
local ret = VSInsertNote(self:get())
if ret == self.BOOL.TRUE then
self.notyet = nil
end
return self:callRetfunc(ret, successf, failf)
end
function obj:update(successf, failf)
local ret = VSUpdateNote(self:get())
return self:callRetfunc(ret, successf, failf)
end
function obj:save(successf, failf)
if self.notyet then
return self:insert(successf, failf)
else
return self:update(successf, failf)
end
end
function obj:remove(successf, failf)
local ret = VSRemoveNote(self:get())
return self:callRetfunc(ret, successf, failf)
end
obj:defineDelegateAccessor{
"posTick",
"durTick",
"noteNum",
"velocity",
"lyric",
}
function obj:endPosTick(posTick)
if posTick == nil then
return self:get().posTick + self:get().durTick
else
self:get().durTick = posTick - self:get().posTick
return self
end
end
function obj:phonemes(phoneTable, ...)
if phoneTable then
local value = phoneTable
if type(value) == "string" then
value = {phoneTable, ...}
end
self:get().phonemes = table.concat(value, " ")
return self
else
local phone = vsutils.split(self:get().phonemes, "%s")
phone[0] = self:get().phonemes
return phone
end
end
function obj:vowelPhonemes()
local vowels = {}
for i, v in ipairs(self:phonemes()) do
local ret = vsutils.isVowel(v)
if ret then
table.insert(vowels, v)
end
end
vowels[0] = table.concat(vowels, " ")
return vowels
end
function obj:isVowelOnly()
for i, v in ipairs(self:phonemes()) do
local ret = vsutils.isVowel(v)
if not ret then
return false
end
end
return true
end
end
}
VSWrapper.NoteEx = VSWrapper.Note:subobject{
init= {
VIBRATO = {
NONE = 0,
NORMAL1 = 1,
NORMAL2 = 2,
NORMAL3 = 3,
NORMAL4 = 4,
EXTREME1 = 5,
EXTREME2 = 6,
EXTREME3 = 7,
EXTREME4 = 8,
FAST1 = 9,
FAST2 = 10,
FAST3 = 11,
FAST4 = 12,
SLIGHT1 = 13,
SLIGHT2 = 14,
SLIGHT3 = 15,
SLIGHT4 = 16,
}
}
}:instance{
init= function(self, note)
return self:superinit(note)
end,
methods= function(obj)
function obj:insert(successf, failf)
local ret = VSInsertNoteEx(self:get())
if ret == self.BOOL.TRUE then
self.notyet = nil
end
return self:callRetfunc(ret, successf, failf)
end
function obj:update(successf, failf)
local ret = VSUpdateNoteEx(self:get())
return self:callRetfunc(ret, successf, failf)
end
obj:defineDelegateAccessor{
"bendDepth",
"bendLength",
"decay",
"accent",
"opening",
"vibratoLength",
"vibratoType",
}
function obj:risePort(value)
if value == nil then
return vsutils.toBool(self:get().risePort)
else
self:get().risePort = vsutils.toVSBool(value)
return self
end
end
function obj:fallPort(value)
if value == nil then
return vsutils.toBool(self:get().fallPort)
else
self:get().fallPort = vsutils.toVSBool(value)
return self
end
end
end
}
local function npFilter()
return true
end
local Iterator = VSObject:subobject{
}:instance{
init= function(self)
self:reset()
return self
end,
methods= function(obj)
function obj:each(filterf)
filterf = filterf or npFilter
local function itrnext(self, i)
local o = self:next()
if o == nil then
return
end
if filterf(o) then
i = i + 1
return i, o
else
return itrnext(self, i)
end
end
return itrnext, self, 0
end
end
}
VSWrapper.NoteIterator = Iterator:subobject{
}:instance{
init= function(self)
return self:superinit()
end,
methods= function(obj)
function obj:reset()
VSSeekToBeginNote()
end
function obj:next()
local ret, note = VSGetNextNote()
if ret ~= self.BOOL.TRUE then
return nil
end
return VSWrapper.Note:new(note)
end
function obj:nextEx()
local ret, note = VSGetNextNoteEx()
if ret ~= self.BOOL.TRUE then
return nil
end
return VSWrapper.Note:new(note)
end
end
}
VSWrapper.NoteExIterator = Iterator:subobject{
}:instance{
init= function(self)
return self:superinit()
end,
methods= function(obj)
function obj:reset()
VSSeekToBeginNote()
end
function obj:next()
local ret, note = VSGetNextNoteEx()
if ret ~= self.BOOL.TRUE then
return nil
end
return VSWrapper.NoteEx:new(note)
end
end
}
VSWrapper.Control = MutableRecord:subobject{
init= {
TYPE = CTRL_TYPE,
MAX = {
DYN = 127,
BRE = 127,
BRI = 127,
CLE = 127,
GEN = 127,
PIT = 8191,
PBS = 24,
POR = 127,
},
MIN = {
DYN = 0,
BRE = 0,
BRI = 0,
CLE = 0,
GEN = 0,
PIT = -8192,
PBS = 0,
POR = 0,
},
}
}:instance{
init= function(self, ctrl)
return self:superinit(ctrl)
end,
methods= function(obj)
function obj:insert(successf, failf)
local ret = VSInsertControl(self:get())
if ret == self.BOOL.TRUE then
self.notyet = nil
end
return self:callRetfunc(ret, successf, failf)
end
function obj:update(successf, failf)
local ret = VSUpdateControl(self:get())
return self:callRetfunc(ret, successf, failf)
end
function obj:save(successf, failf)
if self.notyet then
return self:insert(successf, failf)
else
return self:update(successf, failf)
end
end
function obj:remove(successf, failf)
local ret = VSRemoveControl(self:get())
return self:callRetfunc(ret, successf, failf)
end
obj:defineDelegateAccessor{
"posTick",
"value",
"type",
}
end
}
VSWrapper.ControlIterator = Iterator:subobject{
}:instance{
init= function(self, controlType)
self.type = controlType
return self:superinit()
end,
methods= function(obj)
function obj:reset()
VSSeekToBeginControl(self.type)
end
function obj:next()
local ret, control = VSGetNextControl(self.type)
if ret ~= self.BOOL.TRUE then
return nil
end
return VSWrapper.Control:new(control)
end
end
}
VSWrapper.ControlAtTick = VSWrapper.Control:subobject{
}:instance{
init= function(self, ctrl)
return self:superinit(ctrl)
end,
methods= function(obj)
function obj:insert(successf, failf)
return self:update(successf, failf)
end
function obj:update(successf, failf)
return VSWrapper:updateControlAt(
self:type(), self:posTick(), self:value(),
successf, failf)
end
function obj:save(successf, failf)
return self:update(successf, failf)
end
function obj:remove()
end
end
}
local TickStepIterator = Iterator:subobject{
}:instance{
init= function(self, startTick, limitTick, tickStep)
self.startTick = startTick
self.limitTick = limitTick
self.tickStep = tickStep or 1
return self:superinit()
end,
methods= function(obj)
function obj:reset()
self.posTick = self.startTick
end
function obj:next()
if (self.tickStep > 0 and self.posTick <= self.limitTick) 
or (self.tickStep <= 0 and self.posTick >= self.limitTick) then
local var, mes = self:get(self.posTick)
self.posTick = self.posTick + self.tickStep
return var, mes
end
end
function obj:get(posTick)
end
end
}
VSWrapper.ControlAtTickIterator = TickStepIterator:subobject{
}:instance{
init= function(self, controlType, startTick, limitTick, tickStep)
self.type = controlType
return self:superinit(startTick, limitTick, tickStep)
end,
methods= function(obj)
function obj:get(posTick)
return VSWrapper:getControlAt(self.type, posTick)
end
end
}
VSWrapper.ControlsAtTick = MutableRecord:subobject{
}:instance{
init= function(self, ctrl)
self.fieldModified = {}
return self:superinit(ctrl)
end,
methods= function(obj)
function obj:preSetFieldValue(name)
self.fieldModified[name] = true
end
--[[ TODO disable lazy load
function obj:preGetFieldValue(name)
local typ = CTRL_TYPE_MAP[name]
if self:get()[name] == nil then 
self:get()[name] = VSWrapper:getControlAt(typ, self:posTick()):value()
end
end
--]]
obj:defineDelegateAccessor{
"posTick",
"dyn",
"bre",
"bri",
"cle",
"gen",
"pit",
"pbs",
"por",
}
function obj:insert(successf, failf)
return self:update(successf, failf)
end
function obj:update(successf, failf)
local totalret = true
for field, value in pairs(self:get()) do
local controlType = CTRL_TYPE_MAP[field]
if self.fieldModified[field] and controlType then
local ret = VSWrapper:updateControlAt(controlType, self:posTick(), value)
totalret = ret and totalret
end
end
return self:callRetfunc(vsutils.toVSBool(totalret), successf, failf)
end
function obj:save(successf, failf)
return self:update(successf, failf)
end
end
}
VSWrapper.ControlsAtTickIterator = TickStepIterator:subobject{
}:instance{
init= function(self, startTick, limitTick, tickStep)
return self:superinit(startTick, limitTick, tickStep)
end,
methods= function(obj)
function obj:get(posTick)
--[[ TODO disable lazy load
local control = {
posTick = posTick
}
return VSWrapper.ControlsAtTick:new(control)
--]]            
local control = VSWrapper:getControlsAt(posTick)
return control
end
end
}
--[[
local tickConverter
local function modifyTickConvertFunc()
tickConverter = VSWrapper.MusicalPart:new()
toLocalTick = function(globalTick)
return tickConverter:toLocalTick(globalTick)
end
toGlobalTick = function(globalTick)
return tickConverter:toGlobalTick(globalTick)
end
end
local function toLocalTick(globalTick)
modifyTickConvertFunc() 
return toLocalTick(globalTick)
end
local function toGlobalTick(globalTick)
modifyTickConvertFunc() 
return toGlobalTick(globalTick)
end
--]]
VSWrapper.MasterTrack = VSObject:subobject{
}:instance{
methods= function(obj)
function obj:getTempoAt(globalTick)
local ret, tempo = VSGetTempoAt(globalTick)
if ret ~= self.BOOL.TRUE then
error("VSGetTempoAt call failed")
end
return tempo
end
function obj:getTimeSigAt(globalTick)
local ret, num, denom = VSGetTimeSigAt(globalTick)
if ret ~= self.BOOL.TRUE then
error("VSGetTimeSigAt call failed")
end
return num, denom
end
function obj:getBarTickAt(globalTick)
local num, denom = self:getTimeSigAt(globalTick)
if num == nil then
return nil
end
return num * self:resolution() * 4 / denom
end
function obj:sequenceName()
local name = VSGetSequenceName()
return name
end
function obj:sequencePath()
local path = VSGetSequencePath()
return path
end
function obj:resolution()
local res = VSGetResolution()
return res
end
function obj:listTempo(filterf)
return VSWrapper.DataList:newWithIterator(VSWrapper.TempoIterator:new(), filterf)
end
function obj:listTimeSig(filterf)
return VSWrapper.DataList:newWithIterator(VSWrapper.TimeSigIterator:new(), filterf)
end
function obj:eachTempo(filterf)
return VSWrapper.TempoIterator:new():each(filterf)
end
function obj:eachTimeSig(filterf)
return VSWrapper.TimeSigIterator:new():each(filterf)
end
end
}
VSWrapper.Tempo = Record:subobject{
}:instance{
init= function(self, tempo)
return self:superinit(tempo)
end,
methods= function(obj)
obj:defineDelegateGetter{
"posTick",
"tempo",
}
end
}
VSWrapper.TempoIterator = Iterator:subobject{
}:instance{
init= function(self)
return self:superinit()
end,
methods= function(obj)
function obj:reset()
VSSeekToBeginTempo()
end
function obj:next()
local ret, tempo = VSGetNextTempo()
if ret ~= self.BOOL.TRUE then
return nil
end
return VSWrapper.Tempo:new(tempo)
end
end
}
VSWrapper.TimeSig = Record:subobject{
}:instance{
init= function(self, timeSig)
return self:superinit(timeSig)
end,
methods= function(obj)
obj:defineDelegateGetter{
"posTick",
"numerator",
"denominator",
}
function obj:timeSig()
return self:numerator(), self:denominator()
end
end
}
VSWrapper.TimeSigIterator = Iterator:subobject{
}:instance{
init= function(self)
return self:superinit()
end,
methods= function(obj)
function obj:reset()
VSSeekToBeginTimeSig()
end
function obj:next()
local ret, tempo = VSGetNextTimeSig()
if ret ~= self.BOOL.TRUE then
return nil
end
return VSWrapper.TimeSig:new(tempo)
end
end
}
VSWrapper.Singer = Record:subobject{
}:instance{
init= function(self, singer)
return self:superinit(singer)
end,
methods= function(obj)
obj:defineDelegateGetter{
"vBS",
"vPC",
"breathiness",
"brightness",
"clearness",
"genderFactor",
"opening",
"compID",
}
end
}
VSWrapper.MusicalPart = MutableRecord:subobject{
}:instance{
init= function(self)
local ret, part = VSGetMusicalPart()
if ret ~= self.BOOL.TRUE then
error("VSGetMusicalPart call failed")
end
return self:superinit(part)
end,
methods= function(obj)
function obj:singer()
if self.sngr == nil then 
local ret, singer = VSGetMusicalPartSinger()
if ret ~= self.BOOL.TRUE then
error("VSGetMusicalPartSinger call failed")
end
self.sngr = VSWrapper.Singer:new(singer)
end
return self.sngr
end
function obj:update(successf, failf)
local ret = VSUpdateMusicalPart(self:get())
return self:callRetfunc(ret, successf, failf)
end
obj:defineDelegateAccessor{
"posTick",
"playTime",
"durTick",
"name",
"comment",
}
function obj:toLocalTick(globalTick)
return globalTick - self:posTick()
end
function obj:toGlobalTick(posTick)
return posTick + self:posTick()
end
end
}
VSWrapper.WavPart = Record:subobject{
}:instance{
init= function(self, wav)
return self:superinit(wav)
end,
methods= function(obj)
obj:defineDelegateGetter{
"posTick",
"playTime",
"sampleRate",
"sampleReso",
"channels",
"name",
"comment",
"filePath",
}
end
}
VSWrapper.WavParts = VSObject:subobject{
}:instance{
init= function(self)
local ret, stereo = VSGetStereoWAVPart()
if ret ~= self.BOOL.TRUE then
end
local monoList = {}
VSSeekToBeginMonoWAVPart()
local ret, mono = VSGetNextMonoWAVPart()
while ret == self.BOOL.TRUE do
table.insert(monoList, VSWrapper.WavPart:new(mono))
ret, mono = VSGetNextMonoWAVPart()
end
self = {
stereoPart = VSWrapper.WavPart:new(stereo),
monoList = monoList,
}
return self
end,
methods= function(obj)
function obj:stereo()
return self.stereoPart
end
function obj:monos()
return self.monoList
end
end
}
VSWrapper.MsgBox = VSObject:subobject{
init= {
TYPE = {
OK = 0,
OK_CANCEL = 1,
ABORT_RETRY_IGNORE = 2,
YES_NO_CANCEL = 3,
YES_NO = 4,
RETRY_CANCEL = 5,
},
},
methods= function(cls)
local safecall = vsutils.safecall
function cls:show(message, typ)
local ret = VSMessageBox(message, typ)
return VSWrapper.Answer:valueOf(ret)
end
function cls:ok(message, okf)
local ret = self:show(message, self.TYPE.OK)
if ret == VSWrapper.Answer.OK then
safecall(okf)
end
return ret
end
function cls:okCancel(message, okf, cancelf)
local ret = self:show(message, self.TYPE.OK_CANCEL)
if ret == VSWrapper.Answer.OK then
safecall(okf)
elseif ret == VSWrapper.Answer.CANCEL then
safecall(cancelf)
end
return ret
end
function cls:abortRetryIgnore(message, abortf, retryf, ignoref)
local ret = self:show(message, self.TYPE.ABORT_RETRY_IGNORE)
if ret == VSWrapper.Answer.ABORT then
safecall(abortf)
elseif ret == VSWrapper.Answer.RETRY then
safecall(retryf)
elseif ret == VSWrapper.Answer.IGNORE then
safecall(ignoref)
end
return ret
end
function cls:yesNoCancel(message, yesf, nof, cancelf)
local ret = self:show(message, self.TYPE.YES_NO_CANCEL)
if ret == VSWrapper.Answer.YES then
safecall(yesf)
elseif ret == VSWrapper.Answer.NO then
safecall(nof)
elseif ret == VSWrapper.Answer.CANCEL then
safecall(cancelf)
end
return ret
end
function cls:yesNo(message, yesf, nof)
local ret = self:show(message, self.TYPE.YES_NO )
if ret == VSWrapper.Answer.YES then
safecall(yesf)
elseif ret == VSWrapper.Answer.NO then
safecall(nof)
end
return ret
end
function cls:retryCancel(message, retryf, cancelf)
local ret = self:show(message, self.TYPE.RETRY_CANCEL)
if ret == VSWrapper.Answer.RETRY then
safecall(retryf)
elseif ret == VSWrapper.Answer.CANCEL then
safecall(cancelf)
end
return ret
end
end
}
VSWrapper.DataList = VSObject:subobject{
methods= function(cls)
function cls:defineIntervalGetter(fieldNames)
delegate = "data"
for i, name in ipairs(fieldNames) do
local pascal = name:sub(1, 1):upper() .. name:sub(2)
self["getIntervalNext" .. pascal] = function(self)
local n = self:getNext()
local c = self:current()
if n == nil then
return nil
end
return n[name](n) - c[name](c)
end
self["getIntervalPrev" .. pascal] = function(self)
local c = self:current()
local p = self:getPrev()
if p == nil then
return nil
end
return c[name](c) - p[name](p)
end
end
end
function cls:newWithIterator(itr, filterf)
local list = {}
for i, value in itr:each(filterf) do
table.insert(list, value)
end
return self:new(list)
end
end
}:instance{
init= function(self, list)
return {
data = list,
posIdx = 0
}
end,
methods= function(obj)
function obj:reset()
self.posIdx = 0
end
function obj:finish()
self.posIdx = self:count() + 1
end
function obj:next()
if self.posIdx <= self:count() then 
self.posIdx = self.posIdx + 1
end
return self:current()
end
function obj:prev()
if 0 < self.posIdx then 
self.posIdx = self.posIdx - 1
end
return self:current()
end
function obj:current()
return self.data[self.posIdx]
end
function obj:jump(index)
if index < 1 then
self:reset()
return self:current()
elseif self:count() < index then
self:finish()
return self:current()
else
self.posIdx = index
return self:current()
end
end
local function iterator(self, nextf, filterf)
filterf = filterf or npFilter
local function itrnext(self)
local o = self[nextf](self)
if o == nil then
return
end
if filterf(o) then
return self.posIdx, o
else
return itrnext(self)
end
end
return itrnext, self
end
function obj:each(filterf)
return iterator(self, "next", filterf)
end
function obj:reverseEach(filterf)
return iterator(self, "prev", filterf)
end
function obj:getFirst()
return self:get(1)
end
function obj:getLast()
return self:get(self:count())
end
function obj:get(index)
return self.data[index]
end
function obj:getNext()
return self:get(self:currentIndex() + 1)
end
function obj:getPrev()
return self:get(self:currentIndex() - 1)
end
obj:defineIntervalGetter{
"posTick"
}
function obj:currentIndex()
return self.posIdx
end
function obj:count()
return #self.data
end
function obj:insert(index, record)
if index <= self.posIdx then
self.posIdx = self.posIdx + 1
end
table.insert(self.data, index, record)
end
function obj:add(record)
self:insert(self:count() + 1, record)
end
function obj:sublist(filterf)
filterf = filterf or npFilter
local list = {}
for i, value in ipairs(self.data) do
if filterf(value) then
table.insert(list, value)
end
end
return self._class:new(list)
end
function obj:indexOf(record)
for i, value in ipairs(self.data) do
if value == record then
return i
end
end
end
function obj:lastIndexOf(record)
for i, value in vsutils.ipairs(self.data, self:count() + 1, -1) do
if value == record then
return i
end
end
end
end
}
VSWrapper.Filter = vsutils.object{
methods= function(cls)
local function getArgPosTicks(startTick, limitTick)
if type(startTick) == "table" then
return startTick.beginPosTick, startTick.endPosTick
else
return startTick, limitTick
end
end
function cls:posTick(startTick, limitTick)
startTick, limitTick = getArgPosTicks(startTick, limitTick)
if limitTick == nil then
return function(cnd)
return startTick <= cnd:posTick()
end
else
return function(cnd)
return startTick <= cnd:posTick() and cnd:posTick() <= limitTick
end
end
end
function cls:noteTick(startTick, limitTick)
startTick, limitTick = getArgPosTicks(startTick, limitTick)
return function(cnd)
return startTick <= cnd:posTick() and cnd:endPosTick() <= limitTick
end
end
end
}
VSWrapper.NoteDataList = VSWrapper.DataList:subobject{
}:instance{
init= function(self, list)
return self:superinit(list)
end,
methods= function(obj)
function obj:getIntervalNextNoteTick()
local n = self:getNext()
if n == nil then
return nil
end
return n:posTick() - self:current():endPosTick()
end
function obj:getIntervalPrevNoteTick()
local p = self:getPrev()
if p == nil then
return nil
end
return self:current():posTick() - p:endPosTick()
end
obj:defineIntervalGetter{
"noteNum",
}
function obj:isVowelDivPrevPhenomes()
if self:getIntervalPrevNoteTick() == 0 then
local prev = self:getPrev():phonemes()
local prePhoneme = prev[#prev]
local postPhoneme = self:current():phonemes()[1]
if vsutils.isVowel(prePhoneme) and (prePhoneme == postPhoneme or postPhoneme == CONTINUOUS_PHENOM) then
return true
end
end
return false
end
function obj:isVowelDivNextPhenomes()
if self:getIntervalNextNoteTick() == 0 then
local current = self:current():phonemes()
local prePhoneme = current[#current]
local postPhoneme = self:getNext():phonemes()[1]
if vsutils.isVowel(prePhoneme) and (prePhoneme == postPhoneme or postPhoneme == CONTINUOUS_PHENOM) then
return true
end
end
return false
end
end
}
VSWrapper.ControlDataList = VSWrapper.DataList:subobject{
}:instance{
init= function(self, list)
return self:superinit(list)
end,
methods= function(obj)
obj:defineIntervalGetter{
"value",
}
end
}
VSWrapper.ControlsDataList = VSWrapper.DataList:subobject{
}:instance{
init= function(self, list)
return self:superinit(list)
end,
methods= function(obj)
obj:defineIntervalGetter{
"dyn",
"bre",
"bri",
"cle",
"gen",
"pit",
"pbs",
"por",
}
end
}
