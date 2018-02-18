library(neuRosim)
library(fmri)
library(HH)

## ------------------------------------------------------------------------

#############################
n.loop = 50000

###make sure these match the script
delivery_time=6.0
cue_time=2.0
wait_time=6.0
rinse_time=3.0

tot_iti=cue_time+wait_time+rinse_time
# Things that don't change
water<-rep(0,8)
sweet<-rep(1,8)
unsweet<-rep(2,8)
all<-c(water, sweet, unsweet)
ntrials.total = 24

dur = rep(delivery_time, ntrials.total)#length of stimulus of interest
#min and max jitter values possible
min=4
max=11
#everything not jitter and not of interest (cue+wait+rinse)
iti_inital=wait_time+cue_time+rinse_time
iti_hard = rep(iti_inital+max, ntrials.total) #if using a random iti, you need to include this and the onsets into the loop
ons.all = cumsum(c(0,dur+iti_hard))
ons.all = ons.all[1:(ntrials.total)]

run.length = max(ons.all)+100 #added just a ton of end time so the random jitter doesn't mess me up
tr = 1
eff.size = 1
# Things I'd like to save
eff.val = rep(0, n.loop) #efficiency
desmats = array(0,c(run.length, 4,  n.loop)) #all the model data
ons.save = array(0,c(length(ons.all),3, n.loop)) #the onsets

Sys.time()->start;
for (i in 1:n.loop){
  keep.looking = 1
  while (keep.looking == 1){#creating onsets
    trial.type = sample(all)
    length.repeats = rle(trial.type)$lengths 
    keep.looking = max(length.repeats) > 2
  }
  
  iti.uni = runif(1000, min, max) #randomly generate 1000 numbers between 1 and 9, mean is 5 this is the jitter
  iti = rep(iti_inital, ntrials.total) #iti that is not random, wait, cue, ect
  vr <- c(0) ### an empty vector for jitter
  jit<-c(0)
  for (j in 1:length(iti)) {#generating the jitter, randomly selecting a number from my distribution above
    jitter<-sample(iti.uni, 1)
    jit[j]<-round(jitter,0) #rounding jitter and adding it to a vector
    vr[j] <- iti[j]+jit[j] # adding it to my non-random interval and then vector
  }
  ons.all = cumsum(c(0,dur+vr))
  ons.all = ons.all[1:(ntrials.total)]
  
  
  #taking the onsets and making them simulated activation
  sweet = specifydesign(ons.all[trial.type == 1], dur[trial.type == 1],
                       run.length, tr,
                       eff.size, conv = "double-gamma")
  unsweet = specifydesign(ons.all[trial.type == 2], dur[trial.type == 2],
                        run.length, tr,
                        eff.size, conv = "double-gamma")
  water = specifydesign(ons.all[trial.type == 0], dur[trial.type == 0],
                        run.length, tr,
                        eff.size, conv = "double-gamma")
  #save the simulated activation in a array (TRxContrast)
  des.mat = cbind(rep(1, length(water)), water, sweet, unsweet)
  #ons.save= cbind(ons.save,trial.type)
  #ons.save[,,i]=
  # making the contrast this is sweet>unsweet
  con = c(0, 0, 1,-1) 
  #solving for the efficiency matrix
  eff.val[i] = 1/(t(con)%*%solve(t(des.mat)%*%des.mat)%*%con)
  ons.save[,,i]=c(ons.all,jit,trial.type)
  #creating an array adding des.mat to the efficiency matrix
  desmats[,,i] = des.mat
}
print(Sys.time()-start)

# Plot design matrices with best and worst efficiencies
par(mfrow = c(2, 1), mar = c(4, 3, 2, 1))
# finding the most eff matrix to plot all of the columns simulated activation for each TR
water.best = desmats[,2,which(eff.val == max(eff.val))]
sweet.best = desmats[,3,which(eff.val == max(eff.val))]
unsweet.best = desmats[,4,which(eff.val == max(eff.val))]
plot(water.best, type = 'l', lwd = 2, col = 'red', xlab = "TR", 
     ylab = '', ylim = c(min(c(water.best, sweet.best)), 1.3),
     main = "Highest Efficiency")
lines(sweet.best, lwd = 2, col = 'cyan')
lines(unsweet.best, lwd = 2, col = 'black')

water.worst = desmats[,2,which(eff.val == min(eff.val), arr.ind = TRUE)]
sweet.worst = desmats[,3,which(eff.val == min(eff.val))]
unsweet.worst = desmats[,4,which(eff.val == min(eff.val))]

plot(water.worst, type = 'l', lwd = 2, col = 'red', xlab = "TR", 
     ylab = '', ylim = c(min(c(water.worst, sweet.worst)), 1.3),
     main = "Lowest Efficiency")
lines(sweet.worst, lwd = 2, col = 'cyan')
lines(unsweet.worst, lwd = 2, col = 'black')
legend('topleft', c("sweet 1","unsweet 2",  "water 0"), col = c("cyan", "black", "red"), lwd = c(2,1), bty = 'n')

#desmats TRxcontrast_activationxloops
#there are n.loops of matrices, with timepoint rows and contrast columns
#trying to back out which onsets are associated with the most efficient design
#order the efficiency, the last one (highest efficiency) is what you want
ord.eff = order(eff.val)
#most efficient
best = tail(ord.eff, 1)
ons.save[,,best]
# Omit the intercept
#diag(solve(cor(desmats[,3:4,best])))
#VIF
fake.data = rnorm(length(water))
mod.fake = lm(fake.data ~ water.best + sweet.best)
vif(mod.fake)

write.table(ons.save[,,best][,1], "/Users/gracer/Documents/bevbit_task/onset_files/pre/onsets_run01", row.names = F,col.names = F, sep="\t")
write.table(ons.save[,,best][,2], "/Users/gracer/Documents/bevbit_task/onset_files/pre/jitter_run01", row.names = F, col.names = F, sep="\t")
write.table(ons.save[,,best][,3], "/Users/gracer/Documents/bevbit_task/onset_files/pre/conds_run01", row.names = F, col.names = F, sep="\t")
