# Demo file for Spyder Tutorial
# Hans Fangohr, University of Southampton, UK

import numpy as N
from random import shuffle

positions = [(0.25,0), (-0.25,0)]
positions_eng = ['right','left']
pos_ind = [0,1]

stim_images1=['a.jpg','b.jpg']
stim_images2=['c.jpg','d.jpg']
stim_images3=['e.jpg','f.jpg']

prob1=[0.8, 0.2]
prob2=[0.7, 0.3]
prob3=[0.6, 0.4]

inv_prob1=[0.2, 0.8]
inv_prob2=[0.3, 0.7]
inv_prob3=[0.4, 0.6]

#stim list, prob list, and inv_prob list are on prob index
stim_list=[stim_images1, stim_images2, stim_images3]
prob_list=[prob1, prob2, prob3]
inv_prob_list=[inv_prob1, inv_prob2, inv_prob3]
#master prob list is on indicies
prob_index=[0,1,2]

#this index allows us to switch which key press is associated with which side, while maintaing the image to pump pair
indices=[0,1]

print(stim_list)

x=int(N.random.choice(prob_index, 1, p=[0.34, 0.33,0.33]))
stim_images=stim_list[x]
trial_prob=prob_list[x]
trial_inv_prob=inv_prob_list[x]

master_prob_list=[trial_prob,trial_inv_prob]

print(master_prob_list)
#visual_stim1.setImage(stim_images[indices[0]])#set which image appears
#visual_stim2.setImage(stim_images[indices[1]])#set which image appears

shuffle(indices)
#creating a dictory which will store the postion with the image and pump, the image and pump need to match
mydict={}
mydict[positions_eng[pos_ind[1]]] = [stim_images[indices[1]], master_prob_list[indices[1]]]
mydict[positions_eng[pos_ind[0]]] = [stim_images[indices[0]], master_prob_list[indices[0]]]

#print(mydict)


print(x)
i=0
for i in range(20):
    taste=np.random.choice(stim_images1, 1, p=prob2)
    print(taste)
    i+1