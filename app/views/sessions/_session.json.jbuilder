json.extract! session, :id, :username, :password, :created_at, :updated_at
json.url session_url(session, format: :json)
