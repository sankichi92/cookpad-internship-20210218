class Authenticator
  class AlreadyRegistered < StandardError
  end
  class UserNotFound < StandardError
  end

  attr_accessor :record
  def initialize()
    @record = {}
  end

  def register(username, salt, pass)
    unless @record[username].nil?
      raise AlreadyRegistered
    end
    pair = {
      salt: salt,
      pass: pass,
    }
    @record[username] = pair
  end

  def req_salt(username)
    if @record[username].nil?
      raise UserNotFound
    end
    @record[username][:salt]
  end
end
