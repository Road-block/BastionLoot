-- $Id: utf8.lua 179 2009-04-03 18:10:03Z pasta $
--
-- Provides UTF-8 aware string functions implemented in pure lua:
-- * string.utf8len(s)
-- * string.utf8sub(s, i, j)
-- * string.utf8reverse(s)
-- * string.utf8char(unicode)
-- * string.utf8unicode(s, i, j)
-- * string.utf8gensub(s, sub_len)
-- * string.utf8find(str, regex, init, plain)
-- * string.utf8match(str, regex, init)
-- * string.utf8gmatch(str, regex, all)
-- * string.utf8gsub(str, regex, repl, limit)
--
-- If utf8data.lua (containing the lower<->upper case mappings) is loaded, these
-- additional functions are available:
-- * utf8upper(s)
-- * utf8lower(s)
--
-- All functions behave as their non UTF-8 aware counterparts with the exception
-- that UTF-8 characters are used instead of bytes for all units.

--[[
Copyright (c) 2006-2007, Kyle Smith
All rights reserved.

Contributors:
	Alimov Stepan

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the author nor the names of its contributors may be
      used to endorse or promote products derived from this software without
      specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]

-- ABNF from RFC 3629
--
-- UTF8-octets = *( UTF8-char )
-- UTF8-char   = UTF8-1 / UTF8-2 / UTF8-3 / UTF8-4
-- UTF8-1      = %x00-7F
-- UTF8-2      = %xC2-DF UTF8-tail
-- UTF8-3      = %xE0 %xA0-BF UTF8-tail / %xE1-EC 2( UTF8-tail ) /
--               %xED %x80-9F UTF8-tail / %xEE-EF 2( UTF8-tail )
-- UTF8-4      = %xF0 %x90-BF 2( UTF8-tail ) / %xF1-F3 3( UTF8-tail ) /
--               %xF4 %x80-8F 2( UTF8-tail )
-- UTF8-tail   = %x80-BF
--

local byte    = string.byte
local char    = string.char
local find    = string.find
local format  = string.format
local len     = string.len
local lower   = string.lower
local rep     = string.rep
local sub     = string.sub
local upper   = string.upper
local gsub    = string.gsub
local tinsert = table.insert
local tremove = table.remove
local tsort   = table.sort
local floor   = math.floor

local utf8charpattern = '[%z\1-\127\194-\244][\128-\191]*'

local function utf8symbollen(byte)
  return not byte and 0 or (byte < 0x80 and 1) or (byte >= 0xF0 and 4) or (byte >= 0xE0 and 3) or (byte >= 0xC0 and 2) or 1
end

local head_table = {}
for i = 0, 255 do
  head_table[i] = utf8symbollen(i)
end
head_table[256] = 0

local function utf8charbytes(str, bs)
  return head_table[byte(str, bs) or 256]
end

local function utf8next(str, bs)
  return bs + utf8charbytes(str, bs)
end

-- returns the number of characters in a UTF-8 string
local function utf8len (str)
  local bs = 1
  local bytes = len(str)
  local length = 0

  while bs <= bytes do
    length = length + 1
    bs = utf8next(str, bs)
  end

  return length
end

-- functions identically to string.sub except that i and j are UTF-8 characters
-- instead of bytes
local function utf8sub (s, i, j)
  -- argument defaults
  j = j or -1

  local bs = 1
  local bytes = len(s)
  local length = 0

  local l = (i >= 0 and j >= 0) or utf8len(s)
  i = (i >= 0) and i or l + i + 1
  j = (j >= 0) and j or l + j + 1

  if i > j then
    return ""
  end

  local start, finish = 1, bytes

  while bs <= bytes do
    length = length + 1

    if length == i then
      start = bs
    end

    bs = utf8next(s, bs)

    if length == j then
      finish = bs - 1
      break
    end
  end

  if i > length then start = bytes + 1 end
  if j < 1 then finish = 0 end

  return sub(s, start, finish)
end

-- http://en.wikipedia.org/wiki/Utf8
-- http://developer.coronalabs.com/code/utf-8-conversion-utility
local function utf8char(...)
  local codes = {...}
  local result = {}

  for _, unicode in ipairs(codes) do

    if unicode <= 0x7F then
      result[#result + 1] = unicode
    elseif unicode <= 0x7FF then
      local b0 = 0xC0 + floor(unicode / 0x40);
      local b1 = 0x80 + (unicode % 0x40);
      result[#result + 1] = b0
      result[#result + 1] = b1
    elseif unicode <= 0xFFFF then
      local b0 = 0xE0 +  floor(unicode / 0x1000);
      local b1 = 0x80 + (floor(unicode / 0x40) % 0x40);
      local b2 = 0x80 + (unicode % 0x40);
      result[#result + 1] = b0
      result[#result + 1] = b1
      result[#result + 1] = b2
    elseif unicode <= 0x10FFFF then
      local code = unicode
      local b3= 0x80 + (code % 0x40);
      code       = floor(code / 0x40)
      local b2= 0x80 + (code % 0x40);
      code       = floor(code / 0x40)
      local b1= 0x80 + (code % 0x40);
      code       = floor(code / 0x40)
      local b0= 0xF0 + code;

      result[#result + 1] = b0
      result[#result + 1] = b1
      result[#result + 1] = b2
      result[#result + 1] = b3
    else
      error 'Unicode cannot be greater than U+10FFFF!'
    end

  end

  return char(unpack(result))
end


local shift_6  = 2^6
local shift_12 = 2^12
local shift_18 = 2^18

local utf8unicode
utf8unicode = function(str, ibs, jbs)
  if ibs > jbs then return end

  local ch,bytes

  bytes = utf8charbytes(str, ibs)
  if bytes == 0 then return end

  local unicode

  if bytes == 1 then unicode = byte(str, ibs, ibs) end
  if bytes == 2 then
    local byte0,byte1 = byte(str, ibs, ibs + 1)
    if byte0 and byte1 then
      local code0,code1 = byte0-0xC0,byte1-0x80
      unicode = code0*shift_6 + code1
    else
      unicode = byte0
    end
  end
  if bytes == 3 then
    local byte0,byte1,byte2 = byte(str, ibs, ibs + 2)
    if byte0 and byte1 and byte2 then
      local code0,code1,code2 = byte0-0xE0,byte1-0x80,byte2-0x80
      unicode = code0*shift_12 + code1*shift_6 + code2
    else
      unicode = byte0
    end
  end
  if bytes == 4 then
    local byte0,byte1,byte2,byte3 = byte(str, ibs, ibs + 3)
    if byte0 and byte1 and byte2 and byte3 then
      local code0,code1,code2,code3 = byte0-0xF0,byte1-0x80,byte2-0x80,byte3-0x80
      unicode = code0*shift_18 + code1*shift_12 + code2*shift_6 + code3
    else
      unicode = byte0
    end
  end

  if ibs == jbs then
    return unicode
  else
    return unicode,utf8unicode(str, ibs+bytes, jbs)
  end
end

local function utf8byte(str, i, j)
  if #str == 0 then return end

  local ibs, jbs

  if i or j then
    i = i or 1
    j = j or i

    local str_len = utf8len(str)
    i = i < 0 and str_len + i + 1 or i
    j = j < 0 and str_len + j + 1 or j
    j = j > str_len and str_len or j

    if i > j then return end

    for p = 1, i - 1 do
      ibs = utf8next(str, ibs or 1)
    end

    if i == j then
      jbs = ibs
    else
      for p = 1, j - 1 do
        jbs = utf8next(str, jbs or 1)
      end
    end

    if not ibs or not jbs then
      return nil
    end
  else
    ibs, jbs = 1, 1
  end

  return utf8unicode(str, ibs, jbs)
end

local function utf8gensub(str, sub_len)
  sub_len = sub_len or 1
  local max_len = #str
  return function(skip_ptr, bs)
    bs = (bs and bs or 1) + (skip_ptr and (skip_ptr[1] or 0) or 0)

    local nbs = bs
    if bs > max_len then return nil end
    for i = 1, sub_len do
      nbs = utf8next(str, nbs)
    end

    return nbs, sub(str, bs, nbs - 1), bs
  end
end

local function utf8reverse (s)
  local result = ''
  for _, w in utf8gensub(s) do result = w .. result end
  return result
end

local function utf8validator(str, bs)
  bs = bs or 1

  if type(str) ~= "string" then
    error("bad argument #1 to 'utf8charbytes' (string expected, got ".. type(str).. ")")
  end
  if type(bs) ~= "number" then
    error("bad argument #2 to 'utf8charbytes' (number expected, got ".. type(bs).. ")")
  end

  local c = byte(str, bs)
  if not c then return end

  -- determine bytes needed for character, based on RFC 3629

  -- UTF8-1
  if c >= 0 and c <= 127 then
    return bs + 1
  elseif c >= 128 and c <= 193 then
    return bs + 1, bs, 1, c
      -- UTF8-2
  elseif c >= 194 and c <= 223 then
    local c2 = byte(str, bs + 1)
    if not c2 or c2 < 128 or c2 > 191 then
      return bs + 2, bs, 2, c2
    end

    return bs + 2
      -- UTF8-3
  elseif c >= 224 and c <= 239 then
    local c2 = byte(str, bs + 1)

    if not c2 then
      return bs + 2, bs, 2, c2
    end

    -- validate byte 2
    if c == 224 and (c2 < 160 or c2 > 191) then
      return bs + 2, bs, 2, c2
    elseif c == 237 and (c2 < 128 or c2 > 159) then
      return bs + 2, bs, 2, c2
    elseif c2 < 128 or c2 > 191 then
      return bs + 2, bs, 2, c2
    end

    local c3 = byte(str, bs + 2)
    if not c3 or c3 < 128 or c3 > 191 then
      return bs + 3, bs, 3, c3
    end

    return bs + 3
      -- UTF8-4
  elseif c >= 240 and c <= 244 then
    local c2 = byte(str, bs + 1)

    if not c2 then
      return bs + 2, bs, 2, c2
    end

    -- validate byte 2
    if c == 240 and (c2 < 144 or c2 > 191) then
      return bs + 2, bs, 2, c2
    elseif c == 244 and (c2 < 128 or c2 > 143) then
      return bs + 2, bs, 2, c2
    elseif c2 < 128 or c2 > 191 then
      return bs + 2, bs, 2, c2
    end

    local c3 = byte(str, bs + 2)
    if not c3 or c3 < 128 or c3 > 191 then
      return bs + 3, bs, 3, c3
    end

    local c4 = byte(str, bs + 3)
    if not c4 or c4 < 128 or c4 > 191 then
      return bs + 4, bs, 4, c4
    end

    return bs + 4
  else -- c > 245
    return bs + 1, bs, 1, c
  end
end

local function utf8validate(str, byte_pos)
  local result = {}
  for nbs, bs, part, code in utf8validator, str, byte_pos do
    if bs then
      result[#result + 1] = { pos = bs, part = part, code = code }
    end
  end
  return #result == 0, result
end

local function utf8codes(str)
  local max_len = #str
  local bs = 1
  return function(skip_ptr)
    if bs > max_len then return nil end
    local pbs = bs
    bs = utf8next(str, pbs)

    return pbs, utf8unicode(str, pbs, pbs), pbs
  end
end


--[[--
differs from Lua 5.3 utf8.offset in accepting any byte positions (not only head byte) for all n values

h - head, c - continuation, t - tail
hhhccthccthccthcthhh
        ^ start byte pos
searching current charracter head by moving backwards
hhhccthccthccthcthhh
      ^ head

n == 0: current position
n > 0: n jumps forward
n < 0: n more scans backwards
--]]--
local function utf8offset(str, n, bs)
  local l = #str
  if not bs then
    if n < 0 then
      bs = l + 1
    else
      bs = 1
    end
  end
  if bs <= 0 or bs > l + 1 then
    error("bad argument #3 to 'offset' (position out of range)")
  end

  if n == 0 then
    if bs == l + 1 then
      return bs
    end
    while true do
      local b = byte(str, bs)
      if (0 < b and b < 127)
      or (194 < b and b < 244) then
        return bs
      end
      bs = bs - 1
      if bs < 1 then
        return
      end
    end
  elseif n < 0 then
    bs = bs - 1
    repeat
      if bs < 1 then
        return
      end

      local b = byte(str, bs)
      if (0 < b and b < 127)
      or (194 < b and b < 244) then
        n = n + 1
      end
      bs = bs - 1
    until n == 0
    return bs + 1
  else
    while true do
      if bs > l then
        return
      end

      local b = byte(str, bs)
      if (0 < b and b < 127)
      or (194 < b and b < 244) then
        n = n - 1
        for i = 1, n do
          if bs > l then
            return
          end
          bs = utf8next(str, bs)
        end
        return bs
      end
      bs = bs - 1
    end
  end

end

local function binsearch(sortedTable, item, comp)
  local head, tail = 1, #sortedTable
  local mid = floor((head + tail) / 2)
  if not comp then
    while (tail - head) > 1 do
      if sortedTable[tonumber(mid)] > item then
        tail = mid
      else
        head = mid
      end
      mid = floor((head + tail) / 2)
    end
  end
  if sortedTable[tonumber(head)] == item then
    return true, tonumber(head)
  elseif sortedTable[tonumber(tail)] == item then
    return true, tonumber(tail)
  else
    return false
  end
end
local function classMatchGenerator(class, plain)
  local codes = {}
  local ranges = {}
  local ignore = false
  local range = false
  local firstletter = true
  local unmatch = false

  local it = utf8gensub(class)

  local skip
  for c, _, be in it do
    skip = be
    if not ignore and not plain then
      if c == "%" then
        ignore = true
      elseif c == "-" then
        tinsert(codes, utf8unicode(c))
        range = true
      elseif c == "^" then
        if not firstletter then
          error("!!!")
        else
          unmatch = true
        end
      elseif c == "]" then
        break
      else
        if not range then
          tinsert(codes, utf8unicode(c))
        else
          tremove(codes) -- removing '-'
          tinsert(ranges, {tremove(codes), utf8unicode(c)})
          range = false
        end
      end
    elseif ignore and not plain then
      if c == "a" then -- %a: represents all letters. (ONLY ASCII)
        tinsert(ranges, {65, 90}) -- A - Z
        tinsert(ranges, {97, 122}) -- a - z
      elseif c == "c" then -- %c: represents all control characters.
        tinsert(ranges, {0, 31})
        tinsert(codes, 127)
      elseif c == "d" then -- %d: represents all digits.
        tinsert(ranges, {48, 57}) -- 0 - 9
      elseif c == "g" then -- %g: represents all printable characters except space.
        tinsert(ranges, {1, 8})
        tinsert(ranges, {14, 31})
        tinsert(ranges, {33, 132})
        tinsert(ranges, {134, 159})
        tinsert(ranges, {161, 5759})
        tinsert(ranges, {5761, 8191})
        tinsert(ranges, {8203, 8231})
        tinsert(ranges, {8234, 8238})
        tinsert(ranges, {8240, 8286})
        tinsert(ranges, {8288, 12287})
      elseif c == "l" then -- %l: represents all lowercase letters. (ONLY ASCII)
        tinsert(ranges, {97, 122}) -- a - z
      elseif c == "p" then -- %p: represents all punctuation characters. (ONLY ASCII)
        tinsert(ranges, {33, 47})
        tinsert(ranges, {58, 64})
        tinsert(ranges, {91, 96})
        tinsert(ranges, {123, 126})
      elseif c == "s" then -- %s: represents all space characters.
        tinsert(ranges, {9, 13})
        tinsert(codes, 32)
        tinsert(codes, 133)
        tinsert(codes, 160)
        tinsert(codes, 5760)
        tinsert(ranges, {8192, 8202})
        tinsert(codes, 8232)
        tinsert(codes, 8233)
        tinsert(codes, 8239)
        tinsert(codes, 8287)
        tinsert(codes, 12288)
      elseif c == "u" then -- %u: represents all uppercase letters. (ONLY ASCII)
        tinsert(ranges, {65, 90}) -- A - Z
      elseif c == "w" then -- %w: represents all alphanumeric characters. (ONLY ASCII)
        tinsert(ranges, {48, 57}) -- 0 - 9
        tinsert(ranges, {65, 90}) -- A - Z
        tinsert(ranges, {97, 122}) -- a - z
      elseif c == "x" then -- %x: represents all hexadecimal digits.
        tinsert(ranges, {48, 57}) -- 0 - 9
        tinsert(ranges, {65, 70}) -- A - F
        tinsert(ranges, {97, 102}) -- a - f
      else
        if not range then
          tinsert(codes, utf8unicode(c))
        else
          tremove(codes) -- removing '-'
          tinsert(ranges, {tremove(codes), utf8unicode(c)})
          range = false
        end
      end
      ignore = false
    else
      if not range then
        tinsert(codes, utf8unicode(c))
      else
        tremove(codes) -- removing '-'
        tinsert(ranges, {tremove(codes), utf8unicode(c)})
        range = false
      end
      ignore = false
    end

    firstletter = false
  end

  tsort(codes)

  local function inRanges(charCode)
    for _, r in ipairs(ranges) do
      if r[1] <= charCode and charCode <= r[2] then
        return true
      end
    end
    return false
  end
  if not unmatch then
    return function(charCode)
      return binsearch(codes, charCode) or inRanges(charCode)
    end, skip
  else
    return function(charCode)
      return charCode ~= -1 and not (binsearch(codes, charCode) or inRanges(charCode))
    end, skip
  end
end

local cache = setmetatable({},{__mode = "kv"})
local cachePlain = setmetatable({},{__mode = "kv"})
local function matcherGenerator(regex, plain)
  local matcher = {
    functions = {},
    captures = {}
  }
  if not plain then
    cache[regex] = matcher
  else
    cachePlain[regex] = matcher
  end
  local function simple(func)
    return function(cC)
      if func(cC) then
        matcher:nextFunc()
        matcher:nextStr()
      else
        matcher:reset()
      end
    end
  end
  local function star(func)
    return function(cC)
      if func(cC) then
        matcher:fullResetOnNextFunc()
        matcher:nextStr()
      else
        matcher:nextFunc()
      end
    end
  end
  local function minus(func)
    return function(cC)
      if func(cC) then
        matcher:fullResetOnNextStr()
      end
      matcher:nextFunc()
    end
  end
  local function question(func)
    return function(cC)
      if func(cC) then
        matcher:fullResetOnNextFunc()
        matcher:nextStr()
      end
      matcher:nextFunc()
    end
  end

  local function capture(id)
    return function(_)
      local l = matcher.captures[id][2] - matcher.captures[id][1]
      local captured = utf8sub(matcher.string, matcher.captures[id][1], matcher.captures[id][2])
      local check = utf8sub(matcher.string, matcher.str, matcher.str + l)
      if captured == check then
        for _ = 0, l do
          matcher:nextStr()
        end
        matcher:nextFunc()
      else
        matcher:reset()
      end
    end
  end
  local function captureStart(id)
    return function(_)
      matcher.captures[id][1] = matcher.str
      matcher:nextFunc()
    end
  end
  local function captureStop(id)
    return function(_)
      matcher.captures[id][2] = matcher.str - 1
      matcher:nextFunc()
    end
  end

  local function balancer(str)
    local sum = 0
    local bc, ec = utf8sub(str, 1, 1), utf8sub(str, 2, 2)
    local skip = len(bc) + len(ec)
    bc, ec = utf8unicode(bc), utf8unicode(ec)
    return function(cC)
      if cC == ec and sum > 0 then
        sum = sum - 1
        if sum == 0 then
          matcher:nextFunc()
        end
        matcher:nextStr()
      elseif cC == bc then
        sum = sum + 1
        matcher:nextStr()
      else
        if sum == 0 or cC == -1 then
          sum = 0
          matcher:reset()
        else
          matcher:nextStr()
        end
      end
    end, skip
  end

  matcher.functions[1] = function(_)
    matcher:fullResetOnNextStr()
    matcher.seqStart = matcher.str
    matcher:nextFunc()
    if (matcher.str > matcher.startStr and matcher.fromStart) or matcher.str >= matcher.stringLen then
      matcher.stop = true
      matcher.seqStart = nil
    end
  end

  local lastFunc
  local ignore = false
  local skip = nil
  local it = (function()
    local gen = utf8gensub(regex)
    return function()
      return gen(skip)
    end
  end)()
  local cs = {}
  for c, bs, be in it do
    skip = nil
    if plain then
      tinsert(matcher.functions, simple(classMatchGenerator(c, plain)))
    else
      if ignore then
        if find("123456789", c, 1, true) then
          if lastFunc then
            tinsert(matcher.functions, simple(lastFunc))
            lastFunc = nil
          end
          tinsert(matcher.functions, capture(tonumber(c)))
        elseif c == "b" then
          if lastFunc then
            tinsert(matcher.functions, simple(lastFunc))
            lastFunc = nil
          end
          local b
          b, skip = balancer(sub(regex, be + 1, be + 9))
          tinsert(matcher.functions, b)
        else
          lastFunc = classMatchGenerator("%" .. c)
        end
        ignore = false
      else
        if c == "*" then
          if lastFunc then
            tinsert(matcher.functions, star(lastFunc))
            lastFunc = nil
          else
            error("invalid regex after " .. sub(regex, 1, bs))
          end
        elseif c == "+" then
          if lastFunc then
            tinsert(matcher.functions, simple(lastFunc))
            tinsert(matcher.functions, star(lastFunc))
            lastFunc = nil
          else
            error("invalid regex after " .. sub(regex, 1, bs))
          end
        elseif c == "-" then
          if lastFunc then
            tinsert(matcher.functions, minus(lastFunc))
            lastFunc = nil
          else
            error("invalid regex after " .. sub(regex, 1, bs))
          end
        elseif c == "?" then
          if lastFunc then
            tinsert(matcher.functions, question(lastFunc))
            lastFunc = nil
          else
            error("invalid regex after " .. sub(regex, 1, bs))
          end
        elseif c == "^" then
          if bs == 1 then
            matcher.fromStart = true
          else
            error("invalid regex after " .. sub(regex, 1, bs))
          end
        elseif c == "$" then
          if be == len(regex) then
            matcher.toEnd = true
          else
            error("invalid regex after " .. sub(regex, 1, bs))
          end
        elseif c == "[" then
          if lastFunc then
            tinsert(matcher.functions, simple(lastFunc))
          end
          lastFunc, skip = classMatchGenerator(sub(regex, be + 1))
        elseif c == "(" then
          if lastFunc then
            tinsert(matcher.functions, simple(lastFunc))
            lastFunc = nil
          end
          tinsert(matcher.captures, {})
          tinsert(cs, #matcher.captures)
          tinsert(matcher.functions, captureStart(cs[#cs]))
          if sub(regex, be + 1, be + 1) == ")" then
            matcher.captures[#matcher.captures].empty = true
          end
        elseif c == ")" then
          if lastFunc then
            tinsert(matcher.functions, simple(lastFunc))
            lastFunc = nil
          end
          local cap = tremove(cs)
          if not cap then
            error('invalid capture: "(" missing')
          end
          tinsert(matcher.functions, captureStop(cap))
        elseif c == "." then
          if lastFunc then
            tinsert(matcher.functions, simple(lastFunc))
          end
          lastFunc = function(cC)
            return cC ~= -1
          end
        elseif c == "%" then
          ignore = true
        else
          if lastFunc then
            tinsert(matcher.functions, simple(lastFunc))
          end
          lastFunc = classMatchGenerator(c)
        end
      end
    end
  end
  if #cs > 0 then
    error('invalid capture: ")" missing')
  end
  if lastFunc then
    tinsert(matcher.functions, simple(lastFunc))
  end

  tinsert(
    matcher.functions,
    function()
      if matcher.toEnd and matcher.str ~= matcher.stringLen then
        matcher:reset()
      else
        matcher.stop = true
      end
    end
  )

  matcher.nextFunc = function(self)
    self.func = self.func + 1
  end
  matcher.nextStr = function(self)
    self.str = self.str + 1
  end
  matcher.strReset = function(self)
    local oldReset = self.reset
    local str = self.str
    self.reset = function(s)
      s.str = str
      s.reset = oldReset
    end
  end
  matcher.fullResetOnNextFunc = function(self)
    local oldReset = self.reset
    local func = self.func + 1
    local str = self.str
    self.reset = function(s)
      s.func = func
      s.str = str
      s.reset = oldReset
    end
  end
  matcher.fullResetOnNextStr = function(self)
    local oldReset = self.reset
    local str = self.str + 1
    local func = self.func
    self.reset = function(s)
      s.func = func
      s.str = str
      s.reset = oldReset
    end
  end

  matcher.process = function(self, str, start)
    self.func = 1
    start = start or 1
    self.startStr = (start >= 0) and start or utf8len(str) + start + 1
    self.seqStart = self.startStr
    self.str = self.startStr
    self.stringLen = utf8len(str) + 1
    self.string = str
    self.stop = false

    self.reset = function(s)
      s.func = 1
    end

    local ch
    while not self.stop do
      if self.str < self.stringLen then
        ch = utf8sub(str, self.str, self.str)
        self.functions[self.func](utf8unicode(ch))
      else
        self.functions[self.func](-1)
      end
    end

    if self.seqStart then
      local captures = {}
      for _, pair in pairs(self.captures) do
        if pair.empty then
          tinsert(captures, pair[1])
        else
          tinsert(captures, utf8sub(str, pair[1], pair[2]))
        end
      end
      return self.seqStart, self.str - 1, unpack(captures)
    end
  end

  return matcher
end

local function utf8find(str, regex, init, plain)
  local matcher = cache[regex] or matcherGenerator(regex, plain)
  return matcher:process(str, init)
end

local function utf8match(str, regex, init)
  init = init or 1
  local found = {utf8find(str, regex, init)}
  if found[1] then
    if found[3] then
      return unpack(found, 3)
    end
    return utf8sub(str, found[1], found[2])
  end
end

local function utf8gmatch(str, regex, all)
  regex = (utf8sub(regex, 1, 1) ~= "^") and regex or "%" .. regex
  local lastChar = 1
  return function()
    local found = {utf8find(str, regex, lastChar)}
    if found[1] then
      lastChar = found[2] + 1
      if found[all and 1 or 3] then
        return unpack(found, all and 1 or 3)
      end
      return utf8sub(str, found[1], found[2])
    end
  end
end

local function replace(repl, args)
  local ret = ""
  if type(repl) == "string" then
    local ignore = false
    local num
    for c in utf8gensub(repl) do
      if not ignore then
        if c == "%" then
          ignore = true
        else
          ret = ret .. c
        end
      else
        num = tonumber(c)
        if num then
          ret = ret .. args[num]
        else
          ret = ret .. c
        end
        ignore = false
      end
    end
  elseif type(repl) == "table" then
    ret = repl[args[1] or args[0]] or ""
  elseif type(repl) == "function" then
    if #args > 0 then
      ret = repl(unpack(args, 1)) or ""
    else
      ret = repl(args[0]) or ""
    end
  end
  return ret
end

local function utf8gsub(str, regex, repl, limit)
  limit = limit or -1
  local ret = ""
  local prevEnd = 1
  local it = utf8gmatch(str, regex, true)
  local found = {it()}
  local n = 0
  while #found > 0 and limit ~= n do
    local args = {[0] = utf8sub(str, found[1], found[2]), unpack(found, 3)}
    ret = ret .. utf8sub(str, prevEnd, found[1] - 1) .. replace(repl, args)
    prevEnd = found[2] + 1
    n = n + 1
    found = {it()}
  end
  return ret .. utf8sub(str, prevEnd), n
end

local function utf8replace (s, mapping)
  if type(s) ~= "string" then
    error("bad argument #1 to 'utf8replace' (string expected, got ".. type(s).. ")")
  end
  if type(mapping) ~= "table" then
    error("bad argument #2 to 'utf8replace' (table expected, got ".. type(mapping).. ")")
  end
  local result = gsub( s, utf8charpattern, mapping )
  return result
end

local function utf8upper (s)
  return utf8replace(s, utf8_lc_uc)
end

local function utf8lower (s)
  return utf8replace(s, utf8_uc_lc)
end

if not string.utf8len then
  string.utf8len = utf8len
end
if not string.utf8sub then
  string.utf8sub = utf8sub
end
if not string.utf8reverse then
  string.utf8reverse = utf8reverse
end
if not string.utf8char then
  string.utf8char = utf8char
end
if not string.utf8unicode then
  string.utf8unicode = utf8unicode
end
if not string.utf8byte then
  string.utf8byte = utf8byte
end
if not string.utf8gensub then
  string.utf8gensub = utf8gensub
end
if not string.utf8find then
  string.utf8find = utf8find
end
if not string.utf8match then
  string.utf8match = utf8match
end
if not string.utf8gmatch then
  string.utf8gmatch = utf8gmatch
end
if not string.utf8gsub then
  string.utf8gsub = utf8gsub
end
if utf8_lc_uc and not string.utf8upper then
  string.utf8upper = utf8upper
end
if utf8_uc_lc and not string.utf8lower then
  string.utf8lower = utf8lower
end
