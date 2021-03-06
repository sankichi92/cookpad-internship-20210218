require_relative './authenticator'
require 'openssl'
require 'securerandom'

class SessionManager
  attr_accessor :sessions, :authenticator

  class WrongPassword < StandardError
  end
  class UnknownSession < StandardError
  end

  def initialize()
    @sessions = {}
    @authenticator = Authenticator.new()
  end

  def session_info(sess)
    sess = sess.to_s
    sessions[sess]
  end

  def signup(sess, user, salt, pass, payload)
    sess = sess.to_s
    @authenticator.register(user, salt, pass)
    sessions[sess] = { user: user, login: true, token: nil, payload: payload }
  end

  def start_login(sess, user)
    sess = sess.to_s
    token = SecureRandom.hex(32)
    res = {
      salt: @authenticator.req_salt(user),
      token: token,
    }
    payload = nil
    unless @sessions[sess].nil?
      payload = @sessions[sess][:payload]
    end
    @sessions[sess] = { user: user, login: false, token: token, payload: payload }
    res
  end

  def request_info(sess)
    sess = sess.to_s
    if @sessions[sess].nil?
      @sessions[sess] = { user: nil, login: false, token: nil, payload: nil }
    end
    ({ login: @sessions[sess][:login], user: @sessions[sess][:user], payload: @sessions[sess][:payload] })
  end

  def confirm_login(sess, res_token, payload)
    sess = sess.to_s
    if @sessions[sess].nil?
      raise UnknownSession
    end
    user = @sessions[sess][:user]
    token = @sessions[sess][:token]
    pass = @authenticator.record[user][:pass]
    token_bytes = token.scan(/../).map { |b| b.to_i(16) }.pack('C*')
    pass_bytes = pass.scan(/../).map { |b| b.to_i(16) }.pack('C*')
    login_token = OpenSSL::HMAC.digest("SHA256", token_bytes, pass_bytes).unpack("C*").map { |b| b.to_s(16) }.join('')
    if login_token.to_s == res_token.to_s
      @sessions[sess][:login] = true
      @sessions[sess][:payload] = payload
      ({ result: true })
    else
      raise WrongPassword
    end
  end

  def logout(sess)
    sess = sess.to_s
    unless @sessions[sess].nil?
      @sessions[sess][:login] = false
    end
  end
end
