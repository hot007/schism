!   Copyright 2014 College of William and Mary
!
!   Licensed under the Apache License, Version 2.0 (the "License");
!   you may not use this file except in compliance with the License.
!   You may obtain a copy of the License at
!
!     http://www.apache.org/licenses/LICENSE-2.0
!
!   Unless required by applicable law or agreed to in writing, software
!   distributed under the License is distributed on an "AS IS" BASIS,
!   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
!   See the License for the specific language governing permissions and
!   limitations under the License.

module icm_mod
!-------------------------------------------------------------------------------
!parameter definition for ICM
!Warning: most column arrays index from surface to bottom!
!-------------------------------------------------------------------------------
  use schism_glbl,only: rkind,nvrt,nea
  implicit none

  !integer, parameter ::iT=2
  !real(rkind), parameter :: CV1=1.0E8
  !real(rkind), parameter :: CV2=1.0E8
  real(rkind), parameter :: COV=1.0d-10
  !molar weight for C,Ca,CaCo3,N
  real(rkind), parameter :: mC=12.011,mCACO3=100.086,mN=14.007


  !time step in ICM [days]
  real(rkind), save :: dtw,dtw2 !dtw2=dtw/2

  !time stamp for WQinput
  real(rkind),save:: time_icm(5),time_ph
  
  !global switch 
  integer,save :: iSun,iNPS,iPS
  integer,save :: iLight,jLight,iRad
  integer,save :: iSed,iRea,iBen,iTBen
  integer,save :: iZoo,iPh
  integer,save :: iAtm,iCheck,iout_icm
  integer,save :: iSet !,iTurb,iWRea,iTSS 
  integer,save :: isav_icm,iveg_icm !ncai_sav, ncai_veg 
  integer,save :: isfnveg,isrecnveg,isfpveg,isrecpveg !ncai_veg
  integer,save :: idry_icm
 
!  !ICM region
!  integer,save,allocatable :: reg_icm(:) !nea

  !water quality state variables
  real(rkind),save,allocatable,dimension(:,:,:) :: wqc
  !dep(1:nv=nvrt-kbe) (1- surface). dep(k) is Layer thickness btw level nvrt-k and nvrt-k+1
  real(rkind),save,allocatable,dimension(:) :: dep,Sal,Temp,TSED 
  real(rkind),save,allocatable,dimension(:,:) :: ZB1,ZB2,PB1,PB2,PB3,RPOC,LPOC,DOC,RPON,LPON,DON,NH4,NO3
  real(rkind),save,allocatable,dimension(:,:) :: RPOP,LPOP,DOP,PO4t,SU,SAt,COD,DOO

  !ncai_sav + ncai_veg :: uniformed vegetation height, density
  real(rkind),save,allocatable,dimension(:) :: tthcan,ttdens !(nea) 

  !ncai_sav
  !(nvrt,nea)>> bottom to surface
  real(rkind),save,allocatable,dimension(:,:) :: lfsav,stsav,rtsav !(nvrt,nea), unit: g/m^2 
  !(nvrt)<< surface to bottom
  real(rkind),save,allocatable,dimension(:) :: rtpocsav, rtponsav,rtpopsav !(nvrt), unit: g/m^2/day
  real(rkind),save,allocatable,dimension(:) :: lfNH4sav,lfPO4sav,rtdosav !(nvrt), unit: g/m^2/day
  !(nea)<<depth integrated, true outputs
  real(rkind),save,allocatable,dimension(:) :: tlfsav,tstsav,trtsav !(nea), unit: g/m^2 
  real(rkind),save,allocatable,dimension(:) :: hcansav,hcansavori!(nea)
  real(rkind),save,allocatable,dimension(:) :: trtpocsav,trtponsav,trtpopsav,trtdosav !(nea), unit: g/m^2/day
  real(rkind),save,allocatable,dimension(:) :: tlfNH4sav,tlfPO4sav  !(nea), unit: g/m^2/day

  !ncai_veg
  real(rkind),save,allocatable,dimension(:,:) :: tlfveg,tstveg,trtveg !(nea,3)
  real(rkind),save,allocatable,dimension(:,:) :: hcanveg !,ztcveg !(nea,3)
  real(rkind),save,allocatable,dimension(:,:) :: trtpocveg,trtponveg,trtpopveg,trtdoveg !(nea,3)
  real(rkind),save,allocatable,dimension(:,:) :: lfNH4veg,lfPO4veg !(nvrt,3)<< surface to bottom
  real(rkind),save,allocatable,dimension(:,:) :: tlfNH4veg,tlfPO4veg !(nea,3)

  !PH model
  integer, save :: inu_ph,irec_ph
  integer,save,allocatable :: iphgb(:)
  real(rkind),save,allocatable :: ph_nudge(:),ph_nudge_nd(:) 
  real(rkind),save,allocatable,dimension(:,:) :: TIC,ALK,CA,CACO3,PH_el,PH_nd,TIC_el,ALK_el                         
  real(rkind),save,allocatable,dimension(:) :: PH,CAsat,CO2
  real(rkind),save :: WSCACO3,rKCACO3,rKCA,rKa

  !phyto. growth rate
  real(rkind),save :: TU,TD,rIa,rIavg,Daylen
  real(rkind),save,allocatable,dimension(:,:) :: PrefN
  !(nvrt,nea),>>> 1 to nvrt: bottom to surface
  real(rkind),save,allocatable,dimension(:,:,:) :: GP
  real(rkind),save,allocatable,dimension(:) :: rIavg_save !(nea)
  integer,save :: irSi, iLimit
  
  !TSED
  real(rkind),save,allocatable,dimension(:) :: PC2TSS,WSSED 
  
  !DO
  real(rkind),save,allocatable,dimension(:) :: WMS 

  !---------general parameters from icm.in--------------------------------
  !zooplankton paramters
  real(rkind),save :: Eff,RF,Pf
  real(rkind),save,dimension(8,2) :: GZM,rKhGE,PPC
  real(rkind),save,dimension(2) :: BMZR,DRZ,TGZ,rKTGZ1,rKTGZ2,TBZ,rKTBZ,RZ

  !phytoplankton parameters 
  integer,save :: iReg_PR,iReg_GP,iPRR
  integer,save,allocatable :: reg_GP(:),reg_PR(:) !nea
  real(rkind),save :: rKhS,ST,rKeC1,rKeC2,rKeChl,rKeTSS,rKeSal,mKhN,mKhP,Dopt 
  real(rkind),save,dimension(3) :: BMPR,TBP,rKTBP,rKhN,rKhP,rIm,alpha_PB
  real(rkind),save,allocatable,dimension(:) :: PRR1,PRR2,PRR3,GPM1,GPM2,GPM3,TGP1,TGP2,TGP3,CChl1,CChl2,CChl3
  real(rkind),save,allocatable,dimension(:) :: rKTGP11,rKTGP12,rKTGP13,rKTGP21,rKTGP22,rKTGP23

  !ncai_sav readin parameters 
  integer,save,allocatable :: patchsav(:) !(nea)
  integer,save :: initsav
  real(rkind),save :: famsav,fplfsav,fpstsav,fprtsav
  real(rkind),save :: acdwsav,ancsav,apcsav,aocrsav !ratios
  real(rkind),save :: pmbssav,toptsav,ktg1sav,ktg2sav !temp 
  real(rkind),save :: alphasav,rkshsav !light
  real(rkind),save :: rlf,rst,rrt,hcansav0,hcansav_limit !height
  real(rkind),save :: fdosav, fcdsav, fclpsav, fcrpsav !carbon
  real(rkind),save :: khnwsav,khnssav,khnprsav !nitrogen
  real(rkind),save :: fnisav, fndsav, fnlpsav, fnrpsav
  real(rkind),save :: khpwsav,khpssav !phosphorus
  real(rkind),save :: fpisav, fpdsav, fplpsav, fprpsav
  real(rkind),save :: bmlfrsav,bmstrsav,bmrtrsav !reference metabolism
  real(rkind),save :: ktblfsav,ktbstsav,ktbrtsav
  real(rkind),save :: trlfsav,trstsav,trrtsav
  !intermediate variables
  !sav growth rate and metabolism rate
  !(nvrt,nea)>> bottom to surface
  real(rkind),save,allocatable,dimension(:,:) :: plfsav,pmaxsav,fisav,fnsav,fpsav !(nvrt,nea)
  real(rkind),save,allocatable,dimension(:) :: bmlfsav,bmstsav,bmrtsav !1/day; (nvrt)<< surface to bottom
  real(rkind),save :: rdenssav !density


  !ncai_veg readin parameters
  integer,save,allocatable :: patchveg(:) !nea
  integer,save :: initveg !decide init mapping format
  integer,save :: iMortveg !flag of vegetation mortality
  real(rkind),save,dimension(3) :: famveg,fplfveg,fpstveg,fprtveg
  real(rkind),save,dimension(3) :: acdwveg,ancveg,apcveg,aocrveg !ratios
  real(rkind),save,dimension(3) :: pmbsveg,toptveg,ktg1veg,ktg2veg !temp
  real(rkind),save,dimension(3) :: alphaveg,rkshveg !light
  real(rkind),save,dimension(3) :: saltveg,saltoptveg !salt
  real(rkind),save,dimension(3) :: tinunveg !inundation
  real(rkind),save,dimension(3) :: aveg,critveg,dveg,eveg !height
  !real(rkind),save,allocatable,dimension(:) :: mhtveg !(nea),water level
  real(rkind),save,dimension(3) :: fdoveg, fcdveg, fclpveg, fcrpveg !carbon
  real(rkind),save,dimension(3) :: khnwveg,khnsveg,khnprveg !nitrogen
  real(rkind),save,dimension(3) :: fniveg, fndveg, fnlpveg, fnrpveg
  real(rkind),save,dimension(3) :: khpwveg,khpsveg !phosphorus
  real(rkind),save,dimension(3) :: fpiveg, fpdveg, fplpveg, fprpveg
  real(rkind),save,dimension(3) :: bmlfrveg,bmstrveg,bmrtrveg !reference metabolism 
  real(rkind),save,dimension(3) :: ktblfveg,ktbstveg,ktbrtveg
  real(rkind),save,dimension(3) :: trlfveg,trstveg,trrtveg
  real(rkind),save,dimension(3) :: adlfveg,bdlfveg,cdlfveg,ddlfveg
  real(rkind),save,dimension(3) :: adstveg,bdstveg,cdstveg,ddstveg
  real(rkind),save,dimension(3) :: adrtveg,bdrtveg,cdrtveg,ddrtveg
  !intermediate variables
  integer,save :: knveg(3) !index of top layer with canopy occupied, knveg=0 for emergency
  real(rkind),save,allocatable,dimension(:,:) :: rdephcanveg !(nea,3)
  real(rkind),save,allocatable,dimension(:,:) :: plfveg,pmaxveg,fiveg,fnveg,fpveg,fsveg,ffveg !(nea,3)
  real(rkind),save,dimension(3) :: bmlfveg,bmstveg,bmrtveg !1/day
  real(rkind),save,dimension(3) :: mtlfveg,mtstveg,mtrtveg !1/day
  real(rkind),save :: airtveg,mtemp
  real(rkind),save,dimension(3) :: rdensveg


  !carbon parameters 
  real(rkind),save :: FCRPZ,FCLPZ,FCDPZ
  real(rkind),save :: rKRCalg,rKLCalg,rKDCalg,TRHDR,TRMNL,rKTHDR,rKTMNL
  integer,save :: iReg_KC
  integer,save,allocatable :: reg_KC(:) !nea
  real(rkind),save,allocatable,dimension(:) :: rKRC,rKLC,rKDC
  real(rkind),save :: rKHR1,rKHR2,rKHR3,rKHORDO,rKHDNn,AANOX
  real(rkind),save,dimension(3) :: FCD,FCRP,FCLP,FCDP
  real(rkind),save,dimension(2) :: FCDZ,rKHRZ

  !nitrogen parameters 
  real(rkind),save :: FNRPZ,FNLPZ,FNDPZ,FNIPZ,FNRP,FNLP,FNDP,FNIP,ANDC
  real(rkind),save :: rKRN,rKLN,rKDN,rKRNalg,rKLNalg,rKDNalg,rNitM,TNit,rKNit1,rKNit2,rKhNitDO,rKhNitN
  real(rkind),save,dimension(3) :: FNR,FNL,FND,FNI,ANC
  real(rkind),save,dimension(2) :: FNRZ,FNLZ,FNDZ,FNIZ,ANCZ

  !phosphorus parameters 
  real(rkind),save :: FPRPZ,FPLPZ,FPDPZ,FPIPZ,FPRP,FPLP,FPDP,FPIP
  real(rkind),save :: rKPO4p
  integer,save :: iReg_PO4
  integer,save,allocatable :: reg_PO4(:) !nea
  real(rkind),save,allocatable,dimension(:) :: rKRP,rKLP,rKDP,rKRPalg,rKLPalg,rKDPalg 
  real(rkind),save,dimension(3) :: FPR,FPL,FPD,FPI,APC
  real(rkind),save,dimension(2) :: FPRZ,FPLZ,FPDZ,FPIZ,APCZ

  !silica parameters 
  real(rkind),save :: FSPPZ,FSIPZ,FSPP,FSIP,rKSAp,rKSU,TRSUA,rKTSUA
  real(rkind),save :: FSPd,FSId,ASCd
  real(rkind),save,dimension(2) :: FSPZ,FSIZ,ASCZ

  !COD&DO parameters 
  real(rkind),save :: rKHCOD,rKCD,TRCOD,rKTCOD  
  real(rkind),save :: AOC,AON,AONO,rKro,rKTr         

  !--------------------------------------------------------------------------------------
  !erosion
  real(rkind),save,allocatable,dimension(:) :: EROH2S, EROLPOC,ERORPOC !nea

  !settling
  !integer,save :: iReg_WS,iWS
  integer,save,allocatable :: reg_WS(:) !nea
  real(rkind),save,allocatable,dimension(:) :: WSRP,WSLP,WSPB1,WSPB2,WSPB3,turb,WRea

  !net settling velocity !unit:m/day
  real(rkind),save,allocatable,dimension(:) :: WSSBNET,WSLBNET,WSRBNET,WS1BNET,WS2BNET,WS3BNET

  !benthic flux from sediment flux model, positive refer to from sediment to water column
  real(rkind),save:: BnDOC,BnNH4,BnNO3,BnPO4t,BnSAt,BnCOD,BnDO

  !additional time series of benthic flux 
  real(rkind),save:: TBRPOC,TBLPOC,TBDOC,TBRPON,TBLPON,TBDON,TBNH4,TBNO3,TBRPOP,TBLPOP,TBDOP,TBPO4t,TBSU,TBSAt,TBCOD,TBDO
  real(rkind),save,allocatable,dimension(:) :: BRPOC,BLPOC,BDOC,BRPON,BLPON,BDON,BNH4,BNO3,BRPOP,BLPOP,BDOP,BPO4t,BSU,BSAt,BCOD,BDO

  !simplified benthic flux as function of temp
  real(rkind),save :: thata_tben,SOD_tben,DOC_tben,NH4_tben,NO3_tben,PO4t_tben,SAt_tben

  !surface flux : atmospheric loading
  real(rkind),save :: SRPOC,SLPOC,SDOC,SRPON,SLPON,SDON,SNH4,SNO3,SRPOP,SLPOP,SDOP,SPO4t,SSU,SSAt,SCOD,SDO

  !for station output for intermediate parameters and ICM variables
  !ista(ie) refers to local station index (lsi)
  !nsta(lsi) refers to number of depth
  !depsta(k,lsi) is depth,where k is depth index
  !stanum is the station index from cstation.in
  integer, save :: nspool_icm
  integer,save,allocatable :: ista(:),nsta(:),stanum(:,:)
  real(rkind),save,allocatable :: depsta(:,:)

end module icm_mod
