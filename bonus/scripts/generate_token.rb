require 'date'
user = User.find_by_username('root')
token = user.personal_access_tokens.create(
    name: 'Root Token 1',
    scopes: [:api],
    expires_at: Date.today + 30
)
token.set_token('token1')
token.save!
# Print the token
# puts token.token