(local gamestate (require :lib.gamestate))
(local stdio (require :lib.stdio))

(fn love.load [args]
  (print "ok doing reload")
  (love.graphics.setDefaultFilter "nearest" "nearest" 0)
  (if (= :web (. args 1)) 
      (global web true) 
      (global web false))
  (local pong (require :pong))
  (gamestate.registerEvents)
  (gamestate.switch pong)  ;; Ensure mode-intro.fnl exists and returns a valid state table
  (when (not web) (stdio.start)))  ;; Only start stdio if not in web mode

(love.load :normal)
