for FILE in /net/mri.meduniwien.ac.at/projects/radiology/acqdata/data/nifti_and_ima/*/nifti/*/text_header.txt
do
  grep -q 'alTE\[0\].*= 5000' && grep -q 'alTE\[1\].*= 10000' && grep -q 'alTE\[2\].*= 15000' && grep -q 'ucReadOutMode.*= 0x2' && echo $FILE
done

