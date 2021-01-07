#Author : Kong Fang
input=$1
x=5760
y=4092

cordx_line=` awk '{if ($1=="_rlnCoordinateX") print $2}' ${input} |sed 's/#//' `
echo cordx_line : ${cordx_line}

cordy_line=` awk '{if ($1=="_rlnCoordinateY") print $2}' ${input} |sed 's/#//' `
echo cordy_line : ${cordy_line}

  orix=` awk '{if ($1=="_rlnOriginX") print $2}' ${input} |sed 's/#//' `
  echo orix : ${orix}

  oriy=` awk '{if ($1=="_rlnOriginY") print $2}' ${input} |sed 's/#//' `
  echo oriy : ${oriy}
 

` head -n 50 ${input} | grep mrc | awk '{print NF}' | tail -1 >tmp_r2s `
tmp_ex=`cat tmp_r2s`
tmp_ex=`expr $tmp_ex + 1 `
echo tmp_ex : ${tmp_ex}
rm tmp_r2s


`head -n 50 ${input} |grep -v mrc > tmp_head.star`
grep mrc $1 >tmp_c.star
`awk '  {$'$tmp_ex'=$'${cordx_line}';$'${cordx_line}'=$'${cordy_line}'*'$x'/'$y';$'${cordy_line}'=$'$tmp_ex'*'$y'/'$x';$'$tmp_ex'=None;print $0}' tmp_c.star >tmp1.star`

   `awk '  {$'$tmp_ex'=$'${orix}';$'${orix}'=$'${oriy}'*'$x'/'$y';$'${oriy}'=$'$tmp_ex'*'$y'/'$x';$'$tmp_ex'=None;print $0} ' tmp1.star>tmp2.star`

#mv tmp2.star $2
#rm tmp1.star
#exit

cat tmp_head.star > $2
cat tmp2.star >>$2
rm tmp1.star
rm tmp_c.star
rm tmp2.star
rm tmp_head.star
