import { application } from "./application"
import HelloController from "./hello_controller"
import ModalController from "./modal_controller"
import TimerController from "./timer_controller"
import GameController from "./game_controller"

application.register("hello", HelloController)
application.register("modal", ModalController)
application.register("timer", TimerController)
application.register("game", GameController)
