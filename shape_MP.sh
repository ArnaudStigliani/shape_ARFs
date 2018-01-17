#!/bin/bash

export PYTHONPATH=$PYTHONPATH:./
# Define where are located the DNA shape data from GBshape
araTha=/nobackup/data/shape
helt=$araTha/araTha10.HelT.bigWig;
mgw=$araTha/araTha10.MGW.bigWig;
prot=$araTha/araTha10.ProT.bigWig;
roll=$araTha/araTha10.Roll.bigWig;
helt2=$araTha/araTha10.HelT.2nd.bigWig;
mgw2=$araTha/araTha10.MGW.2nd.bigWig;
prot2=$araTha/araTha10.ProT.2nd.bigWig;
roll2=$araTha/araTha10.Roll.2nd.bigWig;

path_DNAshape=/home/as248291/Programmes/DNAshapedTFBS

# echo "Training a first order TFFM + DNA shape classifier.";
# time python2.7 ../DNAshapedTFBS.py trainTFFM -T TFFM_first_order.xml \
#     -i ../results/files/ARF2_top.fasta -I ../results/files/ARF2_top_regions.bed \
#     -b ../results/files/ARF2_top.fasta -B ../results/files/ARF2_top_regions.bed \
#     -o DNAshapedTFFM_fo_classifier -t first_order \
#     -1 $helt $prot $mgw $roll -2 $helt2 $prot2 $mgw2 $roll2 -n;

# echo "Training a detailed TFFM + DNA shape classifier.";
# time python2.7 ../DNAshapedTFBS.py trainTFFM -T TFFM_detailed.xml \
#     -i ../results/files/ARF2_top.fasta -I ../results/files/ARF2_top_regions.bed \
#     -b ../results/files/ARF2_top.fasta -B ../results/files/ARF2_top_regions.bed \
#     -o DNAshapedTFFM_d_classifier -t detailed \
#     -1 $helt $prot $mgw $roll -2 $helt2 $prot2 $mgw2 $roll2 -n;

echo "Training a PSSM + DNA shape classifier.";
time python2.7 $path_DNAshape/DNAshapedTFBS.py trainPSSM -f ../results/files/MP.jaspar \
    -i ../results/files/ARF2_top.fasta -I ../results/files/ARF2_top_regions.bed \
    -b ../results/files/ARF2_top_neg.fasta -B ../results/files/ARF2_top_regions_1_neg.bed \
    -o ../results/files/DNAshapedPSSM_classifier_MP \
    -1 $helt $prot $mgw $roll -2 $helt2 $prot2 $mgw2 $roll2 -n;



# echo "Training a 4-bits + DNA shape classifier.";
# time python2.7 ../DNAshapedTFBS.py train4bits -f MA0563.1.pfm \
#     -i ../results/files/ARF2_top.fasta -I ../results/files/ARF2_top_regions.bed \
#     -b ../results/files/ARF2_top.fasta -B ../results/files/ARF2_top_regions.bed \
#     -o DNAshaped4bits_classifier \
#     -1 $helt $prot $mgw $roll -2 $helt2 $prot2 $mgw2 $roll2 -n;

# echo "Applying the trained first order TFFM + DNA shape classifier on ../results/files sequences.";
# time python2.7 ../DNAshapedTFBS.py applyTFFM -T TFFM_first_order.xml \
#     -i ../results/files/test.fa -I ../results/files/test.bed \
#     -c DNAshapedTFFM_fo_classifier.pkl -o DNAshapedTFFM_fo_fg_predictions.txt \
#     -1 $helt $prot $mgw $roll -2 $helt2 $prot2 $mgw2 $roll2 -n;

# echo "Applying the trained detailed TFFM + DNA shape classifier on ../results/files sequences.";
# time python2.7 ../DNAshapedTFBS.py applyTFFM -T TFFM_detailed.xml \
#     -i ../results/files/test.fa -I ../results/files/test.bed \
#     -c DNAshapedTFFM_d_classifier.pkl -o DNAshapedTFFM_d_fg_predictions.txt \
#     -1 $helt $prot $mgw $roll -2 $helt2 $prot2 $mgw2 $roll2 -n;

echo "Applying the trained PSSM + DNA shape classifier on ../results/files sequences.";
time python2.7 $path_DNAshape/DNAshapedTFBS.py applyPSSM -f ../results/files/MP.jaspar \
    -i ../results/files/ARF2_test.fas -I ../results/files/ARF2_test.bed \
    -c ../results/files/DNAshapedPSSM_classifier_MP.pkl -o ../results/files/DNAshapedPSSM_fg_predictions_MP.txt \
    -v 0 \
    -1 $helt $prot $mgw $roll -2 $helt2 $prot2 $mgw2 $roll2 -n;

# echo "Applying the trained 4-bits + DNA shape classifier on ../results/files sequences.";
# time python2.7 ../DNAshapedTFBS.py apply4bits -f MA0563.1.pfm \
#     -i ../results/files/test.fa -I ../results/files/test.bed \
#     -c DNAshaped4bits_classifier.pkl -o DNAshaped4bits_fg_predictions.txt \
#     -1 $helt $prot $mgw $roll -2 $helt2 $prot2 $mgw2 $roll2 -n;

# echo "Applying the trained first order TFFM + DNA shape classifier on ../results/files sequences.";
# time python2.7 ../DNAshapedTFBS.py applyTFFM -T TFFM_first_order.xml \
#     -i ../results/files/test.fa -I ../results/files/test.bed \
#     -c DNAshapedTFFM_fo_classifier.pkl -o DNAshapedTFFM_fo_bg_predictions.txt \
#     -1 $helt $prot $mgw $roll -2 $helt2 $prot2 $mgw2 $roll2 -n;

# echo "Applying the trained detailed TFFM + DNA shape classifier on ../results/files sequences.";
# time python2.7 ../DNAshapedTFBS.py applyTFFM -T TFFM_detailed.xml \
#     -i ../results/files/test.fa -I ../results/files/test.bed \
#     -c DNAshapedTFFM_d_classifier.pkl -o DNAshapedTFFM_d_bg_predictions.txt \
#     -1 $helt $prot $mgw $roll -2 $helt2 $prot2 $mgw2 $roll2 -n;

echo "Applying the trained PSSM + DNA shape classifier on ../results/files sequences.";
time python2.7 $path_DNAshape/DNAshapedTFBS.py applyPSSM -f ../results/files/MP.jaspar \
    -i ../results/files/ARF2_test_1_neg.fas -I ../results/files/ARF2_test_1_neg.bed \
    -c ../results/files/DNAshapedPSSM_classifier_MP.pkl -o ../results/files/DNAshapedPSSM_bg_predictions_MP.txt \
    -v 0 \
    -1 $helt $prot $mgw $roll -2 $helt2 $prot2 $mgw2 $roll2 -n;

# echo "Applying the trained 4-bits + DNA shape classifier on ../results/files sequences.";
# time python2.7 ../DNAshapedTFBS.py apply4bits -f MA0563.1.pfm \
#     -i ../results/files/test.fa -I ../results/files/test.bed \
#     -c DNAshaped4bits_classifier.pkl -o DNAshaped4bits_bg_predictions.txt \
#     -1 $helt $prot $mgw $roll -2 $helt2 $prot2 $mgw2 $roll2 -n;
