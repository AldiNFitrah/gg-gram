require './models/user.rb'


class UserController
  def self.create(params)
    user = User.new({
      username: params['username'],
      email: params['email'],
      bio_description: params['bio_description'],
    })

    begin
      user.save()
    rescue Exception => e
      return [400, {error: e.to_s}.to_json()]
    end

    return [201, user.to_json()]
  end
end
