# cs2star
!!!
You should have installed pyem from https://github.com/asarnow/pyem and make sure that the  'csparc2star.py ' script runs correctly .
!!!

cs2star.sh is used only for :
  
      1. Particles were extracted in RELION
      2. After running Hetreo Refine and Non Uniform Refine jobs in cryoSPARC 
      
Note that:
 
      1.If you use cs2star converted star to run further class3d in RELION ,you should check whether these particle stack files were end with .mrcs . IF not ,use 'ln -s 'command to do so.
      
 usage:  cs2star.sh xxxx.cs  particles.star  newname.star
 
         xxxx.cs is the final particles .cs outputfile in NON-UNIFORM job directory
         particles.star is the extracted particles meta when you extract particles using RELION
         
         
cs2star_plus.sh can be used for more types of jobs in cryoSPARC, [even when you extract particles in cryoSPARC, it will also work.], Please contact me to get further usage.
      
