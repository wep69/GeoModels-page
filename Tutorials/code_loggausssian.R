#########################################################
#########################################################
# code for the tutorial on loggaussian  random fields analysis
#########################################################
#########################################################
rm(list=ls())
require(GeoModels)
require(fields)
require(hypergeo)
model="LogGaussian" # model name in the GeoModels package





N=2000 # number of location sites 
set.seed(72)
x = runif(N, 0, 1)
y = runif(N, 0, 1)
coords=cbind(x,y) 

plot(coords,pch=20,xlab="",ylab="")

X=cbind(rep(1,N),runif(N)) # matrix covariates 

NuisParam(model,num_betas=2)

mean = -0.2; mean1 =0.25 # regression parameters
nugget=0 # nugget parameter
sill=2


corrmodel = "Wend0" ## correlation model and parameters 
CorrParam("Wend0")
scale = 0.25
power2 =4



param=list(mean=mean,mean1=mean1,sill=sill, nugget=nugget, scale=scale ,power2=power2)
data = GeoSim(coordx=coords , corrmodel=corrmodel , model=model , param=param ,
X=X)$data

start=list(mean=mean,mean1=mean1,scale=scale,sill=sill)
fixed=list(nugget=nugget ,power2=power2)

# Maximum composite-likelihood fitting of the loggaussian random field:
fit = GeoFit2(data=data,coordx=coords, corrmodel=corrmodel,model=model,X=X,
likelihood="Conditional",type="Pairwise",
start=start,fixed=fixed,neighb=4)

fit

res=GeoResiduals(fit) # computing residuals

#### checking marginal assumptions

GeoQQ(res); 

#### checking dependence assumptions: variogram
vario = GeoVariogram(data=res$data, coordx=coords,maxdist=0.3) # empirical variogram 

GeoCovariogram(res,show.vario=TRUE, vario=vario,pch=20)




##################
##### prediction
##################
xx=seq(0,1,0.013)
loc_to_pred=as.matrix(expand.grid(xx,xx))
Nloc=nrow(loc_to_pred)
Xloc=cbind(rep(1,Nloc),runif(Nloc))

param_est=as.list(c(fit$param,fixed))
pr=GeoKrig(data=data, coordx=coords,loc=loc_to_pred, X=X,Xloc=Xloc,
	corrmodel=corrmodel,model=model,mse=TRUE,
       sparse=TRUE,param=param_est)



colour = rainbow (100)



par(mfrow=c(1,3))
quilt.plot(x, y, data,col=colour,main="Data") ## map of simulated data 
map=matrix(pr$pred,ncol=length(xx))
map=matrix(pr$pred,ncol=length(xx))
image.plot(xx, xx, map,col=colour,xlab="",ylab="",main="Kriging") ## kriging map 
map_mse=matrix(pr$mse,ncol=length(xx)) ## associated MSE kriging map 
image.plot(xx, xx, map_mse,col=colour,xlab="",ylab="",main="MSE")



