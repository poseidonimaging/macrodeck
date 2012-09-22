RAILS_DEFAULT_LOGGER.info "Booting MacroDeck Platform on #{Rails.env}"

if defined?(MacroDeck::Platform)
	# Load macrodeck.yml to get DB URL.
	db_url = ""
	cfg = {}

	File.open("#{Rails.root}/config/macrodeck.yml") do |yml|
		cfg = YAML::load(yml)
	end

	if cfg.key?(Rails.env.to_s) && cfg[Rails.env.to_s].key?("db_url")
		db_url = cfg[Rails.env.to_s]["db_url"]
	else
		db_url = "macrodeck-#{Rails.env}"
	end

	MacroDeck::Platform.start!(db_url)
	MacroDeck::PlatformDataObjects.define!

	RAILS_DEFAULT_LOGGER.info "MacroDeck Platform loaded!"
else
	RAILS_DEFAULT_LOGGER.error "MacroDeck Platform not loaded! This is probably bad!"
	raise "MacroDeck Platform not loaded! This is probably bad!"
end
