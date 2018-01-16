#!/bin/bash


results=../results/files
mkdir -p $results
negative_set_path=../lib/negative_arnaud/
genome=../data/tair10.fas

# retrieving region for motif discovery

sed 's/\./,/g' ../data/ARF2_peaks.narrowPeak | sort -k9,9nr -k7,7nr | head -600 | awk 'BEGIN{OFS="\t"}{print $1,$2+50,$3-50}' > $results/ARF2_top_regions.bed

ARF2_fasta=$results/ARF2_top.fasta

bedtools getfasta -fi $genome -fo $ARF2_fasta -bed $results/ARF2_top_regions.bed

# bed test files

sed 's/\./,/g' ../data/ARF2_peaks.narrowPeak | sort -k9,9nr -k7,7nr | tail -n +600  | awk -v OFS="\t" '{print $1,$2+50,$3-50}' > $results/ARF2_test.bed


python $negative_set_path/fonctions.py -pos $results/ARF2_test.bed -neg ARF2_test -o $results/ 


# fasta test files 

bed_pos=$(mktemp)
seq_pos==$(mktemp)
bedtools getfasta -fi $genome -fo $results/ARF2_test.fas -bed $results/ARF2_test.bed
grep ">" $results/ARF2_test.fas | sed "s/>//" > $seq_pos
paste -d"\t" $results/ARF2_test.bed $seq_pos > $bed_pos
cat $bed_pos  > $results/ARF2_test.bed 

$results/ARF2_test.bed
bed_neg=$(mktemp)
seq_neg=$(mktemp)
bedtools getfasta -fi $genome -fo $results/ARF2_test_1_neg.fas -bed $results/ARF2_test_1_neg.bed
grep ">" $results/ARF2_test_1_neg.fas | sed "s/>//" > $seq_neg
paste -d"\t" $results/ARF2_test_1_neg.bed $seq_neg > $bed_neg
cat $bed_neg > $results/ARF2_test_1_neg.bed



# get matrices

./meme2pfm.sh ../data/ARF2_mono.meme ARF2 > $results/ARF2.pwm
./build_ER_matrix.sh ../results/files/ARF2.pwm ER7 3 > $results/ER7.pwm
./build_ER_matrix.sh ../results/files/ARF2.pwm ER8 4 > $results/ER8.pwm

Rscript transpose.r $results/ER7.pwm
Rscript transpose.r $results/ER8.pwm

sed  $results/ER7.pwm.brut -e 's/ / [ /' -e 's/$/ ]/' -e '1i>ER7' > $results/ER7.jaspar
sed  $results/ER8.pwm.brut -e 's/ / [ /' -e 's/$/ ]/' -e '1i>ER8' > $results/ER8.jaspar

# compute scores 

python scores.py -m $results/ER7.pwm -f  ../results/files/ARF2_test.fas -o ../results/files  &
python scores.py -m $results/ER7.pwm -f  ../results/files/ARF2_test_1_neg.fas -o ../results/files &

python scores.py -m $results/ER8.pwm -f  ../results/files/ARF2_test.fas -o ../results/files  &
python scores.py -m $results/ER8.pwm -f  ../results/files/ARF2_test_1_neg.fas -o ../results/files &


wait 


sed -i "1d" ../results/files/ER7_ARF2_test.fas.scores &
sed -i "1d" ../results/files/ER7_ARF2_test_1_neg.fas.scores &
sed -i "1d" ../results/files/ER8_ARF2_test.fas.scores &
sed -i "1d" ../results/files/ER8_ARF2_test_1_neg.fas.scores &


wait

paste <(sort -u -k1,1 -k4,4nr $results/ER7_ARF2_test.fas.scores | sort -u -k1,1 | awk '{print $4}' ) <(sort -u -k1,1 -k4,4nr $results/ER7_ARF2_test_1_neg.fas.scores | sort -u -k1,1 | awk '{print $4}' ) >  $results/tab_scores_ER7_ARF2.tsv

paste <(sort -u -k1,1 -k4,4nr $results/ER8_ARF2_test.fas.scores | sort -u -k1,1 | awk '{print $4}' ) <(sort -u -k1,1 -k4,4nr $results/ER8_ARF2_test_1_neg.fas.scores | sort -u -k1,1 | awk '{print $4}' ) >  $results/tab_scores_ER8_ARF2.tsv



# plot_ROCs

Rscript plot_ROC.r ../results/files/tab_scores_ER7_ARF2.tsv  ../results/files/tab_scores_ER8_ARF2.tsv

# shape

./shape_ER7.sh
#./shape_ER8.sh

exit 0
