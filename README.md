##How to generate data

    bash bin/list_lois_promulguees.sh | while read url ; do perl bin/parse_dossier.pl $url ; done  > data/dossiers.csv
    bash bin/generate_data.sh data/dossiers.csv

