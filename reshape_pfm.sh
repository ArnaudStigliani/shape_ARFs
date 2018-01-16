#!/bin/bash

folder_pfm=../results/files/pfm_R
mkdir -p $folder_pfm

./meme2pfm.sh ../results/files/meme_ARF2/meme_out/meme_mini.txt ARF2 > $folder_pfm/ARF2.pfm
./meme2pfm.sh ../results/files/meme_MP/new_motif/meme.txt MP > $folder_pfm/MP.pfm

exit 0

