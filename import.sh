#/bin/sh
RAILS_ENV="production"

rake macrodeck:import:countries COUNTRIES="db/data/countries.tsv" RAILS_ENV="${RAILS_ENV}"
rake macrodeck:import:regions REGIONS="db/data/us_states.tsv" RAILS_ENV="${RAILS_ENV}"
rake macrodeck:import:localities LOCALITIES="db/data/ok_cities.tsv" RAILS_ENV="${RAILS_ENV}"
rake macrodeck:import:localities LOCALITIES="db/data/tx_cities.tsv" RAILS_ENV="${RAILS_ENV}"
rake macrodeck:import:neighborhoods NEIGHBORHOODS="db/data/tulsa_neighborhoods.tsv" RAILS_ENV="${RAILS_ENV}"
rake macrodeck:import:neighborhoods NEIGHBORHOODS="db/data/austin_neighborhoods.tsv" RAILS_ENV="${RAILS_ENV}"
rake macrodeck:import:places PLACES="db/data/tulsa_places.tsv" RAILS_ENV="${RAILS_ENV}"
rake macrodeck:import:places PLACES="db/data/austin_places.tsv" RAILS_ENV="${RAILS_ENV}"
rake macrodeck:import:events EVENTS="db/data/austin_events.tsv" RAILS_ENV="${RAILS_ENV}"
