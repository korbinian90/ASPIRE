for FILE in /net/mri.meduniwien.ac.at/projects/radiology/acqdata/data/nifti_and_ima/*/nifti/*/text_header.txt
do
#  grep -q 'alTE\[0\].*= 5000' $FILE && echo $FILE
  grep -q 'alTE\[0\].*= 6000' $FILE && grep -q 'alTE\[1\].*= 12000' $FILE && grep -q 'alTE\[2\].*= 18000' $FILE && grep -q 'ucReadOutMode.*= 0x1' $FILE && echo $FILE
done

