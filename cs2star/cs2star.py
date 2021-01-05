#  ===================
#
#  Author : Fang Kong 
#
#  ===================
import os
from glob import glob
import sys
import numpy as np

import argparse
parser=argparse.ArgumentParser()
parser.add_argument('--star',type=str)
parser.add_argument('--particles',type=str)
parser.add_argument('--mag',type=float,default=10000.00)
parser.add_argument('--pixel',type=float,default=4.29680)
parser.add_argument('--name_index',type=int,default=3)
parser.add_argument('--angx',type=int,default=5)
parser.add_argument('--angy',type=int,default=6)
parser.add_argument('--cs',type=str,default='2.7')
parser.add_argument('--v',type=str,default='300.00')
parser.add_argument('--amp',type=str,default='0.1')
parser.add_argument('--polish',type=int,default=1)
args=parser.parse_args()

Head=['_rlnOriginXAngst','_rlnOriginYAngst','_rlnOpticsGroup']
Part=['_rlnCoordinateX','_rlnCoordinateY','_rlnMicrographName' ,'_rlnMagnification','_rlnDetectorPixelSize']
Optics=['_rlnVoltage','_rlnSphericalAberration','_rlnAmplitudeContrast']
ops=[args.v,args.cs,args.amp]
Part_line=[]



star_file=open(args.star)
star_lines=star_file.read().split('\n')

Star_len=len(star_lines)

star_st_line=0

tmp=star_lines[star_st_line]

outfile=open('tmp_out.star','w')


#======================write head info from cs/star file
H_i=0



current_head_line=0
current_index=0
current_split=tmp.split(' ')
len_cs=len(current_split)
while(len_cs<10):
  if len_cs<2:
    outfile.write(tmp+'\n')
  else:
    current_index+=1
    if current_split[0].find(Head[H_i])!=-1:
      if H_i==0:
        outfile.write('_rlnOriginX '+'#'+str(current_index)+' \n')
        H_i+=1
       
      elif H_i==1:
        outfile.write('_rlnOriginY '+'#'+str(current_index)+' \n')
        H_i+=1
      else:
        current_index-=1


    else:
      outfile.write(current_split[0]+' #'+str(current_index)+' \n')

     

  star_st_line+=1
  tmp=star_lines[star_st_line]
  #print(tmp)
  current_split=tmp.split(' ')
  #print(current_split)
  len_cs=len(current_split)



#===================================================

#============more info from particles.star======================

part_file=open(args.particles)
part_lines=part_file.read().split('\n')


current_part_line=0
tmp_part=part_lines[current_part_line]

current_part_split=tmp_part.split(' ')
len_cps=len(current_part_split)
P_i=0

while(len_cps<10):
  if len_cps>=2:
    if P_i<=4 and  current_part_split[0].find(Part[P_i])!= -1:
      #print(current_part_split)
      Part_line.append(current_part_split[1].split('#')[1])
      current_index+=1  
      outfile.write(Part[P_i]+' #'+str(current_index)+' \n')
      P_i+=1
      
  current_part_line+=1
  tmp_part=part_lines[current_part_line]
  current_part_split=tmp_part.split(' ')
  len_cps=len(current_part_split)


#print(Part_line)
for opt in Optics:
  current_index+=1
  outfile.write(opt+' #'+str(current_index)+' \n')




#==================================back to cs file,write each line ,and search more info from particles.star


while star_st_line<Star_len:
  #print(star_st_line)
  if len(tmp)<10:
    break
  #print(tmp)


  write_line=tmp.split(' ')
  while '' in write_line:
    write_line.remove('')
#print(tmp)
  part_name=tmp.split(' ')[0].split('/')
  micro_name=part_name[len(part_name)-1].split('.')[0]
  #print(micro_name)
  particle_index=part_name[0].split('@')[0]
  if (args.polish):
    particle_index=str(int(particle_index))
    #print(particle_index)
  
  while '' in current_part_split:
    current_part_split.remove('')

#print(Part_line[2])

  image_name=current_part_split[args.name_index-1]
  
  f_p=image_name.find(particle_index)
  m_f=image_name.find(micro_name)
  #print(f_p)
  #print(m_f)
  while f_p==-1 :
    current_part_line+=1
    #print(current_part_line)
    try:
      tmp_part=part_lines[current_part_line]
    except:
      print('Particles File Ends. Still no match.')
      exit()
    
    current_part_split=tmp_part.split(' ')

    while '' in current_part_split:
      current_part_split.remove('')

    #print(image_name)
    if len(current_part_split)<10:
      print('Particles File Ends. Still no match.')
      exit()

    
    image_name=current_part_split[args.name_index-1]
    #print(image_name)
    f_p=image_name.find(particle_index)
    m_f=image_name.find(micro_name)

  while m_f==-1:
    current_part_line+=1
    try:
      tmp_part=part_lines[current_part_line]
    except:
      print('Particles File Ends. Still no match.')
      exit()
    
    current_part_split=tmp_part.split(' ')

    while '' in current_part_split:
      current_part_split.remove('')

    #print(image_name)
    if len(current_part_split)<10:
      print('Particles File Ends. Still no match.')
      exit()

    
    image_name=current_part_split[args.name_index-1]
    
    f_p=image_name.find(particle_index)
    m_f=image_name.find(micro_name)


  write_line[0]=image_name
  #print(write_line[11])
  #print(current_part_line)
  for i in range(len(Part_line)):
    write_line.append(current_part_split[int(Part_line[i])-1])
  for opti in range(3):
    write_line.append(ops[opti])
  write_line[args.angx-1]=str(float(write_line[args.angx-1])/args.pixel)
  write_line[args.angy-1]=str(float(write_line[args.angy-1])/args.pixel)

  for ri in range(11,len(write_line)-1):
    write_line[ri]=write_line[ri+1]

  #print(write_line)
  for wi in range(len(write_line)-1):
    outfile.write(' '+write_line[wi])
  outfile.write('\n')
  
  star_st_line+=1

  tmp=star_lines[star_st_line]
  current_split=tmp.split(' ')



