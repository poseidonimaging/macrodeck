#/bin/sh

rake macrodeck:import:countries COUNTRIES="db/data/countries.tsv"
rake macrodeck:import:regions REGIONS="db/data/us_states.tsv"
rake macrodeck:import:localities LOCALITIES="db/data/ok_cities.tsv"
rake macrodeck:import:localities LOCALITIES="db/data/tx_cities.tsv"
rake macrodeck:import:neighborhoods NEIGHBORHOODS="db/data/tulsa_neighborhoods.tsv"
rake macrodeck:import:neighborhoods NEIGHBORHOODS="db/data/austin_neighborhoods.tsv"
rake macrodeck:import:places PLACES="db/data/tulsa_places.tsv"
rake macrodeck:import:places PLACES="db/data/austin_places.tsv"