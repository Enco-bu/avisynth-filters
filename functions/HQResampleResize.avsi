/******************************************************************************
 * HQResampleResize : Function HQResampleResize()
 * gamma aware resize function for Android devices
 * this resizer is mainly for downscaling.
 * cm_mode means colormatrix mode.
 * iirc, media players for Android devices cannot understand colormatirx
 * and colormatirx is forced to BT.601 except VLC.
 * So, output colormatrix is set to BT.601 when cm_mode == "nonVLC".
 * input colormatrix is automatically selected depending on the clip definition.
 * when cm_mode == "VLC", output colormatrix is automatically
 * selected depending on the clip definition, too.
 * Written by Takuan (K4095)
 * v0.1.5 - 07 January 2013
 ******************************************************************************
 * +----------+
 * | Required |
 * +----------+
 * dll:
 * dither (v1.22.0 or higher)
 * MaskTools2 (v2a48 or higher)
 * avsi:
 * dither.avsi
 * mt_xxpand_multi.avsi
 *
 * +-------------+
 * | restriction |
 * +-------------+
 * This function assumes only tvrange && progressive sources.
 *****************************************************************************/
Function HQResampleResize(clip input, int "w", int "h", float "src_left", float
"src_top", float "src_width", float "src_height", \
 bool "lsb_in", bool "lsb_out", int "d_mode", string "c
m_mode")
{
 /* Default settings */
 lsb_in = Default( lsb_in, False)
 iw = input.Width()
 ih16 = input.Height()
 ih = (lsb_in) ? int((ih16)/2) : ih16
 w = Default( w, iw)
 h = Default( h, ih)
 src_left = Default( src_left, 0)
 src_top = Default( src_top, 0)
 src_width = Default( src_width, 0)
 src_height = Default(src_height, 0)
 lsb_out = Default( lsb_out, False)
 d_mode = Default( d_mode, 6) /* dithering mode for 8-bit output *
/
 cm_mode = Default( cm_mode, "VLC") /* colormatrix mode */
 /* cm_num setting */
 cm_num = (cm_mode == "VLC" ) ? 0 : \
 (cm_mode == "nonVLC" ) ? 1 : \
 (cm_mode == "709->601") ? 2 : \
 (cm_mode == "601->709") ? 3 : \
 (cm_mode == "709" ) ? 4 : \
 (cm_mode == "601" ) ? 5 : \
 Assert(False, "HQResampleResize: wrong cm_mode value!")
 /* res detection */
 in_cm = (cm_num <= 1) ? (((iw > 1050) || (ih > 576)) ? "709" : "601") : \
 (cm_num == 2) ? "709" : \
 (cm_num == 3) ? "601" : \
 (cm_num == 4) ? "709" : "601"
 out_cm = (cm_num == 0) ? ((( w > 1050) || ( h > 576)) ? "709" : "601") : \
 (cm_num == 1) ? "601" : \
 (cm_num == 2) ? "601" : \
 (cm_num == 3) ? "709" : \
 (cm_num == 4) ? "709" : "601"
 /* Y'CbCr -> R'G'B'
 * Algorithm for Chroma up-sampling should be that does not ring too much to
 avoid false colors.
 * Here, using blackmanminlobe, taps=2. */
 rgb48 = (!lsb_in) ? input.Dither_convert_yuv_to_rgb(matrix=in_cm, interla
ced=False, tv_range=True, cplace="MPEG2", chromak="blackmanminlobe", \
 taps=2, lsb_in=False,
 output="rgb48y", noring=True) : \
 input.Dither_convert_yuv_to_rgb(matrix=in_cm, interla
ced=False, tv_range=True, cplace="MPEG2", chromak="blackmanminlobe", \
 taps=2, lsb_in=True,
 output="rgb48y", noring=True)
 /* R'G'B' -> RGB */
 yg2l = rgb48.Dither_y_gamma_to_linear(tv_range_in=True, tv_range_out=Tru
e, curve="709", u=1, v=1)
 /* Resizing section
 I like Catmull-Rom Resizing algorithm. */
 resized = yg2l.Dither_resize16nr(w, h, src_left=src_left, src_top=src_top,
src_width=src_width, src_height=src_height, \
 kernel="cubic", a1=0, a2=0.5, cplace="MPEG
2", y=3, u=1, v=1, noring=True)
 /* RGB -> R'G'B' */
 yl2g = resized.Dither_y_linear_to_gamma(tv_range_in=True, tv_range_out=T
rue, curve="709", u=1, v=1)
 /* R'G'B' -> Y'CbCr
 * Here, using blackmanminlobe, taps=2 for Chroma up-sampling, too. */
 R = yl2g.SelectEvery(3, 0)
 G = yl2g.SelectEvery(3, 1)
 B = yl2g.SelectEvery(3, 2)
 output = (lsb_out) ? Dither_convert_rgb_to_yuv(R, G, B, matrix=out_cm, int
erlaced=False, tv_range=True, cplace="MPEG2", chromak="blackmanminlobe", \
 taps=2, lsb=True,
 output="YV12", noring=True) : \
 Dither_convert_rgb_to_yuv(R, G, B, matrix=out_cm, int
erlaced=False, tv_range=True, cplace="MPEG2", chromak="blackmanminlobe", \
 taps=2, lsb=False, mode=d_m
ode, ampn=0, ampo=1, output="YV12", noring=True)
 return output
}
