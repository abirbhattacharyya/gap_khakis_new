# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_gap_khakis_new_session',
  :secret      => '20c6605fec4e6a9aaed90e8953a776b4c3c852ee144e3232c1e7056f39f3d2af5b02ad9081845499b9113d5c97c4b278001ea5e29fed3e526b359a60caa67030'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
