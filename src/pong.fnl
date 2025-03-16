(local pong {})

(local state {})

(fn make-player [x y up-key down-key pos]
  {:x x
   :y y
   :up-key up-key
   :down-key down-key
   :height 100
   :speed 600
   :width 25
   :pos pos
   :score 0
   :draw (fn [self]
           (love.graphics.rectangle "fill" self.x self.y self.width self.height))
   :update (fn [self dt]
             (if (and (love.keyboard.isDown self.up-key)
                      (> self.y 0))
                 (set self.y (- self.y (* self.speed dt))))
             (if (and (love.keyboard.isDown self.down-key)
                      (< self.y (- 500 (* 1.5 self.height))))
                 (set self.y (+ self.y (* self.speed dt))))
             (if (pong.player-won? self)
                 (do
                    (print "PLAYER WON:" self.pos)
                    (set self.score (+ self.score 1))
                    (set state.ball.x 300)
                    (set state.ball.y 250)
                    )))})

(fn make-ball []
  {:radius 25
   :speed 600
   :x 100
   :y 100
   :dx 300
   :dy 100
   :draw (fn [self]
           (love.graphics.rectangle "fill" self.x self.y self.radius self.radius))
   :update (fn [self dt]
             (if (pong.wall-collision)
                 (do
                   (print "WALL!" self.y)
                   (set self.dy (* -1 self.dy))))
             (if (or (pong.paddle-collision state.p1)
                     (pong.paddle-collision state.p2))
                 (do
                   (print "PADDLE!" self.y "p2.y" state.p2.y)
                   (set self.dx (* -1 self.dx))))
             (set self.x (+ self.x (* self.dx dt)))
             (set self.y (+ self.y (* self.dy dt))))})

(fn pong.enter [self]
  (set state.counter 0)
  (set state.time 0)
  (set state.p1 (make-player 50 50 "q" "a" :left))
  (set state.p2 (make-player 700 50 "up" "down" :right))
  (set state.ball (make-ball))
  (set state.direction :down)
  (set state.vwidth 800)
  (set state.vheight 500)
  (set state.scale_x 1)
  (set state.scale_y 1)
  (pong.resize self 1920 1200)
  (love.graphics.setNewFont 24))

(fn pong.paddle-collision [player]
  (and (< state.ball.x (+ player.x player.width))
       (> (+ state.ball.x state.ball.radius) player.x)
       (< state.ball.y (+ player.y player.height))
       (> (+ state.ball.y state.ball.radius) player.y)))

(fn pong.wall-collision [self]
  (or (<= state.ball.y 0)
      (>= state.ball.y (- state.vheight (* 3 state.ball.radius)) )))

(fn pong.player-won? [player]
  (if (= :left player.pos)
      (< state.ball.x player.x)
      (> state.ball.x player.x)))

(fn pong.update [self dt]
  (state.p1:update dt)
  (state.p2:update dt)
  (state.ball:update dt))

(fn pong.draw [self]
  (love.graphics.origin) 
  (love.graphics.scale state.scale_x state.scale_y)
  (state.p1:draw)
  (state.p2:draw)
  (state.ball:draw)
  (love.graphics.print state.p2.score (/ state.vwidth 4) 10)
  (love.graphics.print state.p1.score (* 2.8 (/ state.vwidth 4)) 10))

(fn pong.resize [self w h]
  (set state.scale_x (/ w state.vwidth))
  (set state.scale_y (/ h state.vheight))
  (love.graphics.origin) 
  (love.graphics.scale state.scale_x state.scale_y))

(fn pong.keypressed [self key]
  (if (= key "r")  ; reload everything for easy debug
      (let [fennel (require :lib.fennel)
            gamestate (require :lib.gamestate)]
        (set package.loaded.pong nil)
        (local new-pong (require :pong))
        (gamestate.switch new-pong)))
  (if (= key "escape")
      (love.event.quit)))

pong
