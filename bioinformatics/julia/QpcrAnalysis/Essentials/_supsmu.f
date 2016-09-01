      subroutine supsmu (n,x,y,w,iper,span,alpha,smo,sc)
c
c------------------------------------------------------------------
c
c super-smoother.
c
c Friedman J.H. (1984). A variable span smoother. Department of Statistics,
c    Stanford University, Technical Report LCS5.
c
c version 10/10/84.
c
c coded  and copyright (c) 1984 by:
c
c                        Jerome H. Friedman
c                     Department of Statistics
c                               and
c                Stanford Linear Accelerator Center
c                        Stanford University
c
c all rights reserved.
c
c
c input:
c    n : number of observations (x,y - pairs).
c    x(n) : ordered abscissa values.
c    y(n) : corresponding ordinate (response) values.
c    w(n) : weight for each (x,y) observation.
c    iper : periodic variable flag.
c       iper=1 => x is ordered interval variable.
c       iper=2 => x is a periodic variable with values
c                 in the range (0.0,1.0) and period 1.0.
c    span : smoother span (fraction of observations in window).
c           span=0.0 => automatic (variable) span selection.
c    alpha : controles high frequency (small span) penality
c            used with automatic span selection (bass tone control).
c            (alpha.le.0.0 or alpha.gt.10.0 => no effect.)
c output:
c   smo(n) : smoothed ordinate (response) values.
c scratch:
c   sc(n,7) : internal working storage.
c
c note:
c    for small samples (n < 40) or if there are substantial serial
c    correlations between obserations close in x - value, then
c    a prespecified fixed span smoother (span > 0) should be
c    used. reasonable span values are 0.2 to 0.4.
c
c------------------------------------------------------------------
c
      dimension x(n),y(n),w(n),smo(n),sc(n,7)
      common /spans/ spans(3) /consts/ big,sml,eps
      if (x(n).gt.x(1)) go to 30
      sy=0.0
      sw=sy
      do 10 j=1,n
      sy=sy+w(j)*y(j)
      sw=sw+w(j)
 10   continue
      a=0.0
      if (sw.gt.0.0) a=sy/sw
      do 20 j=1,n
      smo(j)=a
 20   continue
      return
 30   i=n/4
      j=3*i
      scale=x(j)-x(i)
 40   if (scale.gt.0.0) go to 50
      if (j.lt.n) j=j+1
      if (i.gt.1) i=i-1
      scale=x(j)-x(i)
      go to 40
 50   vsmlsq=(eps*scale)**2
      jper=iper
      if (iper.eq.2.and.(x(1).lt.0.0.or.x(n).gt.1.0)) jper=1
      if (jper.lt.1.or.jper.gt.2) jper=1
      if (span.le.0.0) go to 60
      call smooth (n,x,y,w,span,jper,vsmlsq,smo,sc)
      return
 60   do 70 i=1,3
      call smooth (n,x,y,w,spans(i),jper,vsmlsq,sc(1,2*i-1),sc(1,7))
      call smooth (n,x,sc(1,7),w,spans(2),-jper,vsmlsq,sc(1,2*i),h)
 70   continue
      do 90 j=1,n
      resmin=big
      do 80 i=1,3
      if (sc(j,2*i).ge.resmin) go to 80
      resmin=sc(j,2*i)
      sc(j,7)=spans(i)
 80   continue
      if (alpha.gt.0.0.and.alpha.le.10.0.and.resmin.lt.sc(j,6).and.resmi
     1n.gt.0.0) sc(j,7)=sc(j,7)+(spans(3)-sc(j,7))*amax1(sml,resmin/sc(j
     2,6))**(10.0-alpha)
 90   continue
      call smooth (n,x,sc(1,7),w,spans(2),-jper,vsmlsq,sc(1,2),h)
      do 110 j=1,n
      if (sc(j,2).le.spans(1)) sc(j,2)=spans(1)
      if (sc(j,2).ge.spans(3)) sc(j,2)=spans(3)
      f=sc(j,2)-spans(2)
      if (f.ge.0.0) go to 100
      f=-f/(spans(2)-spans(1))
      sc(j,4)=(1.0-f)*sc(j,3)+f*sc(j,1)
      go to 110
 100  f=f/(spans(3)-spans(2))
      sc(j,4)=(1.0-f)*sc(j,3)+f*sc(j,5)
 110  continue
      call smooth (n,x,sc(1,4),w,spans(1),-jper,vsmlsq,smo,h)
      return
      end
      subroutine smooth (n,x,y,w,span,iper,vsmlsq,smo,acvr)
      dimension x(n),y(n),w(n),smo(n),acvr(n)
      integer in,out
      double precision wt,fbo,fbw,xm,ym,tmp,var,cvar,a,h,sy
      xm=0.0
      ym=xm
      var=ym
      cvar=var
      fbw=cvar
      jper=iabs(iper)
      ibw=0.5*span*n+0.5
      if (ibw.lt.2) ibw=2
      it=2*ibw+1
      do 20 i=1,it
      j=i
      if (jper.eq.2) j=i-ibw-1
      xti=x(j)
      if (j.ge.1) go to 10
      j=n+j
      xti=x(j)-1.0
 10   wt=w(j)
      fbo=fbw
      fbw=fbw+wt
      if (fbw.gt.0.0) xm=(fbo*xm+wt*xti)/fbw
      if (fbw.gt.0.0) ym=(fbo*ym+wt*y(j))/fbw
      tmp=0.0
      if (fbo.gt.0.0) tmp=fbw*wt*(xti-xm)/fbo
      var=var+tmp*(xti-xm)
      cvar=cvar+tmp*(y(j)-ym)
 20   continue
      do 80 j=1,n
      out=j-ibw-1
      in=j+ibw
      if ((jper.ne.2).and.(out.lt.1.or.in.gt.n)) go to 60
      if (out.ge.1) go to 30
      out=n+out
      xto=x(out)-1.0
      xti=x(in)
      go to 50
 30   if (in.le.n) go to 40
      in=in-n
      xti=x(in)+1.0
      xto=x(out)
      go to 50
 40   xto=x(out)
      xti=x(in)
 50   wt=w(out)
      fbo=fbw
      fbw=fbw-wt
      tmp=0.0
      if (fbw.gt.0.0) tmp=fbo*wt*(xto-xm)/fbw
      var=var-tmp*(xto-xm)
      cvar=cvar-tmp*(y(out)-ym)
      if (fbw.gt.0.0) xm=(fbo*xm-wt*xto)/fbw
      if (fbw.gt.0.0) ym=(fbo*ym-wt*y(out))/fbw
      wt=w(in)
      fbo=fbw
      fbw=fbw+wt
      if (fbw.gt.0.0) xm=(fbo*xm+wt*xti)/fbw
      if (fbw.gt.0.0) ym=(fbo*ym+wt*y(in))/fbw
      tmp=0.0
      if (fbo.gt.0.0) tmp=fbw*wt*(xti-xm)/fbo
      var=var+tmp*(xti-xm)
      cvar=cvar+tmp*(y(in)-ym)
 60   a=0.0
      if (var.gt.vsmlsq) a=cvar/var
      smo(j)=a*(x(j)-xm)+ym
      if (iper.le.0) go to 80
      h=0.0
      if (fbw.gt.0.0) h=1.0/fbw
      if (var.gt.vsmlsq) h=h+(x(j)-xm)**2/var
      acvr(j)=0.0
      a=1.0-w(j)*h
      if (a.le.0.0) go to 70
      acvr(j)=abs(y(j)-smo(j))/a
      go to 80
 70   if (j.le.1) go to 80
      acvr(j)=acvr(j-1)
 80   continue
      j=1
 90   j0=j
      sy=smo(j)*w(j)
      fbw=w(j)
      if (j.ge.n) go to 110
 100  if (x(j+1).gt.x(j)) go to 110
      j=j+1
      sy=sy+w(j)*smo(j)
      fbw=fbw+w(j)
      if (j.lt.n) go to 100
 110  if (j.le.j0) go to 130
      a=0.0
      if (fbw.gt.0.0) a=sy/fbw
      do 120 i=j0,j
      smo(i)=a
 120  continue
 130  j=j+1
      if (j.le.n) go to 90
      return
      end
      block data
      common /spans/ spans(3) /consts/ big,sml,eps
c
c---------------------------------------------------------------
c
c this sets the compile time (default) values for various
c internal parameters :
c
c spans : span values for the three running linear smoothers.
c spans(1) : tweeter span.
c spans(2) : midrange span.
c spans(3) : woofer span.
c (these span values should be changed only with care.)
c big : a large representable floating point number.
c sml : a small number. should be set so that (sml)**(10.0) does
c       not cause floating point underflow.
c eps : used to numerically stabilize slope calculations for
c       running linear fits.
c
c these parameter values can be changed by declaring the
c relevant labeled common in the main program and resetting
c them with executable statements.
c
c-----------------------------------------------------------------
c
      data spans,big,sml,eps /0.05,0.2,0.5,1.0e20,1.0e-7,1.0e-3/
      end