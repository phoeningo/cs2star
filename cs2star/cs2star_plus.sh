# Author :Kong Fang
#tmp_star=${1/cs/star}
echo Convert cs file to star file

#  for hetero_apo , (1026+0930) skip this step
#csparc2star.py $1 $tmp_star

tmp_star=$1
data_line=`awk '{if ($1=="data_particles") print NR}' $tmp_star`
data_line=`expr ${data_line} - 1`



#echo head length: $data_line

head -$data_line $tmp_star > tmp_little_head.star

#--------------------------------------------------------------------------------------------
#pixel_line=` awk '{if ($1=="_rlnImagePixelSize") print $2}' tmp_little_head.star |sed 's/#//' `

#echo pixel_line : $pixel_line

#pixel_size=`grep 0 tmp_little_head.star | awk '{ print $'$pixel_line' }' `
#echo pixel_size : $pixel_size

#----------------------------------------------------------------------------------------------



cs_line=` awk '{if ($1=="_rlnSphericalAberration") print $2}' tmp_little_head.star |sed 's/#//' `

#echo pixel_line : $pixel_line

cs=`grep 0 tmp_little_head.star | awk '{ print $'$cs_line' }' `
echo cs: $cs





#---------------------------------------------------------------------------------------------------


v_line=` awk '{if ($1=="_rlnVoltage") print $2}' tmp_little_head.star |sed 's/#//' `

#echo pixel_line : $pixel_line

v=`grep 0 tmp_little_head.star | awk '{ print $'$v_line' }' `
echo Voltage : $v


#------------------------------------------------------------------------------------------


amp_line=` awk '{if ($1=="_rlnAmplitudeContrast") print $2}' tmp_little_head.star |sed 's/#//' `

#echo pixel_line : $pixel_line

amp=`grep 0 tmp_little_head.star | awk '{ print $'$amp_line' }' `
echo AmplitudeConstrast : $amp




#----------------------------------------------------------------------------------------
awk '{if (NR>'$data_line')print}' $tmp_star>tmp_ori.star

grep -v mrc tmp_ori.star>tmp_cs_head.star





OpticsGroup=` awk '{if ($1=="_rlnOpticsGroup") print $2}' tmp_cs_head.star |sed 's/#//' `
opt_ind=` awk '{if ($1=="_rlnOpticsGroup") print NR}' tmp_cs_head.star `

total_line=`grep \# tmp_cs_head.star | wc -l`


`echo  $total_line - $OpticsGroup |bc >tmp_result`
remain=`cat tmp_result`
echo remain : $remain
#
# if extracted from micrographs, skip this 

#angx=` awk '{if ($1=="_rlnOriginXAngst") print $2}' tmp_cs_head.star |sed 's/#//' `
#echo angx : $angx
#angy=` awk '{if ($1=="_rlnOriginYAngst") print $2}' tmp_cs_head.star |sed 's/#//' `
#echo angy : $angy


grep mrc tmp_ori.star | sort -k 1 > tmp_sort_ori.star
# del  _rlnOpticsGroup here#
#
ans=`awk '{$'$OpticsGroup'=None;print $0 }' tmp_sort_ori.star > tmp_cut_ori.star` 

head -n $opt_ind tmp_cs_head.star >tmp_cut_head.star1
grep \# tmp_cut_head.star1 > tmp_line
grep \# tmp_cs_head.star > tmp_all
grep -vf tmp_line tmp_all > tmp_remain_head.star

sed 's/#//' tmp_remain_head.star >tmp_remain_head.star1 


ans=`awk '{$2=$2-1;print $0 }'  tmp_remain_head.star1 > tmp_remain_head.star2 `
#cat tmp_remain_head.star2
 
ans=`awk '{$2="#"$2;print $0 }'  tmp_remain_head.star2 > tmp_remain_head.star3 `

#grep -v $OpticsGroup tmp_cut_head.star1 > tmp_cut_head.star
grep -v $OpticsGroup tmp_cut_head.star1 > tmp_cut_head.star
cat tmp_remain_head.star3 >>tmp_cut_head.star

#
#------------------------------
#ADD _rlnVoltage #1  _rlnSphericalAberration #2  _rlnAmplitudeContrast #3 
#
start_line=`expr $OpticsGroup + $remain`
voltage_index=`expr $start_line + 0 `
cs_index=`expr $start_line + 1 `
ac_index=`expr $start_line + 2 `
mag_index=`expr $start_line + 3 `
tmp_ex=`expr $start_line + 4 `

#echo $voltage_index
echo '_rlnVoltage #'${voltage_index} >> tmp_cut_head.star
echo '_rlnSphericalAberration #'${cs_index} >>tmp_cut_head.star
echo '_rlnAmplitudeContrast #'${ac_index} >>tmp_cut_head.star
echo '_rlnMagnification #'${mag_index} >>tmp_cut_head.star

echo '_rlnDetectorPixelSize #'${tmp_ex} >>tmp_cut_head.star

`awk '   $0=$0" '$v' '$cs' '$amp' 10000.0"  ' tmp_cut_ori.star > tmp_grow_ori.star` 

# provide pixelsize--$3



cordx_line=` awk '{if ($1=="_rlnCoordinateX") print $2}' tmp_cs_head.star |sed 's/#//' `

echo cordxline : ${cordx_line}
cordy_line=` awk '{if ($1=="_rlnCoordinateY") print $2}' tmp_cs_head.star |sed 's/#//' `

#orix=` awk '{if ($1=="_rlnOriginXAngst") print $2}' tmp_cs_head.star |sed 's/#//' `
#oriy=` awk '{if ($1=="_rlnOriginYAngst") print $2}' tmp_cs_head.star |sed 's/#//' `

 
`awk '  {$'$tmp_ex'=$'${cordx_line}';$'${cordx_line}'=$'${cordy_line}';$'${cordy_line}'=$'$tmp_ex';$'$tmp_ex'='$3';print $0}  ' tmp_grow_ori.star>tmp_final_ori.star`

#`awk '  {$'$tmp_ex'=$'${orix}'/'$3';$'${orix}'=$'${oriy}'/'$3';$'${oriy}'=$'$tmp_ex';$'$tmp_ex'='$3';print $0}  ' tmp_final_ori.star1>tmp_final_ori.star`


echo writing tmp_input.star
cat tmp_cut_head.star tmp_final_ori.star > tmp_input.star
sed 's/  / /g' tmp_input.star > tmp_final1
sed 's/OriginXAngst/OriginX/g' tmp_final1>tmp_final2
sed 's/OriginYAngst/OriginY/g' tmp_final2>tmp_final3

sed 's/particles.mrc/particles.mrcs/g' tmp_final3>tmp_final4



mv tmp_final4 $2

##########################################
#  grep -v mrc $2 >tmp_part_head.star
#  image_name_line=` awk '{if ($1=="_rlnImageName") print $2}' tmp_part_head.star |sed 's/#//' `
#  echo imagename_line : ${image_name_line}
#
#  echo writing sorted_particles.star
#  grep mrc $2 |sort -k $image_name_line > tmp_part.star
#
#  cat tmp_part_head.star tmp_part.star > tmp_sort_part.star
#
#  echo final writing
##########################################
#python ~/bin/cs2star.py --star tmp_input.star --particles tmp_sort_part.star --name_index $image_name_line --pixel $pixel_size --angx $angx --angy $angy --cs $cs --v $v --amp $amp

#mv tmp_out.star $3
echo done.
rm tmp*


