# SpeedPPI

This repository forked from [SpeedPPI](https://github.com/patrickbryant1/SpeedPPI). This repository just change some bash scripts to let the software run on the cluster.

## Installation

### Python packages

1. Login to the cluster
2. Clone the repository and set the environment variable using [Mamba](https://mamba.readthedocs.io/en/latest/installation/mamba-installation.html)

    ```bash
    git clone git@github.com:luxiangze/SpeedPPI.git
    cd SpeedPPI
    mamba env create -f speed_ppi.yml
    ```

3. Activate the environment

    ```bash
    mamba activate speed_ppi
    pip install --upgrade "jax[cuda12_pip]" -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html
    pip install --upgrade dm-haiku
    ```

4. Check the GPU availability

    ```bash
    python3 ./src/test_gpu_avail.py
    ```

    If the output is "gpu" - everything is fine.

### HHblits, Uniclust30 and AlphaFold2 parameters

1. Fetch the static SSE2 build.

    ```bash
    mkdir hh-suite
    cd hh-suite
    wget https://github.com/soedinglab/hh-suite/releases/download/v3.3.0/hhsuite-3.3.0-SSE2-Linux.tar.gz
    tar xvfz hhsuite-3.3.0-SSE2-Linux.tar.gz
    cd ..
    ```

2. Fetch the Uniclust30 database(25 Gb download, 87 Gb extracted).

    ```bash
    wget http://wwwuser.gwdg.de/~compbiol/uniclust/2018_08/uniclust30_2018_08_hhsuite.tar.gz --no-check-certificate
    tar -zxvf uniclust30_2018_08_hhsuite.tar.gz -C data/
    ```

3. Fetch the AlphaFold2 parameters.

    ```bash
    mkdir data/params
    wget https://storage.googleapis.com/alphafold/alphafold_params_2021-07-14.tar
    mv alphafold_params_2021-07-14.tar data/params
    tar -xf data/params/alphafold_params_2021-07-14.tar
    mv params_model_1.npz data/params
    ```

4. Cleanup - remove unnecessary files

    ```bash
    rm uniclust30_2018_08_hhsuite.tar.gz
    rm data/params/alphafold_params_2021-07-14.tar
    rm params_*.npz
    rm hh-suite/hhsuite*.tar.gz
    ```

## Usage

### Some VS Some mode

1. Creating individual fastas

    **Note:** The `data/seqs` directory should contain the fasta files of the proteins to be compared, and fasta file's suffix should be `.fa`.

    ```bash
    bash src/Create_individual_fastas.sh data/seqs data/results
    ```

2. Running HHblits

    ```bash
    sbatch src/parallel/hhblits_parallel.sh 1 data/results data/results/fasta/Dm_protein hh-suite/bin/hhblits
    ```

3. Running alphaFold to predict protein structures

    ```bash
    sbatch src/parallel/alphafold_some_vs_some_parallel.sh 0 data/results/DHX15 data/results/fasta/DHX15_protein data/results/fasta/DHX15-MS_protein
    ```
