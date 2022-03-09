#!/home/chiba/etc/hc-utils/rscript -g
USAGE =
"Usage: 
-x: log scale
-y: log scale
-l: linear regression
-h: help
"
### Get command line argumants ###
getopts("xylh")
if (opt.h) {
  cat(USAGE)
  q()
}
##################################

cor.test(t$V1, t$V2)

if (opt.x) {
  x = log10(t$V1)
  xaxt = "n"
} else {
  x = t$V1
  xaxt = "s"
}

if (opt.y) {
  y = log10(t$V2)
  yaxt = "n"
} else {
  y = t$V2
  yaxt = "s"
}

plot(x, y, xlab = ARGV[1], ylab = ARGV[2], xaxt=xaxt, yaxt=yaxt) #, xlim=c(0,2.6) log10(400) = 2.60206

if (opt.y) {
  log.axis(side=2)
}
if (opt.x) {
  log.axis()
}

if (opt.l) {
  lm = lm(y~x)
  print(lm)
  abline(lm, col="red")
}
