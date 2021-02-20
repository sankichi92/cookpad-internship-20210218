class Authenticator
  class AlreadyRegistered < StandardError
  end
  class UserNotFound < StandardError
  end

  attr_accessor :record
  def initialize()
    @record = {}
  end

  def register(username, pubkey, pass)
    unless @record[username].nil?
      raise AlreadyRegistered
    end
    pair = {
      pubkey: pubkey,
      pass: pass,
    }
    @record[username] = pair
  end

  def req_pubkey(username)
    if @record[username].nil?
      raise UserNotFound
    end
    @record[username][:pubkey]
  end
end
