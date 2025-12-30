module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user || create_guest
    end

    private

      def find_verified_user
        User.find_by(id: cookies.encrypted[:user_id])
      end

      def create_guest
        guest = Guest.find_by(id: cookies.encrypted[:guest_id])
  end
end
