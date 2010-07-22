RAILS_DEFAULT_LOGGER.info "Booting MacroDeck Platform on #{Rails.env}"
if defined?(MacroDeck::Platform)
	MacroDeck::Platform.start!("macrodeck-#{Rails.env}")
	RAILS_DEFAULT_LOGGER.error "MacroDeck Platform loaded!"
else
	RAILS_DEFAULT_LOGGER.error "MacroDeck Platform not loaded! This is probably bad!"
end
