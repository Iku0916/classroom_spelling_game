module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user || create_guest
    end

    private

    def find_verified_user
      if user_id = cookies.encrypted[:user_id]
        User.find_by(id: user_id)
      end
    end

    def create_guest
      guest_id = cookies.signed[:guest_id]
      guest = Guest.find_by(id: guest_id) if guest_id

      unless guest
        guest = Guest.create!
        cookies.signed[:guest_id] = {
          value: guest.id,
          expires: 1.year.from_now,
          httponly: true
        }
        logger.info "=== 新しいゲストユーザーを作成: id=#{guest.id} ==="
      end

      guest
    end
  end
end
