pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- this tests a good deal of syntax

-- assert(false)
--[[
    assert(false)
]] x=1
assert(true,1)
assert(x==1,2)
assert("\0\0123\n\t\+\z    \x41\x61"=="\000\x0c\x33\
\9\5Aa") -- (removed newline in \z - pico8 doesn't like it...)
assert("\'\"\\'"==[['"\']],3)
assert([==[]]]==]=="]]",4)
x=1e2e3=1
assert(x==1 and e2e3==1,5)
assert(0xf.f==15.9375 and 0B10.01==2.25,6)
a,b,c=1,{},3
a,b.n,b[1],c=c,2,4,a
assert(a==3 and c==1 and b['n']==2 and b[1]==4,8)
do local a=a+1 assert(a==4,9) 
   local a=a*2 assert(a==8,9.1) end assert(a==3,9.2)
local z=_ENV; assert(z==_ENV,10)
local z; assert(z==nil,11)
function f() return 1,2,3 end
local u,v,w,x,y,z = 0,f()
assert(u==0 and v==1 and w==2 and x==3 and y==nil and z==nil,12)
function f(...) return ... end
assert(f(1,2,3)==1,13)
a,b = (f(1,2)); assert(a==1 and b==nil,14)
a,b = f(1,2),3; assert(a==1 and b==3,15)
assert(pack(f(1,2,nil,3,nil,nil)).n==6,16)
function f(...) return ..., ..., ... end
assert(pack(f(1,2,3)).n == 5,17)
for i=1,3 do assert(select(i,f(1,2,3))==1,18) end
assert(select(4,f(1,2,3))==2,19)
j=0; for i=5,1,-2 do j=1 assert(i==5 or i==3 or i==1,20) end assert(j==1,20.5)
for i=5,1 do assert(false,21) end
j=0; for k,v in ipairs{4,5} do
    assert(k==1 and v==4 or k==2 and v==5,22); j += 1
end
assert(j==2,22.5)
if j==2 then j+=1 else assert(false,23) end assert(j==3,23.5)
if j==2 then assert(false,24) elseif j==3 then j+=1 else assert(false,24.5) end assert(j==4,24.6)
if j==2 then assert(false,25) else j+=1 end assert(j==5,25.5)
if (j==5) j=0;j=1 else assert(false,26)
assert(j==1,27)
if (j==5) assert(false,28) else j=2
assert(j==2,29)
k=1; while (j>0) j-=1 k*=2
assert(k==4 and j==0,30)
while k>0 do k-=1 j+=1 end; assert(j==4 and k==0,31)
while j>0 do j-=1 k+=1 if k==3 then break end end
assert(j==1 and k==3,32)
repeat j+=1; k-=1 until j==1 or j==3
assert(j==3 and k==1,33)
function f() return end; function g() end
assert(f()==nil and pack(f()).n==0,34)
assert(g()==nil and pack(g()).n==0,35)
function h(...) return ... end
a={1,2,a=1;b=2;3;4,[12]=4,h(5,6,nil,8)}
assert(a[1]==1 and a[2]==2 and a[3]==3 and a[4]==4 and a[5]==5 and a[6]==6,36)
assert(a[7]==nil and a[8]==8 and a[--[[member]]'a']==1 and a.b==2 and a[12]==4,37)
function h(...) return {...,} end
do local function h(...) return {...,a=3} end
   assert(#h(1,2)==1 and h(1,2).a==3,38) end
assert(#h(1,2)==2,39)
assert(1+4*5==21 and 0x1f2&0xff<<4==0x1f0,40)
assert((1+4)*5==25 and (0x1f2&0xff)<<4==0xf20,41)
assert(-2^4==-16 and (-2)^4==16,42)
assert(1!=2 and 1~=2 or assert(false,43),43.1)
x={f=function(u) return u.z end,z=3}
assert(x:f()==3 and x.f{z=4}==4,44)
setmetatable(x,{__index=function(o,k) return k end})
assert(x.boo==--[[member]]"boo",45)
x.g=x
function x.g.g.z(x) return x end; assert(x.z(false)==false,46)
function x.g.g:zoo(x) return self,x end
assert(x:zoo(true)==x and select(2,x:zoo(true))==true,47)
do u=1 do ::x:: u += 1
  if (u==4) goto e
goto x end ::e:: assert(u==4,48) end
do ::y:: do goto y assert(false,49) ::y:: end end
u=0; for k,v in next, {5} do assert(k==1 and v==5,50); u+=1 end
assert(u==1,50.5)
do local oldadd, _ENV = add, {--[[global]]assert=assert}
  oldadd(_ENV, 3) assert(_ENV[1] == 3,51) end -- removed add=nil check as not true in pico8 due to global-as-local inclusion
local function o(k) _ENV=k end
local oldenv = _ENV
o({--[[global]]assert=assert,--[[global]]uvw=123}) assert(uvw==123,52) o(oldenv)
function f() return 9,0,1 end
function s(f) return f() end
function r(f) return (f()) end
assert(pack(s(f)).n == 3 and pack(r(f)).n == 1,53)
u=72;u-=4*2;u<<>=16;assert(u==0x.0040,54)
if u<1 then
if (u==0) u=123
else u=321 end
assert(u==0x.0040,55)
do local zoom = 1; function zoom() end end
assert(zoom==nil,56)
u=1; repeat local u=2 until assert(u==2,57)
local function f() return 3 end
assert(-f() + f() == 0,58)
local function ff() return f end
assert(ff()() == 3,59)
local function roo(a,i) local f = function () a += 1; return a end
  if i and i > 0 then return f,roo(a*2,i-1) else return f end end
local r,s,t1,t2 = roo(10),roo(20),roo(30,1)
assert(r()==11 and s()==21 and roo(0)()==1 and t1()==31 and t2()==61
  and r()==12 and s()==22 and roo(0)()==1 and t1()==32 and t2()==62, 60)
function uu(s) return s end
assert(uu"me" == "me" and uu[[me]] == "me", 61)
uo = {uu=function(m,s) return s end}
assert(uo:uu"me" == "me" and #uo:uu{} == 0, 62)
do while true do if 1==1 then ::zoo:: end goto zoo end ::zoo:: end
local a=1 function spa() return a end
local a=2 assert(spa()==1, 63)
local b=1 do function spb() return b end
local b=2 assert(spb()==1, 64) end
do local i,c = 1,2 ::_1:: assert(c==2, 65);
   if (i>1) assert(fff()==4 and c==2, 66) goto out
   local c=3; fff = function () c += 1 return c end
   i+=1 goto _1
end ::out::
do local i=1 ::_1:: local x=i ff=fff fff=function() x += 1 return x end
  i+=1 if(i==3) goto out2 else goto _1
end ::out2::
assert(fff()==3 and fff()==4 and ff()==2 and fff()==5 and ff()==3,67)
do goto foo local bah ::foo::;; end
if (1==1);
local o=0 function ord(i,ret) assert(o==i,68); o+=1; return ret end
local res = {}; ord(0,res).x, ord(1,res).x = ord(2,2), ord(3,function() return 3 end) (ord(4,1), ord(5,1))
assert(res.x==2,69)
local a,a = 1,2
assert(a==2,70)
function f(a,a) assert(a==2,71)end f(1,2)
print("DONE")

__gfx__
dcf6c3968fc4f9d8632d39e67f3953076b48f7b7a87b8f3a1c7d3c647677c0aa345a17500639192c448e3ae773c1ef4b9b8ced74657b1a43f0d23d321a0ad40a
4c49a63747ffeabf17d2d2b36f4ee65c129fbbb1663d2dc2ab0daefb2326aec74f6acf74d9ab50d107f004901073e9cfa89bf6908d49a65e45a6804661ba5179
000e0a00e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000e0a00e00020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
7abd0b061b85dc7a3d47cae943ce8effc7516254f412bd5cfe0ccd4857697bd16a75fa3860d4b836040c9d134e2c4816dd157b192c7815d386d6a9838d997b68f1082175bcdb96c6dcac0476ff502de82a4c22f317e3e8f3fe2133ce4bdd5d16be563ae2414cbb4f6df414c07c602ff7d6836f48be07f9c16da0b3a334de4848
__gff__
aa52cccc84159c6328341bff1000c7ebefa69980293c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
123000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004
__music__
07 12345678
00 00000000
00 00000000
