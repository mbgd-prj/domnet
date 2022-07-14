#!/home/chiba/etc/hc-utils/rscript
USAGE =
"Usage: 
-h: help
"
### Get command line argumants ###
getopts("h")
if (opt.h) {
  cat(USAGE)
  q()
}
##################################

x = log10(t$V1)
y = log10(t$V2)

lm = lm(y~x)
grad = lm$coefficients[["x"]]
r2 = summary(lm)$r.squared

cat(grad, r2, sep="\t", fill=TRUE)
