require 'date'
user = User.find_by_username('root')
token = user.personal_access_tokens.create(
    name: 'Root Token 1',
    scopes: [:api],
    expires_at: Date.today + 30
)
    # s3cretP3rsonalT0ken
token.set_token('token')
token.save!
# Print the token
puts token.token