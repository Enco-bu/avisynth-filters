/*
FlexibleMerge(OrignalName:FlexibleMerge5)

Requirement
Combmask:http://csbarn.blogspot.com/2016/05/combmask.html
MaskTools2:http://avisynth.nl/index.php/MaskTools2

Changelog
2020-03-13 Change use CombMask from　Masktools(v1))

*/
function FlexibleMerge (clip clip1,clip clip2,float "weight1",float "weight2",float "weight3",int "top",int "bottom",int "left",int "right",int "thr",float "nmax",int "mode",int "show") {

thr=default(thr,10)
weight1=default(weight1,0.5)
weight2=default(weight2,1.0)
weight3=default(weight3,0.0)
nmax=default(nmax,30.0)
mode=default(mode,2)
show=default(show,0)

top=default(top,0)
bottom=default(bottom,0)
left=default(left,0)
right=default(right,0)

blank1=BlankClip(clip1,color=$ffffff).Letterbox(top,bottom,left,right).mt_binarize()
mask1=CombMask(clip1, thY1 = thr, thY2 = thr)
mask2=CombMask(clip2, thY1 = thr, thY2 = thr)

nmask12=mt_logic(blank1,mt_logic(mask2,mask1,mode="andn"),mode="and")#clip1にノイズ、clip2はきれい
nmask21=mt_logic(blank1,mt_logic(mask1,mask2,mode="andn"),mode="and")#clip2にノイズ、clip1はきれい
nmaskA=mt_invert(mt_logic(mask1,mask2,mode="or"))#両方きれい
nmaskB=mt_logic(mask1,mask2,mode="and")#両方ノイズ
nmaskAB=mt_logic(blank1,mt_logic(nmaskA,nmaskB,mode="or"),mode="and")

clip1=(show==0) ? clip1 : clip1.subtitle("clip1",size=48)
clip2=(show==0) ? clip2 : clip2.subtitle("clip2",size=48,y=50)

global global_thr=thr
global global_nmax=nmax

clipA=Merge(clip1,clip2,weight1)
clipB=Merge(clip1,clip2,weight3)
clipAB=ScriptClip(Interleave(clip1,clip2),"Merge(SelectEven,SelectOdd,0.5/global_nmax*(averageluma(CombMask(SelectEven,thY1=global_thr,thY2=global_thr))-averageluma(CombMask(SelectOdd,thY1=global_thr,thY2=global_thr)))+0.5)")
clip12=Merge(clip1,clip2,weight2)
clip21=Merge(clip2,clip1,weight2)

clip_m0=mt_merge(clip1,clipA,nmaskA,luma=true)
clip_m0=mt_merge(clip_m0,clipB,nmaskB,luma=true)
clip_m1=mt_merge(clip1,clipAB,nmaskA,luma=true)
clip_m1=mt_merge(clip_m1,clipB,nmaskB,luma=true)
clip_m2=mt_merge(clip1,clipAB,nmaskAB,luma=true)

clip=select(mode,clip_m0,clip_m1,clip_m2)
clip=mt_merge(clip,clip12,nmask12,luma=true)
clip=mt_merge(clip,clip21,nmask21,luma=true)

show1=Combcheck(clip)
show2=StackHorizontal(Combcheck(clip1),Combcheck(clip2)).ReduceBy2.StackVertical(ReduceBy2(Combcheck(clip)).AddBorders(clip.width/4,0,clip.width/4,0))
show3=ConditionalFilter(Interleave(mask1,mask2),show2,show2,"averageluma(SelectEven)","<","averageluma(SelectOdd)",show=true)
clip=Select(show,clip,show1,show2,show3)
return clip
}