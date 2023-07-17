require 'securerandom'
class User < ApplicationRecord
  encryption_key = SecureRandom.hex(32)

  acts_as_google_authenticated(
    :column_name => :username
    drift: 30, # Time allowed in seconds
    issuer: 'ryWeb',
    label: proc { email },
    otp_secret_encryption_key: encryption_key
  )
end
