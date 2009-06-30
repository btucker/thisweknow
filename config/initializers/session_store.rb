# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_datagov_session',
  :secret      => '296d1ce174cef971bfb9de0665387001cb21d17520bb47910c6f82375c976706972ca1141d7e487213fab233e833ae080fd8d0ab01c3e1d4c8f3c0da4c3715e1'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
