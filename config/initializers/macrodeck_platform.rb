RAILS_DEFAULT_LOGGER.info "Booting MacroDeck Platform on #{Rails.env}"
if defined?(MacroDeck::Platform)
	MacroDeck::Platform.start!("macrodeck-#{Rails.env}")
	MacroDeck::PlatformDataObjects.define!

	RAILS_DEFAULT_LOGGER.info "MacroDeck Platform loaded!"
else
	RAILS_DEFAULT_LOGGER.error "MacroDeck Platform not loaded! This is probably bad!"
	raise "MacroDeck Platform not loaded! This is probably bad!"
end