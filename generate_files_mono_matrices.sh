#!/bin/bash


results=../results/files_mono
mkdir -p $results
negative_set_path=../lib/negative_arnaud/
genome=../data/tair10.fas

####################### ARF2 ###############################

sed 's/\./,/g' ../data/ARF2_peaks.narrowPeak | sort -k9,9nr -k7,7nr | head -600 | awk 'BEGIN{OFS="\t"}{print $1,$2,$3}' > $results/ARF2_top_regions.bed


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

sed 's/\./,/g' ../data/ARF2_peaks.narrowPeak | sort -k9,9nr -k7,7nr | tail -n +600  | awk -v OFS="\t" '{print $1,$2,$3}' > $results/ARF2_test.bed


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


####################### MP ###############################

sed 's/\./,/g' ../data/MP_peaks.narrowPeak | sort -k9,9nr -k7,7nr | head -600 | awk 'BEGIN{OFS="\t"}{print $1,$2,$3}' > $results/MP_top_regions.bed


python $negative_set_path/fonctions.py -pos $results/MP_top_regions.bed -neg MP_top_regions -o $results/ 

MP_fasta=$results/MP_top.fasta
MP_fasta_neg=$results/MP_top_neg.fasta

bed_train_pos=$(mktemp)
seq_train_pos=$(mktemp)
bedtools getfasta -fi $genome -fo $MP_fasta -bed $results/MP_top_regions.bed
grep ">" $MP_fasta | sed "s/>//" > $seq_train_pos
paste -d"\t" $results/MP_top_regions.bed $seq_train_pos > $bed_train_pos
cat $bed_train_pos  > $results/MP_top_regions.bed 

bed_train_neg=$(mktemp)
seq_train_neg=$(mktemp)
bedtools getfasta -fi $genome -fo $MP_fasta_neg -bed $results/MP_top_regions_1_neg.bed
grep ">" $MP_fasta_neg | sed "s/>//" > $seq_train_neg
paste -d"\t" $results/MP_top_regions_1_neg.bed $seq_train_neg > $bed_train_neg
cat $bed_train_neg  > $results/MP_top_regions_1_neg.bed 



# bed test files

sed 's/\./,/g' ../data/MP_peaks.narrowPeak | sort -k9,9nr -k7,7nr | tail -n +600  | awk -v OFS="\t" '{print $1,$2,$3}' > $results/MP_test.bed


python $negative_set_path/fonctions.py -pos $results/MP_test.bed -neg MP_test -o $results/ 


# fasta test files 

bed_pos=$(mktemp)
seq_pos=$(mktemp)
bedtools getfasta -fi $genome -fo $results/MP_test.fas -bed $results/MP_test.bed
grep ">" $results/MP_test.fas | sed "s/>//" > $seq_pos
paste -d"\t" $results/MP_test.bed $seq_pos > $bed_pos
cat $bed_pos  > $results/MP_test.bed 


bed_neg=$(mktemp)
seq_neg=$(mktemp)
bedtools getfasta -fi $genome -fo $results/MP_test_1_neg.fas -bed $results/MP_test_1_neg.bed
grep ">" $results/MP_test_1_neg.fas | sed "s/>//" > $seq_neg
paste -d"\t" $results/MP_test_1_neg.bed $seq_neg > $bed_neg
cat $bed_neg > $results/MP_test_1_neg.bed

# get matrices

./meme2pfm.sh ../data/ARF2_mono.meme ARF2 > $results/ARF2.pwm
./meme2pfm.sh ../data/MP_mono.meme MP > $results/MP.pwm

Rscript transpose.r $results/MP.pwm
Rscript transpose.r $results/ARF2.pwm

sed  $results/MP.pwm.brut -e 's/ / [ /' -e 's/$/ ]/' -e '1i>MP' > $results/MP.jaspar
sed  $results/ARF2.pwm.brut -e 's/ / [ /' -e 's/$/ ]/' -e '1i>ARF2' > $results/ARF2.jaspar

# compute scores

python scores.py -m $results/ARF2.pwm -f  $results/ARF2_test.fas -o $results  &
python scores.py -m $results/ARF2.pwm -f  $results/ARF2_test_1_neg.fas -o $results &

python scores.py -m $results/MP.pwm -f  $results/MP_test.fas -o $results  &
python scores.py -m $results/MP.pwm -f  $results/MP_test_1_neg.fas -o $results &


wait 


sed -i "1d" $results/ARF2_ARF2_test.fas.scores &
sed -i "1d" $results/ARF2_ARF2_test_1_neg.fas.scores &
sed -i "1d" $results/MP_MP_test.fas.scores &
sed -i "1d" $results/MP_MP_test_1_neg.fas.scores &


wait

paste <(sort -u -k1,1 -k4,4nr $results/ARF2_ARF2_test.fas.scores | sort -u -k1,1 | awk '{print $4}' ) <(sort -u -k1,1 -k4,4nr $results/ARF2_ARF2_test_1_neg.fas.scores | sort -u -k1,1 | awk '{print $4}' ) >  $results/tab_scores_ARF2.tsv

paste <(sort -u -k1,1 -k4,4nr $results/MP_MP_test.fas.scores | sort -u -k1,1 | awk '{print $4}' ) <(sort -u -k1,1 -k4,4nr $results/MP_MP_test_1_neg.fas.scores | sort -u -k1,1 | awk '{print $4}' ) >  $results/tab_scores_MP.tsv

# shape

./shape_MP.sh &
./shape_ARF2.sh

wait

# scores shape

paste <(awk '{print $6}' $results/DNAshapedPSSM_fg_predictions_ARF2.txt) <(awk '{print $6}' $results/DNAshapedPSSM_bg_predictions_ARF2.txt) | tail -n +2  > $results/tab_scores_ARF2_shape.tsv
paste <(awk '{print $6}' $results/DNAshapedPSSM_fg_predictions_MP.txt) <(awk '{print $6}' $results/DNAshapedPSSM_bg_predictions_MP.txt) | tail -n +2  > $results/tab_scores_MP_shape.tsv

#plot ROC

Rscript plot_ROC_pfm_vs_shape.r $results/tab_scores_MP.tsv  $results/tab_scores_MP_shape.tsv MP_pfm_vs_shape $results MP
Rscript plot_ROC_pfm_vs_shape.r $results/tab_scores_ARF2.tsv  $results/tab_scores_ARF2_shape.tsv ARF2_pfm_vs_shape $results ARF2




