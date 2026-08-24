# Reference setup for ampliconSeq

Last updated: 2026-08-07

## Reference genome used

- Assembly: `VectorBase-50_AaegyptiLVP_AGWG_Genome`
- FASTA file: `ref/VectorBase-50_AaegyptiLVP_AGWG_Genome.fasta`
- Source URL:  
  `https://vectorbase.org/a/service/raw-files/release-50/AaegyptiLVP_AGWG/fasta/data/VectorBase-50_AaegyptiLVP_AGWG_Genome.fasta`

## Download command

```bash
mkdir -p ref
curl -fL -o ref/VectorBase-50_AaegyptiLVP_AGWG_Genome.fasta \
  "https://vectorbase.org/a/service/raw-files/release-50/AaegyptiLVP_AGWG/fasta/data/VectorBase-50_AaegyptiLVP_AGWG_Genome.fasta"
```

## Required indexes

### FASTA index (.fai)

```bash
CTR_BIN=/usr/local/packages/singularity/bin/singularity
PROJ=/local/projects-t2/CVD/bioinformatics_core/RM01_McCann_Rob/BC01_260XX_DENV_PILOT_AMPSEQ/ampliconSeq
REF="$PROJ/ref/VectorBase-50_AaegyptiLVP_AGWG_Genome.fasta"

$CTR_BIN exec --bind "$PROJ:$PROJ" --pwd "$PROJ" \
  "$PROJ/containers/samtools_1.21.sif" \
  samtools faidx "$REF"
```

### Sequence dictionary (.dict)

```bash
$CTR_BIN exec --bind "$PROJ:$PROJ" --pwd "$PROJ" \
  "$PROJ/containers/gatk4_4.1.9.0.sif" \
  gatk CreateSequenceDictionary \
  -R ref/VectorBase-50_AaegyptiLVP_AGWG_Genome.fasta \
  -O ref/VectorBase-50_AaegyptiLVP_AGWG_Genome.dict
```

## Validation

```bash
ls -lh ref/VectorBase-50_AaegyptiLVP_AGWG_Genome.fasta \
       ref/VectorBase-50_AaegyptiLVP_AGWG_Genome.fasta.fai \
       ref/VectorBase-50_AaegyptiLVP_AGWG_Genome.dict
```

## Runtime config

Set in `config/runtime.env`:

```bash
REF_FASTA=/local/projects-t2/CVD/bioinformatics_core/RM01_McCann_Rob/BC01_260XX_DENV_PILOT_AMPSEQ/ampliconSeq/ref/VectorBase-50_AaegyptiLVP_AGWG_Genome.fasta
AMPLICON_BED=/local/projects-t2/CVD/bioinformatics_core/RM01_McCann_Rob/BC01_260XX_DENV_PILOT_AMPSEQ/ampliconSeq/amplicon.loci.bed
```

## Notes

- Initial legacy URL attempts returned `404`; raw-files endpoint above is the working source.
- Remove failed zero-byte artifact if present:
  ```bash
  rm -f ref/VectorBase-50_AaegyptiLVP_AGWG_Genome.fasta.gz
  ```