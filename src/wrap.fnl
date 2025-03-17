(local gamestate (require :lib.gamestate))
(local stdio (require :lib.stdio))

(fn love.load [args]
  (love.graphics.setDefaultFilter "nearest" "nearest" 0)
  (global web (= :web (. args 1)))  ; Simplified web check
  (local pong (require :pong))
  (gamestate.registerEvents)      
  (gamestate.switch pong)
  (when (not web) (stdio.start)))
