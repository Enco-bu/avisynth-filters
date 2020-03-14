/******************************************************************************
 * Remonsenpaiperopero Lite16 : function RSPLite16()
 * Written by Takuan (K4095).
 * v0.2.0 - 07 January 2013
 ******************************************************************************
 * +----------+
 * | Required |
 * +----------+
 * dll:
 * MVTools2 (mod16) (v2.6.0.5 or higher)
 * dither (v1.21.0 or higher)
 * avstp (v1.0.1 or higher)
 * flash3kyuu_deband (v1.5.1 or higher)
 * MosquitoNR (ver.120210 or higher)
 * MaskTools2 (v2a48 or higher)
 * avsi:
 * HQResampleResize.avsi
 * dither.avsi
 * mt_xxpand_multi.avsi
 *
 * +-------------+
 * | restriction |
 * +-------------+
 * This wrapper assumes only HD && BT.709 && progressive sources.
 * Also, target res must be HD.
 *****************************************************************************/
Function RSPLite16(clip input, int "tr", int "thSAD", int "search", int "mos",
 \
 int "w", int "h",
 \
 int "range", int "Y", int "Cb", int "Cr", int "grainY", int "
grainC", bool "dynamic_grain", \
 bool "lsb_in", bool "stack")
{
version = 0.2.0
 /* Default settings */
 tr = Default( tr, 4)
 thSAD = Default( thSAD, 240)
 search = Default( search, 4)
 mos = Default( mos, 20)
 w = Default( w, input.Width())
 h16 = (lsb_in) ? int((input.Height())/2) : input.Height()
 h = Default( h, h16)
 range = Default( range, 16)
 Y = Default( Y, 36)
 Cb = Default( Cb, 0)
 Cr = Default( Cr, 0)
 grainY = Default( grainY, 0)
 grainC = Default( grainC, 0)
 dynamic_grain = Default(dynamic_grain, False)
 lsb_in = Default( lsb_in, False)
 stack = Default( stack, False)
 Assert(isYV12(input), chr(10) + "This is not an YV12 clip !" + chr(10))
/* Denoise */
(mos !=0) ? \
Eval("""
 /* MosquitoNR */
 m = (lsb_in) ? input.DitherPost(mode=-1, u=1, v=1)
 : input
 dem = m.MosquitoNR(strength=mos, restore=128, radius=2, threads=0)
 mh = m.Height()
 mw = m.Width()
 dem16 = (lsb_in) ? StackVertical(dem, BlankClip(width=mw, height=mh, pixel_t
ype="YV12")) : nop()
 mask8 = (lsb_in) ? DitherBuildMask(dem, m)
 : nop()
 dem16 = (lsb_in) ? Dither_merge16_8(input, dem16, mask8, u=2, v=2)
 : nop()
 input = (lsb_in) ? MergeChroma(dem16, input)
 : dem
 """) : \
 input
(tr > 0) ? \
Eval("""
 /* preparation */
 input8 = (lsb_in) ? input.DitherPost(mode=6) : input
 pref = (lsb_in) ? input.Remon(lsb_in=True) : input.Remon(lsb_in=False)
 /* create super clip */
 super_search = MSuper( pref, pel=1, sharp=2, chroma=False, hpad=0, vpad=0,
rfilter=4, planar=False)
 super_render = MSuper(input8, pel=1, sharp=2, chroma=False, hpad=0, vpad=0,
levels= 1, planar=False)
 Recalculate = MSuper( pref, pel=1, sharp=2, chroma=False, hpad=0, vpad=0,
levels= 1, planar=False)
 /* MDegrain3,2,1 */
 (tr < 4) ? \
 Eval("
 /* backward 3 */
 bv3 = (tr > 2) ? super_search.MAnalyse(isb=True, delta=3, overlap=8,
blksize=16, search=search, \
 chroma=False, truemotion=False)
 : \
 nop()
 bv3 = (tr > 2) ? MRecalculate(Recalculate, bv3, overlap=4,
blksize= 8, thSAD=int(thSAD/2), \
 chroma=False, truemotion=False)
 : \
 bv3
 /* backward 2 */
 bv2 = (tr > 1) ? super_search.MAnalyse(isb=True, delta=2, overlap=8,
blksize=16, search=search, \
 chroma=False, truemotion=False)
 : \
 nop()
 bv2 = (tr > 1) ? MRecalculate(Recalculate, bv2, overlap=4,
blksize= 8, thSAD=int(thSAD/2), \
 chroma=False, truemotion=False)
 : \
 bv2
 /* backward 1 */
 bv1 = super_search.MAnalyse(isb=True, delta=1, overlap=8, 
blksize=16, search=search, \
 chroma=False, truemotion=False)
 bv1 = MRecalculate(Recalculate, bv1, overlap=4,
blksize= 8, thSAD=int(thSAD/2), \
 chroma=False, truemotion=False)
 /* forward 1 */
 fv1 = super_search.MAnalyse(isb=False, delta=1, overlap=8,
blksize=16, search=search, \
 chroma=False, truemotion=False)
 fv1 = MRecalculate(Recalculate, fv1, overlap=4,
blksize= 8, thSAD=int(thSAD/2), \
 chroma=False, truemotion=False)
 /* forward 2 */
 fv2 = (tr > 1) ? super_search.MAnalyse(isb=False, delta=2, overlap=8,
blksize=16, search=search, \
 chroma=False, truemotion=False)
 : \
 nop()
 fv2 = (tr > 1) ? MRecalculate(Recalculate, fv2, overlap=4,
blksize= 8, thSAD=int(thSAD/2), \
 chroma=False, truemotion=False)
 : \
 fv2
 /* forward 3 */
 fv3 = (tr > 2) ? super_search.MAnalyse(isb=False, delta=3, overlap=8,
blksize=16, search=search, \
 chroma=False, truemotion=False)
 : \
 nop()
 fv3 = (tr > 2) ? MRecalculate(Recalculate, fv3, overlap=4,
blksize= 8, thSAD=int(thSAD/2), \
 chroma=False, truemotion=False)
 : \
 fv3
 ") : \
 /* MDegrainN */ \
 Eval("
 /* multi */
 vmulti = super_search.MAnalyse(multi=True, delta=tr, overlap=8,
blksize=16, search=search, \
 chroma=False, truemotion=False)
 vmulti = MRecalculate(Recalculate, vmulti, overlap=4,
blksize= 8, thSAD=int(thSAD/2), \
 chroma=False, truemotion=False, t
r=tr)
 ")
 /* Denoised Clip out */
 Eval("
 output = (tr > 3) ? input8.MDegrainN(super_render, vmulti, tr, thSAD2=in
t(thSAD/2), thSADC2=int(thSAD/4), \
 thSAD=thSAD, thSADC=int(thSAD/2), t
hSCD1=1600, thSCD2=130, \
 limit=255, limitc=255, plane=0, pla
nar=False,lsb=True) : \
 (tr > 2) ? input8.MDegrain3(super_render, bv1, fv1, bv2, fv2, b
v3, fv3, thSAD=thSAD, thSADC=int(thSAD/2), \
 thSCD1=1600, thSCD2=130, limit=255,
 limitc=255, plane=0, planar=False, lsb=True) : \
 (tr > 1) ? input8.MDegrain2(super_render, bv1, fv1, bv2, fv2, 
 thSAD=thSAD, thSADC=int(thSAD/2), \
 thSCD1=1600, thSCD2=130, limit=255,
 limitc=255, plane=0, planar=False, lsb=True) : \
 input8.MDegrain1(super_render, bv1, fv1,
 thSAD=thSAD, thSADC=int(thSAD/2), \
 thSCD1=1600, thSCD2=130, limit=255,
 limitc=255, plane=0, planar=False, lsb=True)
 /* LSB_IN merging */
 denoised = (lsb_in) ? Dither_merge16_8(input, output, mt_lutxy(input.Dit
herPost(mode=6), output.Ditherpost(mode=6, u=2, v=2), \
 expr="+Chr(34)+"x y == 0 255 ?"+C
hr(34)+", y=3, u=2, v=2).mt_expand(u=2, v=2), \
 u=2, v=2)
 : \
 output
 ")
 """) : \
Eval("
 denoised = input
 ")
denoised
/* Resize */
resizing = ((w == input.Width()) && (h == (lsb_in ? int((input.Height())/2) : in
put.Height()))) ? False : True
(!resizing) ? last : \
Eval("""
 ((tr == 0) && (!lsb_in)) ? HQResampleResize(w=w, h=h, lsb_in=False, lsb_out=
True, cm_mode="709") : \
 HQResampleResize(w=w, h=h, lsb_in=True, lsb_out=
True, cm_mode="709")
 """)
/* Deband */
deband = ((Y == 0) && (Cb == 0) && (Cr == 0) && (grainY == 0) && (grainC == 0))
? False : True
imode = ((tr == 0) && (!lsb_in) && (!resizing)) ? 0 : 1
idepth = ((tr == 0) && (!lsb_in) && (!resizing)) ? 8 : 16
(!deband) ? \
Eval("
 ((tr == 0) && (!lsb_in) && (!resizing)) ? \
 ((stack) ? Dither_convert_8_to_16() :
 \
 Dither_convert_8_to_16().Dither_convey_yuv4xxp16_on_yvxx()) :
 \
 ((stack) ? last :
 \
 Dither_convey_yuv4xxp16_on_yvxx())
 ") : \
Eval("
 (stack) ? f3kdb(range=range, Y=Y, Cb=Cb, Cr=Cr, grainY=grainY, grainC=grainC
, dynamic_grain=dynamic_grain, \
 keep_tv_range=True, input_mode=imode, input_depth=idepth, ou
tput_mode=1, output_depth=16, \
 random_algo_ref=2, random_algo_grain=2)
 : \
 f3kdb(range=range, Y=Y, Cb=Cb, Cr=Cr, grainY=grainY, grainC=grainC
, dynamic_grain=dynamic_grain, \
 keep_tv_range=True, input_mode=imode, input_depth=idepth, ou
tput_mode=2, output_depth=16, \
 random_algo_ref=2, random_algo_grain=2)
 ")
 return last
}
/* internal func for denoise */
Function Remon(clip src, bool "lsb_in")
{
 lsb_in = Default(lsb_in, False)
 na = lsb_in ? "x 4096 - 56064 / 0 1 clip" : "x 16 - 219 / 0 1 clip"
 naa = "0"+" "+"1.0625"+" " +"0.06640625"+" "+na+" "+"0.0625" \
 +" + / - * " + na +" 1 "+"0" +" - * + " +"65536"+" *"
src
 lsb_in ? Dither_lut16(yexpr=naa, expr="x 32768 - 32768 * 28672 / 32768 +", y
=3, u=1, v=1) : \
 Dither_lut8 (yexpr=naa, expr= "x 128 - 32768 * 112 / 32768 +", y
=3, u=1, v=1)
Ditherpost(mode=6, u=1, v=1)
}
