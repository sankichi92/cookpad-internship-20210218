def calc_login_response(token, pass)
  token_bytes = token.scan(/../).map { |b| b.to_i(16) }.pack('C*')
  pass_bytes = pass.scan(/../).map { |b| b.to_i(16) }.pack('C*')
  login_token = OpenSSL::HMAC.digest("SHA256", token_bytes, pass_bytes).unpack("C*").map { |b| b.to_s(16) }.join('')
end
