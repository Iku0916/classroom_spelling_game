# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"

pin "@rails/actioncable", to: "actioncable.esm.js"
pin "channels/consumer", to: "channels/consumer.js"
pin "channels/game_channel", to: "channels/game_channel.js"

pin "game_room", to: "game_room.js"
pin "onboarding", to: "onboarding.js"

pin_all_from "app/javascript/controllers", under: "controllers"
