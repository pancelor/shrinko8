pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
n=1assert(true,1)assert(n==1,2)assert("\0ᶜ3\n	⁵Aa"=="\0ᶜ3\n	⁵Aa",2.5)assert("'\"\\'"==[['"\']],3)assert([=[]]]=]=="]]",4)n=1d=1assert(n==1and d==1,5)assert(0xf.f==0xf.f and 2.25==2.25,6)i,c,e=1,{},3i,c.n,c[1],e=e,2,4,i assert(i==3and e==1and c["n"]==2and c[1]==4,8)do local n=i+1assert(n==4,9)local n=n*2assert(n==8,9.1)end assert(i==3,9.2)local n=_ENV assert(n==_ENV,10)local n assert(n==nil,11)function r()return 1,2,3end local n,d,o,e,l,a=0,r()assert(n==0and d==1and o==2and e==3and l==nil and a==nil,12)function r(...)return...end assert(r(1,2,3)==1,13)i,c=(r(1,2))assert(i==1and c==nil,14)i,c=r(1,2),3assert(i==1and c==3,15)assert(pack(r(1,2,nil,3,nil,nil)).n==6,16)function r(...)return...,...,...end assert(pack(r(1,2,3)).n==5,17)for n=1,3do assert(select(n,r(1,2,3))==1,18)end assert(select(4,r(1,2,3))==2,19)f=0for n=5,1,-2do f=1assert(n==5or n==3or n==1,20)end assert(f==1,20.5)for n=5,1do assert(false,21)end f=0for n,e in ipairs{4,5}do assert(n==1and e==4or n==2and e==5,22)f+=1end assert(f==2,22.5)if f==2then f+=1else assert(false,23)end assert(f==3,23.5)if f==2then assert(false,24)elseif f==3then f+=1else assert(false,24.5)end assert(f==4,24.6)if f==2then assert(false,25)else f+=1end assert(f==5,25.5)if f==2do assert(false,25.8)else f+=1end assert(f==6,25.9)if f==6then f=0f=1else assert(false,26)end assert(f==1,27)if f==5then assert(false,28)else f=2end assert(f==2,29)u=1while f>0do f-=1u*=2end assert(u==4and f==0,30)while u>0do u-=1f+=1end assert(f==4and u==0,31)while f>0do f-=1u+=1if u==3then break end end assert(f==1and u==3,32)repeat f+=1u-=1until f==1or f==3assert(f==3and u==1,33)function r()return end function m()end assert(r()==nil and pack(r()).n==0,34)assert(m()==nil and pack(m()).n==0,35)function x(...)return...end i={1,2,l=1,i=2,3,4,[12]=4,x(5,6,nil,8)}assert(i[1]==1and i[2]==2and i[3]==3and i[4]==4and i[5]==5and i[6]==6,36)assert(i[7]==nil and i[8]==8and i["l"]==1and i.i==2and i[12]==4,37)function x(...)return{...}end do local function n(...)return{...,l=3}end assert(#n(1,2)==1and n(1,2).l==3,38)end assert(#x(1,2)==2,39)assert(1+4*5==21and 498&255<<4==496,40)assert((1+4)*5==25and(498&255)<<4==3872,41)assert(-2^4==-16and(-2)^4==16,42)assert(1~=2and 1~=2or assert(false,43),43.1)e={a=function(n)return n.d end,d=3}assert(e:a()==3and e.a{d=4}==4,44)setmetatable(e,{__index=function(e,n)return n end})assert(e.r=="r",45)e.o=e function e.o.o.d(n)return n end assert(e.d(false)==false,46)function e.o.o:t(n)return self,n end assert(e:t(true)==e and select(2,e:t(true))==true,47)do n=1do::n::n+=1if n==4then goto e end goto n end::e::assert(n==4,48)end do::n::do goto n assert(false,49)::n::end end n=0for e,d in next,{5}do assert(e==1and d==5,50)n+=1end assert(n==1,50.5)do local n,_ENV=add,{assert=assert}n(_ENV,3)assert(_ENV[1]==3,51)end local function e(n)_ENV=n end local d=_ENV e{assert=assert,k=123}assert(k==123,52)e(d)function r()return 9,0,1end function z(n)return n()end function j(n)return(n())end assert(pack(z(r)).n==3and pack(j(r)).n==1,53)n=72n-=4*2n>>>=16assert(n==.00098,54)if n<1then if n==0then n=123end else n=321end assert(n==.00098,55)do local n=1function n()end end assert(y==nil,56)n=1repeat local n=2until assert(n==2,57)do local n=2repeat local e=3until assert(n*e==6,57.5)end local function e()return 3end assert(-e()+e()==0,58)local function d()return e end assert(d()()==3,59)local function n(e,d)local o=function()e+=1return e end if d and d>0then return o,n(e*2,d-1)else return o end end local o,l,a,t=n(10),n(20),n(30,1)assert(o()==11and l()==21and n(0)()==1and a()==31and t()==61and o()==12and l()==22and n(0)()==1and a()==32and t()==62,60)function w(n)return n end assert(w"me"=="me"and w[[me]]=="me",61)b={f=function(e,n)return n end}assert(b:f"me"=="me"and#b:f{}==0,62)do while true do if 1==1then::n::end goto n end::n::end local n=1function q()return n end local n=2assert(q()==1,63)local n=1do function v()return n end local n=2assert(v()==1,64)end do local n,e=1,2::n::assert(e==2,65)if n>1then assert(h()==4and e==2,66)goto e end local e=3h=function()e+=1return e end n+=1goto n end::e::do local n=1::n::local e=n d=h h=function()e+=1return e end n+=1if n==3then goto d else goto n end end::d::assert(h()==3and h()==4and d()==2and h()==5and d()==3,67)do goto n local n::n::end if 1==1then end local n=0function ord(e,d)assert(n==e,68)n+=1return d end local n={}ord(0,n).e,ord(1,n).e=ord(2,2),ord(3,function()return 3end)(ord(4,1),ord(5,1))assert(n.e==2,69)local o,n=1,2assert(n==2,70)function e(e,n)assert(n==2,71)end e(1,2)p=0g={10,20}function d()p+=1return p end g[d()]+=1assert(g[1]==11and g[2]==20,72)n=0n+=16assert(n==16,73)assert([[[[]]=="[[",73.5)if 1==1then if 2==3then n=1else n=2end else n=3end assert(n==2,74)if 1==2then if 2==3then n=1else n=2end else n=3end assert(n==3,74.1)s=1while s<10do s+=1if s==5then break end end assert(s==5,75)if 1==2then s=1else if 1==3then s=2else s=3end end assert(s==3,76)if 1==1then if 2==2then n=4else n=5end else n=6end assert(n==4,77)do n=0if 1==2then end end n=123assert(n==123,78)do local e,n=print print=function(e)n=e end?1
assert(n==1,79)print=e end do local n local print=function(e)n=e end?2
assert(n==2,80)end e=1({e=1}).e=2assert(e==1,81)e={1}({e=1}).e=2assert(e[1]==1,81.1)e="1"({e=1}).e=2assert(e=="1",81.2)e=function()end({e=1}).e=2assert(e()==nil,81.3)printh"DONE"
__gfx__
dcf6c3968fc4f9d8632d39e67f3953076b48f7b7a87b8f3a1c7d3c647677c0aa345a17500639192c448e3ae773c1ef4b9b8ced74657b1a43f0d23d321a0ad40a
4c49a63747ffeabf17d2d2b36f4ee65c129fbbb1663d2dc2ab0daefb2326aec74f6acf74d9ab50d107f004901073e9cfa89bf6908d49a65e45a6804661ba5179
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
__label__
v0606660600060000660000060600660666060006600000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6v606000600060006060000060606060606060006060000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66v06600600060006060000060606060660060006060000000000000000000000000000000000000000000000000000000000000000000000000000000000000
606v6000600060006060000066606060606060006060000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6060v660666066606600000066606600606066606660000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000v00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000v0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000v000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000v00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000v0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000v000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000v00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000v0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000v000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000v00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000v0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000v000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000v00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000v0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000v000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000v00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000v0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000v000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000v00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000v0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000v000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000v00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000v0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000v000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000v00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000v0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000v000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000v00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000v0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000v000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000v00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000v0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000v000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000v00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000v0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000v000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000v00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000v0000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000v000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000v00000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000v0000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000v000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000v00000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000v0000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000v000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000v00000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000v0000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000v000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000v00000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000v0000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000v000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000v00000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000v0000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000v000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000v00000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000v0000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000v000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000v00000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000v0000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000v000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000v00000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000v0000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000v000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000v00000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000v0000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000v000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000v00000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000v0000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000v000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000v00000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000v0000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000v000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000v00000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000v0000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000v000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000v00000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000v0000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000v000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000v00000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000v0000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000v000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000v00000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000v0000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000v000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000v00000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000v0000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000v000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000v00000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000v0000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000v000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000v00000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000v0000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000v000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000v00000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000v0000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000v000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0123456789abcde00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__meta:hello__
hello1
hello2
__meta:hello2__
hello3
hello4
__meta:title__
this tests a good deal of syntax
