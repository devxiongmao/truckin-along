Geocoder.configure do |config|
  # Geocoding options
  config.timeout = 5                  # geocoding service timeout (secs)

  # Environment-specific configuration
  if Rails.env.test? || ENV["CI"] == "true" || ENV["GITHUB_ACTIONS"] == "true" || ENV["GEOCODER_DISABLED"] == "true"
    # Test mode - use much faster test adapter
    puts "Using Geocoder test mode configuration"
    config.lookup = :test
    config.ip_lookup = :test
    config.timeout = 0.1  # Very short timeout for faster failures if something goes wrong
  else
    # Normal mode
    config.lookup = :nominatim          # name of geocoding service (symbol)
    # config.ip_lookup = :ipinfo_io     # name of IP address geocoding service (symbol)
    config.language = :en               # ISO-639 language code
    config.use_https = true             # use HTTPS for lookup requests? (if supported)
    # config.http_proxy = nil           # HTTP proxy server (user:pass@host:port)
    # config.https_proxy = nil          # HTTPS proxy server (user:pass@host:port)
    config.api_key = nil                # API key for geocoding service
  end

  # Exceptions that should not be rescued by default
  # (if you want to implement custom error handling);
  # supports SocketError and Timeout::Error
  # config.always_raise = []

  # Calculation options
  # config.units = :mi                # :km for kilometers or :mi for miles
  # config.distances = :linear        # :spherical or :linear

  # Cache configuration
  # config.cache_options = {
  #   expiration: 2.days,
  #   prefix: 'geocoder:'
  # }
end
