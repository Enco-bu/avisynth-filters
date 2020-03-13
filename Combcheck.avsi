function Combcheck (clip clip) {
clip=mt_merge(Grayscale(clip),ColorYUV(Grayscale(clip),gain_u=100,gain_v=100),CombMask(clip,thY1=16,thY2=16),luma=true)
return clip
}	