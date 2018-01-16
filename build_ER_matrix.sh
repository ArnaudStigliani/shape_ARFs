#!/bin/bash

matrix=$1
name_matrix=$2
spacing=$3
header="MATRIX COUNT SYMETRIC $name_matrix SIMPLE\nA\tC\tG\tT"


pfm_mono=$(tail -n +3 $matrix)
echo -e "$header"
echo -e "$pfm_mono"
for i in `seq 1 $spacing`
do
    echo -e "1\t1\t1\t1"
done
echo -e "$pfm_mono" | tac | awk -v OFS="\t" '{print $4,$3,$2,$1}'
