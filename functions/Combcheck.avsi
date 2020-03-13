/*
Combcheck

Changelog
2020-03-13 Change use CombMask from　Masktools(v1))
*/
function Combcheck (clip clip) {
clip=mt_merge(Grayscale(clip),ColorYUV(Grayscale(clip),gain_u=100,gain_v=100),CombMask(clip,cthresh=16,mthresh=0,chroma=false),luma=true)
return clip
}	