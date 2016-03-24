# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = set_current_user
    end

    protected
    def set_current_user
      current_user = User.find_by(id: cookies.signed[:user_id])
    end
  end
end
