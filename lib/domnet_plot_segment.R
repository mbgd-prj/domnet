#!/home/chiba/etc/rscript/rscript -g
USAGE =
"Usage: 
-h: help
"
### Get command line argumants ###
getopts("hx:y:s:")
if (opt.h) {
  cat(USAGE)
  q()
}

if (opt.x != F) {
  xlab = opt.x
} else {
  xlab = "x";
}

if (opt.y != F) {
  ylab = opt.y
} else {
  ylab = "y";
}

if (opt.s != F) {
  segments = read.table(opt.s)
}
##################################

if (opt.s != F) {
  x = c(t$V1, segments$V1, segments$V2)
  y = c(t$V2, segments$V3)
} else {
  x = t$V1
  y = t$V2
}  

plot(t$V1, t$V2
     , pch='*'
     # , pch='+'
     , xlim=c(min(x), max(x))
     , ylim=c(min(y), max(y))
     , xlab = xlab
     , ylab = ylab
     )

if (opt.s != F) {
  for (i in 1:length(segments$V1)) {
    cat(segments$V1[i], segments$V2[i], "\n")
    lines(c(segments$V1[i], segments$V2[i]), c(segments$V3[i], segments$V3[i]))
  }
}
