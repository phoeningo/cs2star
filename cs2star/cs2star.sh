#===================
#
# Author : Fang Kong
#
#===================
tmp_star=${1/cs/star}
echo Convert cs file to star file

#  for hetero_apo , (1026+0930) skip this step
csparc2star.py $1 $tmp_star

#tmp_star=$1

data_line=`awk '{if ($1=="data_particles") print NR}' $tmp_star`
data_line=`expr ${data_line} - 1`



#echo head length: $data_line

head -$data_line $tmp_star > tmp_little_head.star

#--------------------------------------------------------------------------------------------
pixel_line=` awk '{if ($1=="_rlnImagePixelSize") print $2}' tmp_little_head.star |sed 's/#//' `

#echo pixel_line : $pixel_line

pixel_size=`grep 0 tmp_little_head.star | awk '{ print $'$pixel_line' }' `
echo pixel_size : $pixel_size

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


angx=` awk '{if ($1=="_rlnOriginXAngst") print $2}' tmp_cs_head.star |sed 's/#//' `
echo angx : $angx
angy=` awk '{if ($1=="_rlnOriginYAngst") print $2}' tmp_cs_head.star |sed 's/#//' `
echo angy : $angy


grep mrc tmp_ori.star | sort -k 1 > tmp_sort_ori.star
echo writing input_cs.star
cat tmp_cs_head.star tmp_sort_ori.star > tmp_input.star

grep -v mrc $2 >tmp_part_head.star
image_name_line=` awk '{if ($1=="_rlnImageName") print $2}' tmp_part_head.star |sed 's/#//' `
echo imagename_line : ${image_name_line}

echo writing sorted_particles.star
grep mrc $2 |sort -k $image_name_line > tmp_part.star

cat tmp_part_head.star tmp_part.star > tmp_sort_part.star

echo final writing
python ~/bin/cs2star.py --star tmp_input.star --particles tmp_sort_part.star --name_index $image_name_line --pixel $pixel_size --angx $angx --angy $angy --cs $cs --v $v --amp $amp

mv tmp_out.star $3
echo done.
rm tmp*star


