#!/bin/bash


results=../results/files
mkdir -p $results
negative_set_path=../lib/negative_arnaud/
genome=../data/tair10.fas

# retrieving region for motif discovery

sed 's/\./,/g' ../data/ARF2_peaks.narrowPeak | sort -k9,9nr -k7,7nr | head -600 | awk 'BEGIN{OFS="\t"}{print $1,$2+50,$3-50}' > $results/ARF2_top_regions.bed

python $negative_set_path/fonctions.py -pos $results/ARF2_top_regions.bed -neg ARF2_top_regions -o $results/ 

ARF2_fasta=$results/ARF2_top.fasta
ARF2_fasta_neg=$results/ARF2_top_neg.fasta

bed_train_pos=$(mktemp)
seq_train_pos=$(mktemp)
bedtools getfasta -fi $genome -fo $ARF2_fasta -bed $results/ARF2_top_regions.bed
grep ">" $ARF2_fasta | sed "s/>//" > $seq_train_pos
paste -d"\t" $results/ARF2_top_regions.bed $seq_train_pos > $bed_train_pos
cat $bed_train_pos  > $results/ARF2_top_regions.bed 

bed_train_neg=$(mktemp)
seq_train_neg=$(mktemp)
bedtools getfasta -fi $genome -fo $ARF2_fasta_neg -bed $results/ARF2_top_regions_1_neg.bed
grep ">" $ARF2_fasta_neg | sed "s/>//" > $seq_train_neg
paste -d"\t" $results/ARF2_top_regions_1_neg.bed $seq_train_neg > $bed_train_neg
cat $bed_train_neg  > $results/ARF2_top_regions_1_neg.bed 



# bed test files

sed 's/\./,/g' ../data/ARF2_peaks.narrowPeak | sort -k9,9nr -k7,7nr | tail -n +600  | awk -v OFS="\t" '{print $1,$2+50,$3-50}' > $results/ARF2_test.bed


python $negative_set_path/fonctions.py -pos $results/ARF2_test.bed -neg ARF2_test -o $results/ 


# fasta test files 

bed_pos=$(mktemp)
seq_pos=$(mktemp)
bedtools getfasta -fi $genome -fo $results/ARF2_test.fas -bed $results/ARF2_test.bed
grep ">" $results/ARF2_test.fas | sed "s/>//" > $seq_pos
paste -d"\t" $results/ARF2_test.bed $seq_pos > $bed_pos
cat $bed_pos  > $results/ARF2_test.bed 


bed_neg=$(mktemp)
seq_neg=$(mktemp)
bedtools getfasta -fi $genome -fo $results/ARF2_test_1_neg.fas -bed $results/ARF2_test_1_neg.bed
grep ">" $results/ARF2_test_1_neg.fas | sed "s/>//" > $seq_neg
paste -d"\t" $results/ARF2_test_1_neg.bed $seq_neg > $bed_neg
cat $bed_neg > $results/ARF2_test_1_neg.bed



# get matrices

./meme2pfm.sh ../data/ARF2_mono.meme ARF2 > $results/ARF2.pwm
./build_ER_matrix.sh $results/ARF2.pwm ER7 3 > $results/ER7.pwm
./build_ER_matrix.sh $results/ARF2.pwm ER8 4 > $results/ER8.pwm

Rscript transpose.r $results/ER7.pwm
Rscript transpose.r $results/ER8.pwm

sed  $results/ER7.pwm.brut -e 's/ / [ /' -e 's/$/ ]/' -e '1i>ER7' > $results/ER7.jaspar
sed  $results/ER8.pwm.brut -e 's/ / [ /' -e 's/$/ ]/' -e '1i>ER8' > $results/ER8.jaspar

# compute scores 

python scores.py -m $results/ER7.pwm -f  $results/ARF2_test.fas -o $results  &
python scores.py -m $results/ER7.pwm -f  $results/ARF2_test_1_neg.fas -o $results &

python scores.py -m $results/ER8.pwm -f  $results/ARF2_test.fas -o $results  &
python scores.py -m $results/ER8.pwm -f  $results/ARF2_test_1_neg.fas -o $results &


wait 


sed -i "1d" $results/ER7_ARF2_test.fas.scores &
sed -i "1d" $results/ER7_ARF2_test_1_neg.fas.scores &
sed -i "1d" $results/ER8_ARF2_test.fas.scores &
sed -i "1d" $results/ER8_ARF2_test_1_neg.fas.scores &


wait

paste <(sort -u -k1,1 -k4,4nr $results/ER7_ARF2_test.fas.scores | sort -u -k1,1 | awk '{print $4}' ) <(sort -u -k1,1 -k4,4nr $results/ER7_ARF2_test_1_neg.fas.scores | sort -u -k1,1 | awk '{print $4}' ) >  $results/tab_scores_ER7_ARF2.tsv

paste <(sort -u -k1,1 -k4,4nr $results/ER8_ARF2_test.fas.scores | sort -u -k1,1 | awk '{print $4}' ) <(sort -u -k1,1 -k4,4nr $results/ER8_ARF2_test_1_neg.fas.scores | sort -u -k1,1 | awk '{print $4}' ) >  $results/tab_scores_ER8_ARF2.tsv


# shape

./shape_ER7.sh &
./shape_ER8.sh

wait

# scores shape

paste <(awk '{print $6}' $results/DNAshapedPSSM_fg_predictions_ER7.txt) <(awk '{print $6}' $results/DNAshapedPSSM_bg_predictions_ER7.txt) | tail -n +2  > $results/tab_scores_ER7_ARF2_shape.tsv
paste <(awk '{print $6}' $results/DNAshapedPSSM_fg_predictions_ER8.txt) <(awk '{print $6}' $results/DNAshapedPSSM_bg_predictions_ER8.txt) | tail -n +2  > $results/tab_scores_ER8_ARF2_shape.tsv

# best score ER7 ER8

paste $results/tab_scores_ER7_ARF2.tsv $results/tab_scores_ER8_ARF2.tsv | awk -v OFS="\t" '{print ($1>$3?$1:$3),($2>$4?$2:$4)}' > $results/tab_scores_ARF2.tsv
paste $results/tab_scores_ER7_ARF2_shape.tsv $results/tab_scores_ER8_ARF2_shape.tsv | awk -v OFS="\t" '{print ($1>$3?$1:$3),($2>$4?$2:$4)}' > $results/tab_scores_ARF2_shape.tsv

# plot ROCs

Rscript plot_ROC.r $results/tab_scores_ER7_ARF2.tsv  $results/tab_scores_ER8_ARF2.tsv pfm $results
Rscript plot_ROC.r $results/tab_scores_ER7_ARF2_shape.tsv  $results/tab_scores_ER8_ARF2_shape.tsv shape $results
Rscript plot_ROC_pfm_vs_shape.r $results/tab_scores_ARF2.tsv  $results/tab_scores_ARF2_shape.tsv pfm_vs_shape $results ARF2_dimer

exit 0
