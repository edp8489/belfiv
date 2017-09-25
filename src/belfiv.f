      PROGRAM BELFIV
C
C....... THIS IS THE BELFIV PROGRAM ------- VERSION 3.3
C        THIS PROGRAM CALCULATES THE MODAL FREQUENCIES, FLOW EXCITATION
C        RANGES, AND THE FLOW-INDUCED STRESSES FOR THE LONGITUDINAL
C        MODES AND THE CONVOLUTE BENDING MODE IN A METAL BELMWS.
C        THIS PROGRAM APPLIES TO BOTH LIQUID AND GAS FLOWS. IN THE
C        CASE OF GAS FLOWS,
C        MODE FREQUENCY AND VELOCITY. THIS PROGRAM, HOWEVER, DOES NOT
C        CONDUCT FLOW-INDUCED VIBRATION ANALYSIS FOR A FLEXHOSE AND
C        DOES NOT CALCULATE STATIC STRESSES IN A BELLOWS.
C        IT ALSO CALCüLATES THE FIRST RADIAL ACOUSTIC
C
C        THIS PROGRAM WAS WRITTEN TO OPERATE ON AN IBM-XT COMPUTER
C        WITH A FORTRAN COMPILER WRITTEN BY RYAN-MCFARLAND CORPORATION.
C 
C        THE FOLLOWING PARAMETERS ARE USED: 
C
C        JFLAG = 1(C0MPUTE KA), 2(USE GIVEN KA). KA IS THE OVERALL
C           BELLOWS SPRING RATE, LBF/IN
C        NFLUID = 1(GAS), 2(LIQUID)
C        NDEG = NUMBER OF BELLOWS LONGITUDINAL DEGREES OF FREEDON, 2*NC-1
C        NC = NUMBER OF BELLOWS CONVOLUTES COUNTED FROM THE OUTSIDE
C        SIGMA = INSIDE CONVOLUTE WIDTH, IN.
C        LAMBDA = INSIDE CONVOLUTE PITCH, IN. L
C        H = MEAN INSIDE CONVOLUTE HEIGHT, IN.
C        T = CONVOLUTE THICKNESS PER PLY, IN. I
C        NPLY = NUMBER OF PLYS IN THE BELLOWS CONVOLUTES
C        DI = BELLOWS INSIDE DIAMETER, IN. 
C        DU = BELLOWS OUTSIDE DIAMETER, IN.
C        E = YOUNG'S MODULUS OF THE BELLQWS MATERIAL, LB/SQ IN.
C        RHOM = WEIGHT DENSITY OF THE BELLOWS MATERIAL, LBF/CU IN.
C        LOVERD = LENGTH FROM TERMINATION OF ELBOW TO FIRST CONVOLUTE 
C          DIVIDED BY THE I.D. OF PIPE JUST BEFORE THE BELLOW, NON-DIM
C        CE = DIMENSIONLESS ELBOW FACTOR
C        IF NFLUID = 1(GAS), THE PERFECT GAS EQUATION OF STATE IS USED
C           FOR CALCULATING GAS DENSITY AT THE STATE DEFINED BY P AND TEMP.
C           IT IS ASSUMED THAT THE GAS PROPERTIES ARE KNOWN AT A REFERENCE
C           STATE DEFINED BY RHOREF, PREF, AND TREF.
C           P = GAS PRESSURE, PSIG
C           TEMP = GAS TEMPERATURE, DEG. F.
C           PREF AND TREF = REFERENCE GAS STATE, PSIA AND DEG. F.
C           RHOREF = UEIGHT DENSITY OF GAS AT REFERENCE STATE, LBF/CU FT.
C           Z = GAS COMPRESSIBILITY FACTOR, NON-DIM.
C           ZREF = GAS COMPRESSIBILITY FACTOR AT REFERENCE STATE, NON-DIM
C           GAMMA = SPECIFIC HEAT RATIO FOR THE GAS, NON-DIM
C        IF NFLUID = 2(LIQUID), THE LIQUID DENSITY MUST BE KNOWN APRIORI
C           AT THE LIQUID STATE (P AND TEMP).
C           P = LIQUID PRESSURE, PSIG
C           TEMP = LIQUID TEMPERA-, DEG. F.
C           RHOF = WEIGHT DENSITY OF LIQUID AT P AND TEMP, LBF/CU FT. 
C * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
      IMPLICIT REAL(A-H,O-Z)
      REAL MODER,MASS,MFLUID,MFLUDR,MMETAL,MASSR
      REAL KA,K,N1,LOVERD,NC,NPLY,LAMBDA,FLUID1,FLUID2
      INTEGER*2 ANS,DEV
      CHARACTER*5 TITLE(80),DFILE(20),OFILE(20)
      DIMENSION FREQ(75),V(75,3),FISC(75)
C 
C...... SET DATA FILES
C
      WRITE(6,5)
    5 FORMAT(1X,'DID YOU SET OUTPUT AND INPUT FILE NAMES ?'/
     $' (YES=1,NO=2)'/)
      READ(5,*) NAM
      GO TO (20,10),NAM
   10 WRITE(6,25)
   15 FORMAT(1X,'RETURN TO DOS ENVIRONMENT TO SET FILE NAMES.'/
     $' (SET DFILE=input.DAT)'/' (SET OFILE=output.DAT)')
      GO TO 2000
   20 WRITE(6,25)
   25 FORMAT(1X,'WILL THE INPUT DATA BE FROM THE KEYBOARD OR FILE ?'/
     $' KEYBOARD=1,FILE=2'/)
      READ(5,*) INP
      GO TO (30,220),INP
C
C...... INPUT DATA FROM KEYBOARD
C
   30 WRITE(6,35)
   35 FORMAT(1X,'HOW DO YOU IDENTIFY THIS BELLOWS ?',/)
      READ(5,40) (TITLE(I),I=1,70)
   40 FORMAT(70A1)
      WRITE(6,45)
   45 FORMAT(1X,'COMPUTE OR USE GIVEN SPRING RATE ?'/
     $' 1 (COMPUTE KA), 2 (USE GIVEN KA)'/)
      READ(5,*) JFLAG
      GO TO (60,50),JFLAG
   50 WRITE(6,55)
   55 FORMAT(1X,'OVERALL BELLOWS SPRING RATE, LBF/IN. ?'/)
      READ(5,*) KA
   60 CONTINUE
      WRITE(6,65)
   65 FORMAT(1X,'IS THE FLUID A GAS OR LIQUID?'/
     $' 1 (GAS), 2 (LIQUID)'/)
      READ(5,*) NFLUID
      WRITE(6,70)
   70 FORMAT(1X,'NUMBER OF BELLOWS CONVOLUTES COUNTED FROM THE OUTSIDE
     $?'/)
      READ(5,*) NC
      NDEG = 2*NC-1
      WRITE(6,75)
   75 FORMAT(1X,'NUMBER OF PLYS IN THE BELLOWS CONVOLUTES ?'/)
      READ(5,*) NPLY
      WRITE(6,80)
   80 FORMAT(1X,'INSIDE CONVOLUTE WIDTH, IN. ?'/)
      READ(5,*) SIGMA
      WRITE(6,85)
   85 FORMAT(1X,'INSIDE CONVOLUTE PITCH, IN. ?'/)
      READ(5,*) LAMBDA
      WRITE(6,90)
   90 FORMAT(1X,'MEAN INSIDE CONVOLUTE HEIGHT, IN. ?'/)
      READ(5,*) H
      WRITE(6,95)
   95 FORMAT(1X,'CONVOLUTE THICKNESS PER PLY, IN. ?'/)
      READ(5,*) T
      WRITE(6,100)
  100 FORMAT(1X,'BELLOWS INSIDE DIAMETER, IN. ?'/)
      READ(5,*) DI
      WRITE(6,105)
  105 FORMAT(1X,'BELLOWS OUTSIDE DIAMETER, IN. ?'/)
      READ(5,*) DU
      WRITE(6,110)
  110 FORMAT(1X,'YOUNGS MODULUS FOR BELLOWS MATERIAL, LB/SQ IN. ?'/)
      READ(5,*) E
      WRITE(6,115)
  115 FORMAT(1X,'WEIGHT DENSITY OF THE BELLOWS MATERIAL, LBF/CU IN. ?'/)
      READ(5,*) RHOM
      WRITE(6,120)
  120 FORMAT(1X,'LENGTH FROM TERMINATION OF ELBOW TO FIRST CONVOLUTE'/
     $' DIVIDED BY THE I.D. OF PIPE JUST BEFORE THE BELLOW ?(INPUT 0 IF
     $NO ELBOW)'/)
      READ(5,*) LOVERD
      GO TO (125,160),NFLUID
  125 WRITE(6,130)
  130 FORMAT(1X,'GAS PRESSURE, PSIG ?'/)
      READ(5,*) P
      WRITE(6,135)
  135 FORMAT(1X,'GAS TEMPERATURE, DEG. F ?'/)
      READ(5,*) TEMP
      WRITE(6,140)
  140 FORMAT(1X,'GAS PRESSURE AT REFERENCE STATE, PSIA ?'/)
      READ(5,*) PREF
      WRITE(6,145)
  145 FORMAT(1X,'GAS TEMPERATURE AT REFERENCE STATE, DEG. F ?'/)
      READ(5,*) TREF
      WRITE(6,150)
  150 FORMAT(1X,'WEIGHT DENSITY OF GAS AT REFERENCE STATE, LBF/CU FT. ?'
     $/)
      READ(5,*) RHOREF
      WRITE(6,151)
  151 FORMAT(1X,'GAS COMPRESSIBILITY FACTOR, NON-DIM ?'/)
      READ(5,*) Z
      WRITE(6,152)
  152 FORMAT(1X,'GAS COMPRESSIBILITY FACTOR AT REFERENCE STATE, NON-DIM.
     $ ?'/)
      READ(5,*) ZREF
      WRITE(6,155)
  155 FORMAT(1X,'SPECIFIC HEAT RATIO FOR THE GAS, NON-DIM. ?'/)
      READ(5,*) GAMMA
      GO TO 180
  160 WRITE(6,165)
  165 FORMAT(1X,'LIQUID PRESSURE, PSIG ?'/)
      READ(5,*) P
      WRITE(6,170)
  170 FORMAT(1X,'LIQUID TEMPERATURE, DEG.F ?'/)
      READ(5,*) TEMP
      WRITE(6,175)
  175 FORMAT(1X,'WEIGHT DENSITY OF LIQUID AT THE LIQUID STATE (P AND TEM
     $P), LBF/CU FT. ?'/)
      READ(5,*) RHOF
C
C...... SAVE INPUT DATA FROM KEYBOARD
C
  180 WRITE(6,185)
  185 FORMAT(1X,'DO YOU WISH TO SAVE THE INPUT DATA ? (YES=1, NO=2)'/)
      READ(5,*) NSAVE
      IF(NSAVE .EQ. 2) GO TO 250
      OPEN (UNIT=10, FILE='DFILE')
      WRITE(10,225)(TITLE(I),I=1,70)
      WRITE(10,230)JFLAG,NFLUID,NDEG
      WRITE(10,235)NC,NPLY,SIGMA,LAMBDA,H,T
      IF (JFLAG .EQ. 1) KA=0.0
      WRITE(10,236)DI,DU,E,RHOM,KA,LOVERD
      GO TO (200,210),NFLUID
  200 WRITE(10,241)P,TEMP,PREF,TREF,RHOREF
      WRITE(10,242)Z,ZREF,GAMMA
      GO TO 250
  210 WRITE(10,242)P,TEMP,RHOF
      GO TO 250
C
C...... INPUT DATA FROM FILE
C
  220 OPEN (UNIT=7, FILE='DFILE')
      READ(7,225)(TITLE(I),I=1,70)
  225 FORMAT(70A1)
      READ(7,230)JFLAG,NFLUID,NDEG
  230 FORMAT(3I3)
      READ(7,235)NC,NPLY,SIGMA,LAMBDA,H,T
      READ(7,236)DI,DU,E,RHOM,KA,LOVERD
  235 FORMAT(6F10.3)
  236 FORMAT(2F10.3,F10.0,3F10.3)
      GO TO (240,245),NFLUID
  240 READ(7,241)P,TEMP,PREF,TRED,RHOREF
  241 FORMAT(5F10.4)
      READ(7,242)Z,ZREF,GAMMA
  242 FORMAT(3F10.3)
      GO TO 250
  245 READ(7,242)P,TEMP,RHOF
  250 CONTINUE
      PI=3.1415927
      G=32.174049
      DMEAN=(DI+DU)/2.0
      GO TO (400,405),JFLAG
C
C...... CALCULATION OF SPRING RATE
C
  400 KA=DMEAN*E*(NPLY/NC)*(T/H)**3
  405 K=2.*NC*KA
C
C...... CALCULATION OF METAL MASS AND FLUID MASS
C
      A=(SIGMA-T*NPLY)/2.
      MMETAL=PI*RHOM*T*NPLY*DMEAN*(PI*A+H-2.*A)/G
      GO TO (410,415),NFLUID
  410 RHOF=(RHOREF/1728.)*((P+14.7)/PREF)*((TREF+460.)/(TEMP+460.))*
     $(ZREF/Z)
      GO TO 420
  415 RHOF=RHOF/1728.
  420 FLUID1=PI*RHOF*DMEAN*H*(2.*A-T*NPLY)/(2.*G)
      DELTA=LAMBDA-SIGMA
      FLUID2=RHOF*DMEAN*(H**3)/(G*DELTA)
C
C...... CALCULATION OF CRITICAL FREQUENCY AND VELOCITY (AT MODE N=NC)
C
      STUP=0.3
      STLO=0.1
      STCRIT=0.2
      MODER=NC
      MFLUDR=1.0*FLUID1 + 0.68*(FLUID2*MODER)/NC
      MASSR=MFLUDR+MMETAL
      FO=(1./(2.*PI))*SQRT(12.*K/MASSR)
      FREQC=FO*SQRT(2.)
      VELC=FREQC*SIGMA/(STCRIT*12.)
C
C...... CALCULATION OF FREQ. AND VEL. RANGE FOR LONGITUDINAL MODES
C
      DO 440 MODE=1,NDEG
      MFLUID=1.0*FLUID1 + 0.68*FLUID2*(MODE/NC)
      MASS=MFLUID+MMETAL
      BN=SQRT(2.*(1.+COS((PI*(2.*NC-MODE))/(2.*NC))))
      FO=(1./(2*PI))*SQRT(12.*K/MASS)
      FREQ(MODE)=FO*BN
      DO 440 J=1,3
      GO TO (425,430,435),J
  425 V(MODE,J)=FREQ(MODE)*SIGMA/(STUP*12.)
      GO TO 440
  430 V(MODE,J)=FREQ(MODE)*SIGMA/(STCRIT*12.)
      GO TO 440
  435 V(MODE,J)=FREQ(MODE)*SIGMA/(STLO*12.)
  440 CONTINUE
C
C...... CALCULATION OF FIRST RADIAL ACOUSTIC MODE (GAS MEDIA ONLY)
C
      GO TO (600,615), NFLUID
  600 RI=DI/2.
      HRI=H/RI
      CO=SQRT(GAMMA*(P+14.7)*G/(RHOF*12.))
      IF(HRI.LE.0.40) GO TO 605
      FNCO=-.336+.935*(RI/H)
      GO TO 610
  605 FNCO=3.8-16.72*(HRI**2)+13.67*(HRI**3)
  610 FREQCO=12.*FNCO*CO/(2.*PI*RI)
      QADJUS=5.0
      VELCO=FREQCO*SIGMA/(STCRIT*12.)
C
C...... CALCULATION OF FLOW-INDUCED STRESS FOR LONGITUDINAL MODES
C
  615 SSR=KA*NC/(DMEAN*NPLY)
      C1=.13
      C2=.462
      C3=1.0
      C4=10.0
      C5=.06
      C6=1.25
      C7=5.5
      N1=1.0
      IF(LOVERD.EQ.0.0) N1=0.0
      CE=1.+(N1*4.7/(2.+LOVERD))
      DO 655 MODE=1,NDEG
      VP=V(MODE,2)/VELC
      IF(NPLY.GT.1.) GO TO 620
      CNP=1.0
      GO TO 625
  620 CNP=1.0-((C6*SIGMA/H)/(1.0+C7*VP**2))
  625 BB=C1/(C2+VP**2)
      CC=C3*ABS(SIN(PI*VP))/(C4+VP**2)
      CST=BB+CC+C5
      PD=12.0*RHOF*(V(MODE,2)**2)/(2.0*G)
      DD=CST*T*PD/(VP*SSR*DELTA)
      EE=1.0+0.1*((400.0/SSR)**2)
      FIS=EE*DD*E*CNP*CE/NPLY
C
C...... UNCERTAINTY FACTORS FOR STRESS (LONGITUDINAL MODES)
C
      GO TO (630,635), NFLUID
  630 IF (FREQ(MODE).GE.FREQCO) FIS=FIS*QADJUS*1.5
  635 CONTINUE
      GO TO (640,645), JFLAG
  640 FIS=FIS*2.0
      GO TO 650
  645 FIS=FIS*1.5
  650 CONTINUE
      FISC(MODE)=FIS
  655 CONTINUE
C
C...... CALCULATION OF FREQ. AND VEL. RANGE FOR CONVOLUTE BENDING MODE
C
      FREQCB=(1./(2.*PI))*SQRT(8.*K*12./(MMETAL+.68*FLUID2))
      VCBLOW=FREQCB*SIGMA/(STUP*12.)
      VCBSTAR=FREQCB*SIGMA/(STCRIT*12.)
      VCBUP=FREQCB*SIGMA/(STLO*12.)
C
C...... CALCULATION OF FLOW-INDUCED STRESS FOR CONVOLUTE BENDING MODE
C
      VP=VCBSTAR/VELC
      IF (NPLY.GT.1) GO TO 660
      CNP=1.0
      GO TO 665
  660 CNP=1.0-((C6*SIGMA/h)/(1.0+C7*VP**2))
  665 CST=0.4
      PD=12.0*RHOF*(VCBSTAR**2)/(2.0*G)
      DD=CST*T*PD/(VP*SSR*DELTA)
      FIS=EE*DD*E*CNP*CE/NPLY
C
C...... UNCERTAINTY FACTORS FOR STRESS (CONVOLUTE BENDING MODE)
C
      GO TO (670,675), NFLUID
  670 IF (FREQCB.GE.FREQCO) FIS=FIS*QADJUS*1.5
  675 CONTINUE
      GO TO (680,685) JFLAG
  680 FIS=FIS*2.0
      GO TO 690
  685 FIS=FIS*1.5
  690 CONTINUE
      FISCB=FIS
C
C...... OUTPUT DATA
C
      DEV=6
  800 WRITE(DEV,805)(TITLE(I),I=1,70)
  805 FORMAT(1X,70A1)
      WRITE(DEV,840) SIGMA,LAMBDA,H,T,DI,DU,NC,NPLY,E
      WRITE(DEV,845) KA,RHOM,P,TEMP,RHOF,NFLUID,CE
      WRITE(DEV,850)
      DO 810 MODE=1,NDEG
  810 WRITE(DEV,855)MODE,FISC(MODE),FREQ(MODE),V(MODE,1),V(MODE,2),
     $V(MODE,3)
      WRITE(DEV,856)FISCB,FREQCB,VCBLOW,VCBSTAR,VCBUP
      GO TO (815,820), NFLUID
  815 WRITE(DEV,860) FREQCO
      WRITE(DEV,865) VELCO
  820 CONTINUE
  825 IF (DEV.EQ.8 .OR. DEV.EQ.9) GO TO 835
      WRITE(6,830)
  830 FORMAT(//,1X,'WHERE DO YOU WANT OUTPUT SENT? 0-EXIT,1-FILE,2-PRINT
     $ER'/)
      READ(5,*)ANS
      IF(ANS.EQ.0) GO TO 2000
      IF(ANS.EQ.1) DEV=8
      OPEN (UNIT=8, FILE='OFILE')
      IF(ANS.EQ.2) DEV=9
      OPEN (UNIT=9, FILE='LPT1')
      GO TO 800
  835 CONTINUE
  840 FORMAT(/,29X,18HBELLOWS PARAMETERS,//
     $       19X,33HSIGMA(INSIDE CONVOLUTE WIDTH, IN),4X,F6.3,/
     $       19X,34HLAMBDA(INSIDE CONVOLUTE PITCH, IN),3X,F6.3,/
     $       19X,35HH(MEAN INSIDE CONVOLUTE HEIGHT, IN),2X,F6.3,/
     $       19X,34HT(CONVOLUTE THICKNESS PER PLY, IN),3X,F6.3,/
     $       19X,23HDI(INSIDE DIAMETER, IN),14X,F6.3,/
     $       19X,24HDU(OUTSIDE DIAMETER, IN),13X,F6.3,/
     $       19X,24HNC(NUMBER OF CONVOLUTES),12X,F7.3,/
     $       19X,20HNPLY(NUMBER OF PLYS),16X,F7.3,/
     $       19X,27HE(YOUNGS MODULUS, LB/SQ.IN),5X,E11.4)
  845 FORMAT(19X,31HKA(OVERALL SPRING RATE, LBF/IN),1X,F11.3,/
     $       19X,33HRHOM(MATERIAL DENSITY, LBF/CU.IN),3X,F7.3,//
     $       30X,16HFLUID PARAMETERS,//
     $       19X,17HP(PRESSURE, PSIG),19X,F7.3,/
     $       19X,24HTEMP(TEMPERATURE, DEG F),11X,F8.3,/
     $       19X,30HRHOF(FLUID DENSITY, LBF/CU.IN),2X,E11.4,/
     $       19X,23HNFLUID(1=GAS, 2=LIQUID),19X,I1,/
     $       19X,'CE(ELBOW FACTOR, DIMENSIONLESS)',6X,F6.3///
     $       25X,'THEORETICAL BELLOWS PERFORMANCE',/)
  850 FORMAT(2X,78HLONG.    FLOW-IND. STRESS    MODE FREQUENCY    FLOW
     $ EXCITATION RANGE, FT/SEC,/,1X,8HMODE NO.,3X,14HWITH U.F., PSI,
     $11X,2HHZ,13X,5HLOWER,5X,8HCRITICAL,4X,5HUPPER,/)
  855 FORMAT(3X,I2,8X,E11.5,7X,F11.3,5X,3F11.3)
  856 FORMAT(//,1X,9HCONVOLUTE,/,2X,7HBENDING,/,3X,4HMODE,6X,E11.5,7X,
     $F11.3,5X,3F11.3)
  860 FORMAT(//,3X,'FIRST RADIAL ACOUSTIC MODE FREQUENCY=',F9.3,1X,
     $'HZ'/)
  865 FORMAT(3X,'FIRST RADIAL ACOUSTIC MODE VELOCITY=',F9.3,1X,
     $'FT/SEC'/)
 2000 CONTINUE
      END