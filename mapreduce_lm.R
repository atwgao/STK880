lm(dist~speed,data=cars)$coefficients

y=cars$dist
X=cbind(1,cars$speed)
k = ncol(X)

solve(crossprod(X,X))%*%crossprod(X,y)

decomp_qr = function(x){
  list(Q=qr.Q(qr(as.matrix(x))),R=qr.R(qr(as.matrix(x))))
}

get_Vlist = function(j){
  Q3 = QR1[[j]]$Q %*% Q2list[[j]]
  t(Q3) %*% ylist[[j]]
}

solve(decomp_qr(X)$R) %*% t(decomp_qr(X)$Q) %*% y

#m blocks
m <- 5

Xlist = list()
for(j in 1:m) Xlist[[j]] = X[(j-1)*10+1:10,]
ylist = list()
for(j in 1:m) ylist[[j]] = y[(j-1)*10+1:10]

QR1 = list()
for(j in 1:m) QR1[[j]] = decomp_qr(Xlist[[j]])

R1 = QR1[[1]]$R
for(j in 2:m) R1 = rbind(R1,QR1[[j]]$R)
Q1 = decomp_qr(R1)$Q
R2 = decomp_qr(R1)$R

Q2list=list()
for(j in 1:m) Q2list[[j]] = Q1[(j-1)*2+1:2,]

Vlist <- list()
for(j in 1:m) Vlist[[j]] = get_Vlist(j)

sumV = Vlist[[1]]
for(j in 2:m) sumV = sumV + Vlist[[j]]
solve(R2) %*% sumV

###########################################################################

library(parallel)
ncl = 5   #detectCores()-1
cl  = makeCluster(ncl)

clusterExport(cl, c("decomp_qr", "get_Vlist"), envir=environment())

#Map1
QR1 = parLapply(cl=cl,Xlist, decomp_qr)
Q1 =  decomp_qr(R1)$Q
R2 =  decomp_qr(R1)$R

Q2list = split.data.frame(Q1, rep(1:ncl, each=k))
clusterExport(cl, c("QR1", "Q2list", "ylist"), envir=environment())

#Map2
Vlist = parLapply(cl, 1:length(QR1), get_Vlist)

#Reduce
sumV = Reduce('+', Vlist)
solve(R2) %*% sumV