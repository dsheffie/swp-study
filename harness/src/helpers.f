      subroutine set1d(n,array,value,stride)
c
c  -- initialize one-dimensional arrays
c
      integer i, n, stride, frac, frac2
      real array(n), value
      parameter(frac=-1,frac2=-2)
      if ( stride .eq. frac ) then
         do 10 i=1,n
            array(i) = 1.0/float(i)
10       continue
      elseif ( stride .eq. frac2 ) then
         do 15 i=1,n
            array(i) = 1.0/float(i*i)
15       continue
      else
         do 20 i=1,n,stride
            array(i) = value
20       continue
      endif
      return
      end
      subroutine set2d(n,array,value,stride)
c
c  -- initialize two-dimensional arrays
c
      integer i, j, n, stride, frac, frac2, ld
      parameter(frac=-1, frac2=-2, ld=1000)
      real array(ld,n),value
      if ( stride .eq. frac ) then
         do 10 j=1,n
            do 20 i=1,n
               array(i,j) = 1.0/float(i)
20          continue
10       continue
      elseif ( stride .eq. frac2 ) then
         do 30 j=1,n
            do 40 i=1,n
               array(i,j) = 1.0/float(i*i)
40          continue
30       continue
      else
         do 50 j=1,n,stride
            do 60 i=1,n
               array(i,j) = value
60          continue
50       continue
      endif
      return
      end
      real function cs1d(n,a)
c
c --  calculate one-dimensional checksum
c
      integer i,n
      real a(n), sum
      sum = 0.0
      do 10 i = 1,n
         sum = sum + a(i)
10    continue
      cs1d = sum
      return
      end
      real function cs2d(n,aa)
c
c --  calculate two-dimensional checksum
c
      integer i,j,n,ld
      parameter(ld=1000)
      real aa(ld,n), sum
      sum = 0.0
      do 10 j = 1,n
         do 20 i = 1,n
            sum = sum + aa(i,j)
20       continue
10    continue
      cs2d = sum
      return
      end
      subroutine dummy(ld,n,a,b,c,d,e,aa,bb,cc,s)
c
c --  called in each loop to make all computations appear required
c
      integer ld, n
      real a(n), b(n), c(n), d(n), e(n), aa(ld,n), bb(ld,n), cc(ld,n)
      real s
      return
      end
      subroutine init(ld,n,a,b,c,d,e,aa,bb,cc,name)
      real zero, small, half, one, two, any, array
      parameter(any=0.0,zero=0.0,half=.5,one=1.,two=2.,small=.000001)
      integer unit, frac, frac2, ld, n
      parameter(unit=1, frac=-1, frac2=-2)
      real a(n), b(n), c(n), d(n), e(n), aa(ld,n), bb(ld,n), cc(ld,n)
      common /cdata/ array(1000*1000)
      character*5 name

      if     ( name .eq. 's111 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, any,frac2)
      elseif ( name .eq. 's112 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, any,frac2)
      elseif ( name .eq. 's113 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, any,frac2)
      elseif ( name .eq. 's114 ' ) then
         call set2d(n,aa, any,frac)
         call set2d(n,bb, any,frac2)
      elseif ( name .eq. 's115 ' ) then
         call set1d(n,  a, one,unit)
         call set2d(n, aa,small,unit)
      elseif ( name .eq. 's116 ' ) then
         call set1d(n,  a, one,unit)
      elseif ( name .eq. 's118 ' ) then
         call set1d(n,  a, one,unit)
         call set2d(n, bb,small,unit)
      elseif ( name .eq. 's119 ' ) then
         call set2d(n,aa, one,unit)
         call set2d(n,bb, any,frac2)
      elseif ( name .eq. 's121 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, any,frac2)
      elseif ( name .eq. 's122 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, any,frac2)
      elseif ( name .eq. 's123 ' ) then
         call set1d(n,  a,zero,unit)
         call set1d(n,  b, one,unit)
         call set1d(n,  c, one,unit)
         call set1d(n,  d, any,frac)
         call set1d(n,  e, any,frac)
      elseif ( name .eq. 's124 ' ) then
         call set1d(n,  a,zero,unit)
         call set1d(n,  b, one,unit)
         call set1d(n,  c, one,unit)
         call set1d(n,  d, any,frac)
         call set1d(n,  e, any,frac)
      elseif ( name .eq. 's125 ' ) then
         call set1d(n*n,array,zero,unit)
         call set2d(n,aa, one,unit)
         call set2d(n,bb,half,unit)
         call set2d(n,cc, two,unit)
      elseif ( name .eq. 's126 ' ) then
         call set2d(n,  bb, one,unit)
         call set1d(n*n,array,any,frac)
         call set2d(n,  cc, any,frac)
      elseif ( name .eq. 's127 ' ) then
         call set1d(n,  a,zero,unit)
         call set1d(n,  b, one,unit)
         call set1d(n,  c, any,frac)
         call set1d(n,  d, any,frac)
         call set1d(n,  e, any,frac)
      elseif ( name .eq. 's128 ' ) then
         call set1d(n,  a,zero,unit)
         call set1d(n,  b, two,unit)
         call set1d(n,  c, one,unit)
         call set1d(n,  d, one,unit)
      elseif ( name .eq. 's131 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, any,frac2)
      elseif ( name .eq. 's132 ' ) then
         call set2d(n, aa, one,unit)
         call set1d(n,  b, any,frac)
         call set1d(n,  c, any,frac)
      elseif ( name .eq. 's141 ' ) then
         call set1d(n*n,array, one,unit)
         call set2d(n,bb, any,frac2)
      elseif ( name .eq. 's151 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, any,frac2)
      elseif ( name .eq. 's152 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b,zero,unit)
         call set1d(n,  c, any,frac)
         call set1d(n,  d, any,frac)
         call set1d(n,  e, any,frac)
      elseif ( name .eq. 's161 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n/2,b(1), one,2)
         call set1d(n/2,b(2),-one,2)
         call set1d(n,  c, one,unit)
         call set1d(n,  d, any,frac)
         call set1d(n,  e, any,frac)
      elseif ( name .eq. 's162 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, any,frac)
         call set1d(n,  c, any,frac)
      elseif ( name .eq. 's171 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, any,frac2)
      elseif ( name .eq. 's172 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, any,frac2)
      elseif ( name .eq. 's173 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, any,frac2)
      elseif ( name .eq. 's174 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, any,frac2)
      elseif ( name .eq. 's175 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, any,frac2)
      elseif ( name .eq. 's176 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, any,frac)
         call set1d(n,  c, any,frac)
      elseif ( name .eq. 's211 ' ) then
         call set1d(n,  a,zero,unit)
         call set1d(n,  b, one,unit)
         call set1d(n,  c, any,frac)
         call set1d(n,  d, any,frac)
         call set1d(n,  e, any,frac)
      elseif ( name .eq. 's212 ' ) then
         call set1d(n,  a, any,frac)
         call set1d(n,  b, one,unit)
         call set1d(n,  c, one,unit)
         call set1d(n,  d, any,frac)
      elseif ( name .eq. 's221 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, any,frac)
         call set1d(n,  c, any,frac)
         call set1d(n,  d, any,frac)
      elseif ( name .eq. 's222 ' ) then
         call set1d(n,  a,zero,unit)
         call set1d(n,  b, one,unit)
         call set1d(n,  c, one,unit)
      elseif ( name .eq. 's231 ' ) then
         call set2d(n,aa, one,unit)
         call set2d(n,bb, any,frac2)
      elseif ( name .eq. 's232 ' ) then
         call set2d(n,aa, one,unit)
         call set2d(n,bb,zero,unit)
      elseif ( name .eq. 's233 ' ) then
         call set2d(n,aa, any,frac)
         call set2d(n,bb, any,frac)
         call set2d(n,cc, any,frac)
      elseif ( name .eq. 's234 ' ) then
         call set2d(n,aa, one,unit)
         call set2d(n,bb, any,frac)
         call set2d(n,cc, any,frac)
      elseif ( name .eq. 's235 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, any,frac)
         call set1d(n,  c, any,frac)
         call set2d(n,aa, one,unit)
         call set2d(n,bb, any, frac2)
      elseif ( name .eq. 's241 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, one,unit)
         call set1d(n,  c, one,unit)
         call set1d(n,  d, one,unit)
      elseif ( name .eq. 's242 ' ) then
         call set1d(n,  a,small,unit)
         call set1d(n,  b,small,unit)
         call set1d(n,  c,small,unit)
         call set1d(n,  d,small,unit)
      elseif ( name .eq. 's243 ' ) then
         call set1d(n,  a,zero,unit)
         call set1d(n,  b, one,unit)
         call set1d(n,  c, any,frac)
         call set1d(n,  d, any,frac)
         call set1d(n,  e, any,frac)
      elseif ( name .eq. 's244 ' ) then
         call set1d(n,  a,zero,unit)
         call set1d(n,  b, one,unit)
         call set1d(n,  c,small,unit)
         call set1d(n,  d,small,unit)
      elseif ( name .eq. 's251 ' ) then
         call set1d(n,  a,zero,unit)
         call set1d(n,  b, one,unit)
         call set1d(n,  c, any,frac)
         call set1d(n,  d, any,frac)
      elseif ( name .eq. 's252 ' ) then
         call set1d(n,  a,zero,unit)
         call set1d(n,  b, one,unit)
         call set1d(n,  c, one,unit)
      elseif ( name .eq. 's253 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b,small,unit)
         call set1d(n,  c, one,unit)
         call set1d(n,  d, any,frac)
      elseif ( name .eq. 's254 ' ) then
         call set1d(n,  a,zero,unit)
         call set1d(n,  b, one,unit)
      elseif ( name .eq. 's255 ' ) then
         call set1d(n,  a,zero,unit)
         call set1d(n,  b, one,unit)
      elseif ( name .eq. 's256 ' ) then
         call set1d(n, a, one,unit)
         call set2d(n,aa, two,unit)
         call set2d(n,bb, one,unit)
      elseif ( name .eq. 's257 ' ) then
         call set1d(n, a, one,unit)
         call set2d(n,aa, two,unit)
         call set2d(n,bb, one,unit)
      elseif ( name .eq. 's258 ' ) then
         call set1d(n,  a, any,frac)
         call set1d(n,  b,zero,unit)
         call set1d(n,  c, any,frac)
         call set1d(n,  d, any,frac)
         call set1d(n,  e,zero,unit)
         call set2d(n, aa, any,frac)
      elseif ( name .eq. 's261 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, any,frac2)
         call set1d(n,  c, any,frac2)
         call set1d(n,  d, one,unit)
      elseif ( name .eq. 's271 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, any,frac)
         call set1d(n,  c, any,frac)
      elseif ( name .eq. 's272 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, one,unit)
         call set1d(n,  c, any,frac)
         call set1d(n,  d, any,frac)
         call set1d(n,  e, two,unit)
      elseif ( name .eq. 's273 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, one,unit)
         call set1d(n,  c, one,unit)
         call set1d(n,  d,small,unit)
         call set1d(n,  e, any,frac)
      elseif ( name .eq. 's274 ' ) then
         call set1d(n,  a,zero,unit)
         call set1d(n,  b, one,unit)
         call set1d(n,  c, one,unit)
         call set1d(n,  d, any,frac)
         call set1d(n,  e, any,frac)
      elseif ( name .eq. 's275 ' ) then
         call set2d(n,aa, one,unit)
         call set2d(n,bb,small,unit)
         call set2d(n,cc,small,unit)
      elseif ( name .eq. 's276 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, any,frac)
         call set1d(n,  c, any,frac)
         call set1d(n,  d, any,frac)
      elseif ( name .eq. 's277 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n/2,b, one,unit)
         call set1d(n/2,b(n/2+1),-one,unit)
         call set1d(n,  c, any,frac)
         call set1d(n,  d, any,frac)
         call set1d(n,  e, any,frac)
      elseif ( name .eq. 's278 ' ) then
         call set1d(n/2,a,-one,unit)
         call set1d(n/2,a(n/2+1),one,unit)
         call set1d(n,  b, one,unit)
         call set1d(n,  c, any,frac)
         call set1d(n,  d, any,frac)
         call set1d(n,  e, any,frac)
      elseif ( name .eq. 's279 ' ) then
         call set1d(n/2,a,-one,unit)
         call set1d(n/2,a(n/2+1),one,unit)
         call set1d(n,  b, one,unit)
         call set1d(n,  c, any,frac)
         call set1d(n,  d, any,frac)
         call set1d(n,  e, any,frac)
      elseif ( name .eq. 's2710' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, one,unit)
         call set1d(n,  c, any,frac)
         call set1d(n,  d, any,frac)
         call set1d(n,  e, any,frac)
      elseif ( name .eq. 's2711' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, any,frac)
         call set1d(n,  c, any,frac)
      elseif ( name .eq. 's2712' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, any,frac)
         call set1d(n,  c, any,frac)
      elseif ( name .eq. 's281 ' ) then
         call set1d(n,  a,zero,unit)
         call set1d(n,  b, one,unit)
         call set1d(n,  c, one,unit)
      elseif ( name .eq. 's291 ' ) then
         call set1d(n,  a,zero,unit)
         call set1d(n,  b, one,unit)
      elseif ( name .eq. 's292 ' ) then
         call set1d(n,  a,zero,unit)
         call set1d(n,  b, one,unit)
      elseif ( name .eq. 's293 ' ) then
         call set1d(n,  a, any,frac)
      elseif ( name .eq. 's2101' ) then
         call set2d(n,aa, one,unit)
         call set2d(n,bb, any,frac)
         call set2d(n,cc, any,frac)
      elseif ( name .eq. 's2102' ) then
         call set2d(n,aa,zero,unit)
      elseif ( name .eq. 's2111' ) then
         call set2d(n,aa,zero,unit)
      elseif ( name .eq. 's311 ' ) then
         call set1d(n,  a, any,frac)
      elseif ( name .eq. 's312 ' ) then
         call set1d(n,a,1.000001,unit)
      elseif ( name .eq. 's313 ' ) then
         call set1d(n,  a, any,frac)
         call set1d(n,  b, any,frac)
      elseif ( name .eq. 's314 ' ) then
         call set1d(n,  a, any,frac)
      elseif ( name .eq. 's315 ' ) then
         call set1d(n,  a, any,frac)
      elseif ( name .eq. 's316 ' ) then
         call set1d(n,  a, any,frac)
      elseif ( name .eq. 's317 ' ) then
         continue
      elseif ( name .eq. 's318 ' ) then
         call set1d(n,  a, any,frac)
         a(n) = -two
      elseif ( name .eq. 's319 ' ) then
         call set1d(n,  a,zero,unit)
         call set1d(n,  b,zero,unit)
         call set1d(n,  c, any,frac)
         call set1d(n,  d, any,frac)
         call set1d(n,  e, any,frac)
      elseif ( name .eq. 's3110' ) then
         call set2d(n,aa, any,frac)
         aa(n,n) = two
      elseif ( name .eq. 's3111' ) then
         call set1d(n,  a, any,frac)
      elseif ( name .eq. 's3112' ) then
         call set1d(n,  a, any,frac2)
         call set1d(n,  b,zero,unit)
      elseif ( name .eq. 's3113' ) then
         call set1d(n,  a, any,frac)
         a(n) = -two
      elseif ( name .eq. 's321 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b,zero,unit)
      elseif ( name .eq. 's322 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b,zero,unit)
         call set1d(n,  c,zero,unit)
      elseif ( name .eq. 's323 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, one,unit)
         call set1d(n,  c, any,frac)
         call set1d(n,  d, any,frac)
         call set1d(n,  e, any,frac)
      elseif ( name .eq. 's331 ' ) then
         call set1d(n,  a, any,frac)
         a(n) = -one
      elseif ( name .eq. 's332 ' ) then
         call set1d(n,  a, any,frac2)
         a(n) = two
      elseif ( name .eq. 's341 ' ) then
         call set1d(n,  a,zero,unit)
         call set1d(n,  b, any,frac)
      elseif ( name .eq. 's342 ' ) then
         call set1d(n,  a, any,frac)
         call set1d(n,  b, any,frac)
      elseif ( name .eq. 's343 ' ) then
         call set2d(n,aa, any,frac)
         call set2d(n,bb, one,unit)
      elseif ( name .eq. 's351 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, one,unit)
         c(1) = 1.
      elseif ( name .eq. 's352 ' ) then
         call set1d(n,  a, any,frac)
         call set1d(n,  b, any,frac)
      elseif ( name .eq. 's353 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, one,unit)
         c(1) = 1.
      elseif ( name .eq. 's411 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, any,frac)
         call set1d(n,  c, any,frac)
      elseif ( name .eq. 's412 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, any,frac)
         call set1d(n,  c, any,frac)
      elseif ( name .eq. 's413 ' ) then
         call set1d(n,  a,zero,unit)
         call set1d(n,  b, one,unit)
         call set1d(n,  c, one,unit)
         call set1d(n,  d, any,frac)
         call set1d(n,  e, any,frac)
      elseif ( name .eq. 's414 ' ) then
         call set2d(n,aa, one,unit)
         call set2d(n,bb, any,frac)
         call set2d(n,cc, any,frac)
      elseif ( name .eq. 's415 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, any,frac)
         call set1d(n,  c, any,frac)
         a(n) = -one
      elseif ( name .eq. 's421 ' ) then
         call set1d(n,  a, any,frac2)
      elseif ( name .eq. 's422 ' ) then
         call set1d(n,array,one,unit)
         call set1d(n,  a, any,frac2)
      elseif ( name .eq. 's423 ' ) then
         call set1d(n,array,zero,unit)
         call set1d(n,  a, any,frac2)
      elseif ( name .eq. 's424 ' ) then
         call set1d(n,array,one,unit)
         call set1d(n,  a, any,frac2)
      elseif ( name .eq. 's431 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, any,frac2)
      elseif ( name .eq. 's432 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, any,frac2)
      elseif ( name .eq. 's441 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, any,frac)
         call set1d(n,  c, any,frac)
         call set1d(n/3,   d(1),        -one,unit)
         call set1d(n/3,   d(1+n/3),    zero,unit)
         call set1d(n/3+1, d(1+(2*n/3)), one,unit)
      elseif ( name .eq. 's442 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, any,frac)
         call set1d(n,  c, any,frac)
         call set1d(n,  d, any,frac)
         call set1d(n,  e, any,frac)
      elseif ( name .eq. 's443 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, any,frac)
         call set1d(n,  c, any,frac)
      elseif ( name .eq. 's451 ' ) then
         call set1d(n,  b, any,frac)
         call set1d(n,  c, any,frac)
      elseif ( name .eq. 's452 ' ) then
         call set1d(n,  a,zero,unit)
         call set1d(n,  b, one,unit)
         call set1d(n,  c,small,unit)
      elseif ( name .eq. 's453 ' ) then
         call set1d(n,  a,zero,unit)
         call set1d(n,  b, any,frac2)
      elseif ( name .eq. 's471 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, one,unit)
         call set1d(n,  c, one,unit)
         call set1d(n,  d, any,frac)
         call set1d(n,  e, any,frac)
      elseif ( name .eq. 's481 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, any,frac)
         call set1d(n,  c, any,frac)
         call set1d(n,  d, any,frac)
      elseif ( name .eq. 's482 ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, any,frac)
         call set1d(n,  c, any,frac)
      elseif ( name .eq. 's491 ' ) then
         call set1d(n,  a,zero,unit)
         call set1d(n,  b, one,unit)
         call set1d(n,  c, any,frac)
         call set1d(n,  d, any,frac)
      elseif ( name .eq. 's4112' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, any,frac)
      elseif ( name .eq. 's4113' ) then
         call set1d(n,  a,zero,unit)
         call set1d(n,  b, one,unit)
         call set1d(n,  c, any,frac2)
      elseif ( name .eq. 's4114' ) then
         call set1d(n,  a,zero,unit)
         call set1d(n,  b, one,unit)
         call set1d(n,  c, any,frac)
         call set1d(n,  d, any,frac)
      elseif ( name .eq. 's4115' ) then
         call set1d(n,  a, any,frac)
         call set1d(n,  b, any,frac)
      elseif ( name .eq. 's4116' ) then
         call set1d(n, a, any,frac)
         call set2d(n,aa, any,frac)
      elseif ( name .eq. 's4117' ) then
         call set1d(n,  a,zero,unit)
         call set1d(n,  b, one,unit)
         call set1d(n,  c, any,frac)
         call set1d(n,  d, any,frac)
      elseif ( name .eq. 's4121' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, any,frac)
         call set1d(n,  c, any,frac)
      elseif ( name .eq. 'va   ' ) then
         call set1d(n,  a,zero,unit)
         call set1d(n,  b, any,frac2)
      elseif ( name .eq. 'vag  ' ) then
         call set1d(n,  a,zero,unit)
         call set1d(n,  b, any,frac2)
      elseif ( name .eq. 'vas  ' ) then
         call set1d(n,  a,zero,unit)
         call set1d(n,  b, any,frac2)
      elseif ( name .eq. 'vif  ' ) then
         call set1d(n,  a,zero,unit)
         call set1d(n,  b, any,frac2)
      elseif ( name .eq. 'vpv  ' ) then
         call set1d(n,  a,zero,unit)
         call set1d(n,  b, any,frac2)
      elseif ( name .eq. 'vtv  ' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, one,unit)
      elseif ( name .eq. 'vpvtv' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, any,frac)
         call set1d(n,  c, any,frac)
      elseif ( name .eq. 'vpvts' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, any,frac2)
      elseif ( name .eq. 'vpvpv' ) then
         call set1d(n,  a, any,frac2)
         call set1d(n,  b, one,unit)
         call set1d(n,  c,-one,unit)
      elseif ( name .eq. 'vtvtv' ) then
         call set1d(n,  a, one,unit)
         call set1d(n,  b, two,unit)
         call set1d(n,  c,half,unit)
      elseif ( name .eq. 'vsumr' ) then
         call set1d(n,  a, any,frac)
      elseif ( name .eq. 'vdotr' ) then
         call set1d(n,  a, any,frac)
         call set1d(n,  b, any,frac)
      elseif ( name .eq. 'vbor ' ) then
         call set1d(n,  a, any,frac)
         call set1d(n,  b, any,frac)
         call set1d(n,  c, one,frac)
         call set1d(n,  d, two,frac)
         call set1d(n,  e,half,frac)
         call set2d(n, aa, any,frac)
      else
        stop 'init: unknown kernel'
      endif

      return
      end
      subroutine s471s
      return
      end
