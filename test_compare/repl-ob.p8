pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--------------------------------------
-- Please see 'Commented Source Code' section in the BBS
-- for the original commented source code
-- (The below had the comments stripped due to cart size limits)
--------------------------------------
local t,eu,ea=_ENV,{},{}for n,e in pairs(_ENV)do eu[n]=e if type(e)=="function"then ea[n]=true end end local _ENV=eu j,n5=true function f(t,e)for n=1,#e do if sub(e,n,n)==t then return n end end end function e(e,n)return sub(e,n,n)end local ec,e1,eu=split"a,b,f,n,r,t,v,\\,\",',\n,*,#,-,|,+,^",split"⁷,⁸,ᶜ,\n,\r,	,ᵇ,\\,\",',\n,¹,²,³,⁴,⁵,⁶",{}for n=1,#ec do eu[ec[n]]=e1[n]end function g(n)return n>="0"and n<="9"end function q(n)return n>="A"and n<="Z"or n>="a"and n<="z"or n=="_"or n>="█"or g(n)end function nz(r,n,i,o)local t=""while n<=#r do local l=e(r,n)if l==i then break end if l=="\\"then n+=1local t=e(r,n)l=eu[t]if t=="x"then t=tonum("0x"..sub(r,n+1,n+2))if t then n+=2else o"bad hex escape"end l=chr(t)elseif g(t)then local i=n while g(t)and n<i+3do n+=1t=e(r,n)end n-=1t=tonum(sub(r,i,n))if not t or t>=256then o"bad decimal escape"end l=chr(t)elseif t=="z"then repeat n+=1t=e(r,n)until not f(t," \r	ᶜᵇ\n")if t==""then o()end l=""n-=1elseif t==""then o()l=""end if not l then o("bad escape: "..t)l=""end elseif l=="\n"then o"unterminated string"break end t..=l n+=1end if n>#r then o("unterminated string",true)end return t,n+1end function n6(t,n,l,r)if e(t,n)=="["then n+=1local r=n while e(t,n)=="="do n+=1end local r="]"..sub(t,r,n-1).."]"local o=#r if e(t,n)=="["then n+=1if e(t,n)=="\n"then n+=1end local e=n while n<=#t and sub(t,n,n+o-1)~=r do n+=1end if n>=#t then l()end return sub(t,e,n-1),n+o end end if r then l"invalid long brackets"end return nil,n end function ng(l,c)local n,s,o,h,b,p,u,i=1,1,{},{},{},{}local function d(n,e)if c then n8(n,i)end u=n and not e end while n<=#l do i=n local t,a,r=e(l,n)if f(t," \r	ᶜᵇ\n")then n+=1a=true if t=="\n"then s+=1end elseif t=="-"and e(l,n+1)=="-"then n+=2if e(l,n)=="["then r,n=n6(l,n,d)end if not r then while n<=#l and e(l,n)~="\n"do n+=1end end if c then a=true else add(o,true)end elseif g(t)or t=="."and g(e(l,n+1))then local u,a="0123456789",true if t=="0"and f(e(l,n+1),"xX")then u..="AaBbCcDdEeFf"n+=2elseif t=="0"and f(e(l,n+1),"bB")then u="01"n+=2end while true do t=e(l,n)if t=="."and a then a=false elseif not f(t,u)then break end n+=1end r=sub(l,i,n-1)if not tonum(r)then d"bad number"r="0"end add(o,tonum(r))elseif q(t)then while q(e(l,n))do n+=1end add(o,sub(l,i,n-1))elseif t=="'"or t=='"'then r,n=nz(l,n+1,t,d)add(o,{t=r})elseif t=="["and f(e(l,n+1),"=[")then r,n=n6(l,n,d,true)add(o,{t=r})else n+=1local e,r,u=unpack(split(sub(l,n,n+2),""))if e==t and r==t and f(t,".>")then n+=2if u=="="and f(t,">")then n+=1end elseif e==t and r~=t and f(t,"<>")and f(r,"<>")then n+=2if u=="="then n+=1end elseif e==t and f(t,".:^<>")then n+=1if r=="="and f(t,".^<>")then n+=1end elseif e=="="and f(t,"+-*/\\%^&|<>=~!")then n+=1elseif f(t,"+-*/\\%^&|<>=~#(){}[];,?@$.:")then else d("bad char: "..t)end add(o,sub(l,i,n-1))end if not a then add(h,s)add(b,i)add(p,n-1)end if u then o[#o],u=false,false end end return o,h,b,p end function r(t,n)for e=1,#n do if n[e]==t then return e end end end function c(n)return unpack(n,1,n.n)end function nj(e)local n={}for e,t in next,e do n[e]=t end return n end local n6=split"and,break,do,else,elseif,end,false,for,function,goto,if,in,local,nil,not,or,repeat,return,then,true,until,while"nd={}for n in all(n6)do nd[n]=true end local function n6(n)return type(n)=="string"and e(n,#n)=="="end nk=split"end,else,elseif,until"function n4(n,ni)local o,no,l=ng(n,true)local n,f,s,v,d,p,x,t,b,y,h,nn=1,0,0,{}local function i(e)n8(e,l[n-1]or 1)end local function g(n)return function()return n end end local function nt(e)local n=d[e]if n then return function(t)return t[n][e]end else n=d._ENV return function(t)return t[n]._ENV[e]end end end local function nf()local n=d["..."]if not n or n~=nn then i"unexpected '...'"end return function(e)return c(e[n]["..."])end end local function nl(e)local n=d[e]if n then return function(t)return t[n],e end else n=d._ENV return function(t)return t[n]._ENV,e end end end local function l(e)local t=o[n]n+=1if t==e then return end if t==nil then i()end i("expected: "..e)end local function u(t)if not t then t=o[n]n+=1end if t==nil then i()end if type(t)=="string"and q(e(t,1))and not nd[t]then return t end if type(t)=="string"then i("invalid identifier: "..t)end i"identifier expected"end local function e(e)if o[n]==e then n+=1return true end end local function z()d=setmetatable({},{__index=d})f+=1end local function q()d=getmetatable(d).__index f-=1end local function m(l,t)local e,n={},#t for n=1,n-1do e[n]=t[n](l)end if n>0then local t=pack(t[n](l))if t.n~=1then for l=1,t.n do e[n+l-1]=t[l]end n+=t.n-1else e[n]=t[1]end end e.n=n return e end local function k(t)local n={}add(n,(t()))while e","do add(n,(t()))end return n end local function ne(r,o,i)local n={}if i then add(n,i)elseif not e")"then while true do add(n,(t()))if e")"then break end l","end end if o then return function(e)local t=r(e)return t[o](t,c(m(e,n)))end,true,nil,function(e)local t=r(e)return t[o],pack(t,c(m(e,n)))end else return function(e)return r(e)(c(m(e,n)))end,true,nil,function(e)return r(e),m(e,n)end end end local function nd()local r,d,c,a={},{},1while not e"}"do a=nil local i,f if e"["then i=t()l"]"l"="f=t()elseif o[n+1]=="="then i=g(u())l"="f=t()else i=g(c)f=t()c+=1a=#r+1end add(r,i)add(d,f)if e"}"then break end if not e";"then l","end end return function(e)local t={}for n=1,#r do if n==a then local l,n=r[n](e),pack(d[n](e))for e=1,n.n do t[l+e-1]=n[e]end else t[r[n](e)]=d[n](e)end end return t end end local function nr(o,a)local n,p,t if o then if a then z()n=u()d[n]=f t=nl(n)else n={u()}while e"."do add(n,u())end if e":"then add(n,u())p=true end if#n==1then t=nl(n[1])else local e=nt(n[1])for t=2,#n-1do local l=e e=function(e)return l(e)[n[t]]end end t=function(t)return e(t),n[#n]end end end end local n,r={}if p then add(n,"self")end l"("if not e")"then while true do if e"..."then r=true else add(n,u())end if e")"then break end l","if r then i"unexpected param after '...'"end end end z()for n in all(n)do d[n]=f end if r then d["..."]=f end local e,i,d=v,h,nn v,h,nn={},s+1,f local f=b()for n in all(v)do n()end v,h,nn=e,i,d l"end"q()return function(e)if a then add(e,{})end local l=nj(e)local i=#l local n=function(...)local t,e=pack(...),l if#e~=i then local n={}for t=0,i do n[t]=e[t]end e=n end local l={}for e=1,#n do l[n[e]]=t[e]end if r then l["..."]=pack(unpack(t,#n+1,t.n))end add(e,l)local n=f(e)deli(e)if n then if type(n)=="table"then return c(n)end return n()end end if o then local e,t=t(e)e[t]=n else return n end end end local function nn()local e=o[n]n+=1local n if e==nil then i()end if e=="nil"then return g()end if e=="true"then return g(true)end if e=="false"then return g(false)end if type(e)=="number"then return g(e)end if type(e)=="table"then return g(e.t)end if e=="{"then return nd()end if e=="("then n=t()l")"return function(e)return(n(e))end,true end if e=="-"then n=t(11)return function(e)return-n(e)end end if e=="~"then n=t(11)return function(e)return~n(e)end end if e=="not"then n=t(11)return function(e)return not n(e)end end if e=="#"then n=t(11)return function(e)return#n(e)end end if e=="@"then n=t(11)return function(e)return@n(e)end end if e=="%"then n=t(11)return function(e)return%n(e)end end if e=="$"then n=t(11)return function(e)return$n(e)end end if e=="function"then return nr()end if e=="..."then return nf()end if e=="\\"then n=u()return function()return nq(n)end,true,function()return en(n)end end if u(e)then return nt(e),true,nl(e)end i("unexpected token: "..e)end local function nl(e,t,l,r)local n if e=="^"and t<=12then n=r(12)return function(e)return l(e)^n(e)end end if e=="*"and t<10then n=r(10)return function(e)return l(e)*n(e)end end if e=="/"and t<10then n=r(10)return function(e)return l(e)/n(e)end end if e=="\\"and t<10then n=r(10)return function(e)return l(e)\n(e)end end if e=="%"and t<10then n=r(10)return function(e)return l(e)%n(e)end end if e=="+"and t<9then n=r(9)return function(e)return l(e)+n(e)end end if e=="-"and t<9then n=r(9)return function(e)return l(e)-n(e)end end if e==".."and t<=8then n=r(8)return function(e)return l(e)..n(e)end end if e=="<<"and t<7then n=r(7)return function(e)return l(e)<<n(e)end end if e==">>"and t<7then n=r(7)return function(e)return l(e)>>n(e)end end if e==">>>"and t<7then n=r(7)return function(e)return l(e)>>>n(e)end end if e=="<<>"and t<7then n=r(7)return function(e)return l(e)<<>n(e)end end if e==">><"and t<7then n=r(7)return function(e)return l(e)>><n(e)end end if e=="&"and t<6then n=r(6)return function(e)return l(e)&n(e)end end if e=="^^"and t<5then n=r(5)return function(e)return l(e)~n(e)end end if e=="|"and t<4then n=r(4)return function(e)return l(e)|n(e)end end if e=="<"and t<3then n=r(3)return function(e)return l(e)<n(e)end end if e==">"and t<3then n=r(3)return function(e)return l(e)>n(e)end end if e=="<="and t<3then n=r(3)return function(e)return l(e)<=n(e)end end if e==">="and t<3then n=r(3)return function(e)return l(e)>=n(e)end end if e=="=="and t<3then n=r(3)return function(e)return l(e)==n(e)end end if(e=="~="or e=="!=")and t<3then n=r(3)return function(e)return l(e)~=n(e)end end if e=="and"and t<2then n=r(2)return function(e)return l(e)and n(e)end end if e=="or"and t<1then n=r(1)return function(e)return l(e)or n(e)end end end local function nf(d,e,a)local i=o[n]n+=1local r,f if a then if i=="."then r=u()return function(n)return e(n)[r]end,true,function(n)return e(n),r end end if i=="["then r=t()l"]"return function(n)return e(n)[r(n)]end,true,function(n)return e(n),r(n)end end if i=="("then return ne(e)end if i=="{"or type(i)=="table"then n-=1f=nn()return ne(e,nil,f)end if i==":"then r=u()if o[n]=="{"or type(o[n])=="table"then f=nn()return ne(e,r,f)end l"("return ne(e,r)end end local e=nl(i,d,e,t)if not e then n-=1end return e end t=function(r)local n,e,t,l=nn()while true do local r,o,i,f=nf(r or 0,n,e)if not r then break end n,e,t,l=r,o,i,f end return n,t,l end local function nn()local e,n=t()if not n then i"cannot assign to value"end return n end local function nf()local n=k(nn)l"="local e=k(t)if#n==1and#e==1then return function(t)local n,l=n[1](t)n[l]=e[1](t)end else return function(t)local l,r={},{}for e=1,#n do local n,e=n[e](t)add(l,n)add(r,e)end local e=m(t,e)for n=#n,1,-1do l[n][r[n]]=e[n]end end end end local function nd(e,l)local r=o[n]n+=1local n=sub(r,1,-2)local n=nl(n,0,e,function()return t()end)if not n then i"invalid compound assignment"end return function(e)local t,l=l(e)t[l]=n(e)end end local function nu()if e"function"then return nr(true,true)else local n,e=k(u),e"="and k(t)or{}z()for e=1,#n do d[n[e]]=f end if#n==1and#e==1then return function(t)add(t,{[n[1]]=e[1](t)})end else return function(t)local l,r={},m(t,e)for e=1,#n do l[n[e]]=r[e]end add(t,l)end end end end local function nl(e)local t=no[n-1]x=function()return t~=no[n]end if not e or x()then i(n<=#o and"bad shorthand"or nil)end end local function no()local r,o,t,n=o[n]=="(",t()if e"then"then t,n=b()if e"else"then n=b()l"end"elseif e"elseif"then n=no()else l"end"end else nl(r)t=b()if not x()and e"else"then n=b()end x=nil end return function(e)if o(e)then return t(e)elseif n then return n(e)end end end local function nn(...)local n=y y=s+1local e=b(...)y=n return e end local function ne(n,e)if n==true then return end return n,e end local function na()local r,t,n=o[n]=="(",t()if e"do"then n=nn()l"end"else nl(r)n=nn()x=nil end return function(e)while t(e)do if stat(1)>=1then w()end local n,e=n(e)if n then return ne(n,e)end end end end local function nl()local r,e=f,nn(true)l"until"local l=t()while f>r do q()end return function(n)repeat if stat(1)>=1then w()end local e,t=e(n)if not e then t=l(n)end while#n>r do deli(n)end if e then return ne(e,t)end until t end end local function nc()if o[n+1]=="="then local r=u()l"="local o=t()l","local i,e=t(),e","and t()or g(1)l"do"z()d[r]=f local t=nn()l"end"q()return function(n)for e=o(n),i(n),e(n)do if stat(1)>=1then w()end add(n,{[r]=e})local e,t=t(n)deli(n)if e then return ne(e,t)end end end else local r=k(u)l"in"local e=k(t)l"do"z()for n in all(r)do d[n]=f end local o=nn()l"end"q()return function(n)local e=m(n,e)while true do local l,t={},{e[1](e[2],e[3])}if t[1]==nil then break end e[3]=t[1]for n=1,#r do l[r[n]]=t[n]end if stat(1)>=1then w()end add(n,l)local e,t=o(n)deli(n)if e then return ne(e,t)end end end end end local function g()if not y or h and y<h then i"break outside of loop"end return function()return true end end local function y()if not h and not ni then i"return outside of function"end if o[n]==";"or r(o[n],nk)or x and x()then return function()return pack()end else local n,r,l=t()local n={n}while e","do add(n,(t()))end if#n==1and l and h then return function(n)local n,e=l(n)if stat(1)>=1then w()end return function()return n(c(e))end end else return function(e)return m(e,n)end end end end local function z(e)local n=u()l"::"if p[n]and p[n].e==s then i"label already defined"end p[n]={l=f,e=s,o=e,r=#e}end local function nn()local t,e,l,n=u(),p,f add(v,function()n=e[t]if not n then i"label not found"end if h and n.e<h then i"goto outside of function"end local e=e[n.e]or l if n.l>e and n.r<#n.o then i"goto past local"end end)return function()if stat(1)>=1then w()end return 0,n end end local function u(f)local r=o[n]n+=1if r==";"then return end if r=="do"then local n=b()l"end"return n end if r=="if"then return no()end if r=="while"then return na()end if r=="repeat"then return nl()end if r=="for"then return nc()end if r=="break"then return g()end if r=="return"then return y(),true end if r=="local"then return nu()end if r=="goto"then return nn()end if r=="::"then return z(f)end if r=="function"and o[n]~="("then return nr(true)end if r=="?"then local e,t=nt"print",k(t)return function(n)e(n)(c(m(n,t)))end end n-=1local r,t,f,l=n,t()if e","or e"="then n=r return nf()elseif n6(o[n])then return nd(t,f)elseif s<=1and j then return function(n)local n=pack(t(n))if not(l and n.n==0)then add(a,n)end n5=n[1]end else if not l then i"statement has no effect"end return function(n)t(n)end end end b=function(t)p=setmetatable({},{__index=p})p[s]=f s+=1local d,i,l=s,t and 32767or f,{}while n<=#o and not r(o[n],nk)and not(x and x())do local n,t=u(l)if n then add(l,n)end if t then e";"break end end while f>i do q()end s-=1p=getmetatable(p).__index return function(e)local r,o,t,n=1,#l while r<=o do t,n=l[r](e)if t then if type(t)~="number"then break end if n.e~=d then break end r=n.r while#e>n.l do deli(e)end t,n=nil end r+=1end while#e>i do deli(e)end return t,n end end d=j and{_ENV=0,_env=0,_=0}or{_ENV=0}local e=b()if n<=#o then i"unexpected end"end for n in all(v)do n()end return function(n)local n=j and{_ENV=n,_env=n,_=n5}or{_ENV=n}local n=e{[0]=n}if n then return c(n)end end end n2,nb=10,false local n5={["\0"]="000",["ᵉ"]="014",["ᶠ"]="015"}for n,e in pairs(eu)do if not f(n,"'\n")then n5[e]=n end end function ee(n)local t=1while t<=#n do local e=e(n,t)local e=n5[e]if e then n=sub(n,1,t-1).."\\"..e..sub(n,t+1)t+=#e end t+=1end return'"'..n..'"'end function et(n)if type(n)~="string"then return false end if nd[n]then return false end if#n==0or g(e(n,1))then return false end for t=1,#n do if not q(e(n,t))then return false end end return true end function nn(e,t)local n=type(e)if n=="nil"then return"nil"elseif n=="boolean"then return e and"true"or"false"elseif n=="number"then return tostr(e,nb)elseif n=="string"then return ee(e)elseif n=="table"and not t then local n,t,r="{",0,0for e,l in next,e do if t==n2 then n=n..",<...>"break end if t>0then n=n..","end local l=nn(l,1)if e==r+1then n=n..l r=e elseif et(e)then n=n..e.."="..l else n=n.."["..nn(e,1).."]="..l end t+=1end return n.."}"else return"<"..tostr(n)..">"end end function el(n,e)if e==nil then return n end if not n then n=""end local t=min(21,#e)for t=1,t do if#n>0then n..="\n"end local t=e[t]if type(t)=="table"then local e=""for n=1,t.n do if#e>0then e=e..", "end e=e..nn(t[n])end n..=e else n..=t end end local l={}for n=t+1,#e do l[n-t]=e[n]end return n,l end poke(24365,1)cls()d="> "n,s,k="",1,0l,v=1,20u,y={""},1ne=false h,o=0,1nu,na=true,true i={7,4,3,5,6,8,5,12,14,7,11,5}t.print=function(n,...)if pack(...).n~=0or not nu then return print(n,...)end add(a,tostr(n))end function n9()poke(24368,1)end function nv()return function()if stat(30)then return stat(31)end end end function np(r,o)local t,n,l=1,0,0if not r then return t,n,l end while t<=#r do local e=e(r,t)local r=e>="█"if n>=(r and 31or 32)then l+=1n=0end if o then o(t,e,n,l)end if e=="\n"then l+=1n=0else n+=r and 2or 1end t+=1end return t,n,l end function nt(t,l)local n,e=0,0local o,r,t=np(t,function(t,i,r,o)if l==t then n,e=r,o end end)if l>=o then n,e=r,t end if r>0then t+=1end return n,e,t end function nl(l,r,e)local t,n=1,false local r,o,l=np(l,function(o,f,i,l)if e==l and r==i and not n then t=o n=true end if(e<l or e==l and r<i)and not n then t=o-1n=true end end)if not n then t=e>=l and r or r-1end if o>0then l+=1end return t,l end function nw(n,t,l,e)if type(e)=="function"then np(n,function(n,r,o,i)print(r,t+o*4,l+i*6,e(n))end)else print(n and"⁶rw"..n,t,l,e)end end function er(n,o,f)local d,t,u,l=ng(n)local t=1nw(n,o,f,function(o)while t<=#l and l[t]<o do t+=1end local n if t<=#l and u[t]<=o then n=d[t]end local t=i[5]if n==false then t=i[6]elseif n==true then t=i[7]elseif type(n)~="string"or r(n,{"nil","true","false"})then t=i[8]elseif nd[n]then t=i[9]elseif not q(e(n,1))then t=i[10]elseif ea[n]then t=i[11]end return t end)end function _draw()local u,c,p=peek(24357),peek2(24360),peek2(24362)camera()local function e(n)cursor(0,127)for n=1,n do rectfill(0,o*6,127,(o+1)*6-1,0)if o<21then o+=1else print""end end end local function w(n,e)for n=1,n do if o>e then o-=1end rectfill(0,o*6,127,(o+1)*6-1,0)end end local function m(n,e)for t=0,2do local l=pget(n+t,e+5)pset(n+t,e+5,l==0and i[12]or 0)end end local function f(f)local r=d..n.." "local l,t,n=nt(r,#d+l)if n>s then e(n-s)elseif n<s then w(s-n,n)end s=n k=mid(k,0,max(s-21,0))::n::local n=o-s+k if n+t<0then k+=1goto n end if n+t>=21then k-=1goto n end local n=n*6rectfill(0,n,127,n+s*6-1,0)if s>21then rectfill(0,126,127,127,0)end er(r,0,n)print(d,0,n,i[4])if v>=10and f~=false and not x then m(l*4,n+t*6)end end local function d(t)e(1)o-=1print("[enter] ('esc' to abort)",0,o*6,i[3])while true do flip()n9()for n in nv()do if n=="•"then ne=true b=""a={}return false end if n=="\r"or n=="\n"then h+=t return true end end end end::n::local r,t if a or b then r,t=nl(b,0,h)if t-h<=20and a then b,a=el(b,a)r,t=nl(b,0,h)if#a==0and not x then a=nil end end end if not x then camera()end if h==0and not x then f(not b)end if b then local u,r=sub(b,r),min(t-h,20)e(r)nw(u,0,(o-r)*6,i[1])if r<t-h then if d(r)then goto n end else local d,u,t=nt(nc,0)e(t)nw(nc,0,(o-t)*6,i[2])if x then h+=r else n,s,k,l,h,b,nc="",0,0,1,0f()end end end if x then e(1)o-=1print(x,0,o*6,i[3])end if z then e(1)o-=1print(z,0,o*6,i[3])z=nil end if n1 then n1-=1if n1==0then z,n1=""end end v-=1if v==0then v=20end color(u)camera(c,p)if o<=20then cursor(0,o*6)end end ns,nr,no=false,false,false ni={}function n8(n,e)m,eo=n,e assert(false,n)end function nx(n,e,l)return n4(n,l)(e or t)end function n3(n,e)return nx("return "..n,e,true)end function ei(n)local e=cocreate(n4)::n::local n,e=coresume(e,n)if n and not e then goto n end if not n then e,m=m,false end return n,e end function ef(n,e)local n,e=nt(n,e)return"line "..e+1 .." col "..n+1end function ny(e,l)a,ne,m={},false,false ns,nr,no=false,false,false local t,r,n=cocreate(function()nx(e)end)while true do r,n=coresume(t)if costatus(t)=="dead"then break end if nu and not nr then x="running, press 'esc' to abort"_draw()flip()x=nil else if na and not nr and not no then flip()end if not na and holdframe then holdframe()end no=false end for n in nv()do if n=="•"then ne=true else add(ni,n)end end if ne then n="computation aborted"break end end if m==nil then if l then n="unexpected end of code"else n,a=nil end end if m then n,m=m.."\nat "..ef(e,eo)end nc=n ni={}end w=function()ns=true yield()ns=false end t.flip=function(...)local n=pack(flip(...))no=true w()return c(n)end t.coresume=function(n,...)local e=pack(coresume(n,...))while ns do yield()e=pack(coresume(n))end m=false return c(e)end t.stat=function(n,...)if n==30then return#ni>0or stat(n,...)elseif n==31then if#ni>0then return deli(ni,1)else local n=stat(n,...)if n=="•"then ne=true end return n end else return stat(n,...)end end function ed(n)if _set_fps then _set_fps(n._update60 and 60or 30)end if n._init then n._init()end nr=true while true do if _update_buttons then _update_buttons()end if holdframe then holdframe()end if n._update60 then n._update60()elseif n._update then n._update()end if n._draw then n._draw()end flip()no=true w()end nr=false end function nq(e)if r(e,{"i","interrupt"})then return nu elseif r(e,{"f","flip"})then return na elseif r(e,{"r","repl"})then return j elseif r(e,{"mi","max_items"})then return n2 elseif r(e,{"h","hex"})then return nb elseif r(e,{"cl","colors"})then return i elseif r(e,{"c","code"})then local n={[0]=n}for e=1,#u-1do n[e]=u[#u-e]end return n elseif r(e,{"cm","compile"})then return function(n)return ei(n)end elseif r(e,{"x","exec"})then return function(n,e)nx(n,e)end elseif r(e,{"v","eval"})then return function(n,e)return n3(n,e)end elseif r(e,{"p","print"})then return function(n,...)t.print(nn(n),...)end elseif r(e,{"ts","tostr"})then return function(n)return nn(n)end elseif r(e,{"rst","reset"})then run()elseif r(e,{"run"})then ed(t)else assert(false,"unknown \\-command")end end function en(e)local function t(n)return n and n~=0and true or false end local n if r(e,{"i","interrupt"})then n=function(n)nu=t(n)end elseif r(e,{"f","flip"})then n=function(n)na=t(n)end elseif r(e,{"r","repl"})then n=function(n)j=t(n)end elseif r(e,{"mi","max_items"})then n=function(n)n2=tonum(n)or-1end elseif r(e,{"h","hex"})then n=function(n)nb=t(n)end elseif r(e,{"cl","colors"})then n=function(n)i=n end else assert(false,"unknown \\-command assign")end local n={__newindex=function(t,l,e)n(e)end}return setmetatable(n,n),0end nh=stat(4)nf,n0=0,false poke(24412,10,2)function p(n)if stat(28,n)then if n~=nm then nm,nf=n,0end return nf==0or nf>=10and nf%2==0elseif nm==n then nm=nil end end function _update()local t=false local function r(r)local t,e,o=nt(d..n,#d+l)if n7 then t=n7 end e+=r if not(e>=0and e<o)then return false end l=max(nl(d..n,t,e)-#d,1)n7=t v=20return true end local function f(r)local e,o=nt(d..n,#d+l)e=r>0and 100or 0l=max(nl(d..n,e,o)-#d,1)t=true end local function c(r)u[y]=n y+=r n=u[y]if r<0then l=#n+1else l=max(nl(d..n,32,0)-#d,1)local n=e(n,l)if n~=""and n~="\n"then l-=1end end t=true end local function d()if#n>0then if#u>50then del(u,u[1])end u[#u]=n add(u,"")y=#u t=true end end local function s(e)if l+e>0then n=sub(n,1,l+e-1)..sub(n,l+e+1)l+=e t=true end end local function o(e)n=sub(n,1,l-1)..e..sub(n,l)l+=#e t=true end local i,h,e=stat(28,224)or stat(28,228),stat(28,225)or stat(28,229),-1if p(80)then if l>1then l-=1t=true end elseif p(79)then if l<=#n then l+=1t=true end elseif p(82)then if(i or not r(-1))and y>1then c(-1)end elseif p(81)then if(i or not r(1))and y<#u then c(1)end else local r=stat(31)e=ord(r)if r=="•"then if#n==0then extcmd"pause"else a,nc={}d()end elseif r=="\r"or r=="\n"then if h then o"\n"else ny(n)if not a then o"\n"else d()end end elseif i and p(40)then ny(n,true)d()elseif r~=""and e>=32and e<154then if n0 and e>=128then r=chr(e-63)end o(r)elseif e==193then o"\n"elseif e==192then f(-1)elseif e==196then f(1)elseif e==203then n0=not n0 z,n1="shift now selects "..(n0 and"punycase"or"symbols"),40elseif p(74)then if i then l=1t=true else f(-1)end elseif p(77)then if i then l=#n+1t=true else f(1)end elseif p(42)then s(-1)elseif p(76)then s(0)end end local r=stat(4)if r~=nh or e==213then o(r)nh=r end if e==194or e==215then if n~=""and n~=nh then nh=n printh(n,"@clip")if e==215then n=""l=1end z="press again to put in clipboard"else z=""end end if stat(120)then local n repeat n=serial(2048,24448,128)o(chr(peek(24448,n)))until n==0end if t then v,n7=20end nf+=1n9()end function n_(n,e)local e,t=coresume(cocreate(e))if not e then printh("error #"..n..": "..t)print("error #"..n.."\npico8 broke something again,\nthis cart may not work.\npress any button to ignore")while btnp()==0do flip()end cls()end end n_(1,function()assert(pack(n3"(function (...) return ... end)(1,2,nil,nil)").n==4)end)n_(2,function()assert(n3"function() local temp, temp2 = {max(1,3)}, -20;return temp[1] + temp2; end"()==-17)end)printh"finished"stop()while true do if holdframe then holdframe()end _update()_draw()flip()end
__meta:title__
keep:------------------------------------
keep: Please see 'Commented Source Code' section in the BBS