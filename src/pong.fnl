(local pong {})

(local state {})

(fn make-player [x y up-key down-key pos]
  {:x x
   :y y
   :up-key up-key
   :down-key down-key
   :height 100
   :speed 300
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
                    (set state.mode :countdown)
                    (state.ball:reset self.pos))))})

(fn make-ball []
  {:radius 25
   :x 100
   :y 100
   :dx 300
   :dy 100
   :draw (fn [self]
           (love.graphics.rectangle "fill" self.x self.y self.radius self.radius))
   :reset (fn [self direction]
            (set self.x 300)
            (set self.y 250)
            (set self.dx (math.random 50 100))
            (set self.dy (math.random 20 150))
            (if (= direction :left)
                (set self.dx (* -1 self.dx))))
   :update (fn [self dt]
             (if (pong.wall-collision)
                 (do
                   (print "WALL!" self.y)
                   (set self.dy (* -1 self.dy))))

             (let [paddle (if (pong.paddle-collision state.p1)
                              state.p1
                              (pong.paddle-collision state.p2)
                              state.p2
                              nil)]
               (when paddle
                   (print "PADDLE! bally" self.y "py" paddle.y "px" paddle.x )
                   ;;go faster on each bounce
                   (if (> self.dx 0)
                       (do
                         (set self.dx (+ self.dx 20))
                         (while (pong.paddle-collision paddle)
                           (set self.x (- self.x 1))))
                       (do
                         (set self.dx (- self.dx 20))
                         (while (pong.paddle-collision paddle)
                           (set self.x (+ self.x 1)))))
                   (if (love.keyboard.isDown paddle.down-key)
                       (set self.dy (+ self.dy 100)))
                   (if (love.keyboard.isDown paddle.up-key)
                       (set self.dy (- self.dy 100)))
                   (set self.dx (* -1 self.dx))))
             (set self.x (+ self.x (* self.dx dt)))
             (set self.y (+ self.y (* self.dy dt))))})

(fn pong.enter [self]
  ;;either in countdown mode or playing mode
  (set state.mode :countdown)
  (set state.timeout 5)
  (set state.timeleft state.timeout)
  (set state.p1 (make-player 50 50 "q" "a" :left))
  (set state.p2 (make-player 700 50 "up" "down" :right))
  (set state.ball (make-ball))
  (state.ball:reset)
  (set state.direction :down)
  (set state.vwidth 800)
  (set state.vheight 500)
  (set state.scale_x 1)
  (set state.scale_y 1)
  (pong.resize self 1920 1200)
  (love.graphics.setNewFont 24))

(fn pong.paddle-collision [paddle]
  (and (< state.ball.x (+ paddle.x paddle.width))
       (> (+ state.ball.x state.ball.radius) paddle.x)
       (< state.ball.y (+ paddle.y paddle.height))
       (> (+ state.ball.y state.ball.radius) paddle.y)))

(fn pong.wall-collision [self]
  (or (<= state.ball.y 0)
      (>= state.ball.y (- state.vheight (* 3 state.ball.radius)) )))

(fn pong.player-won? [player]
  (if (= :left player.pos)
      (< state.ball.x player.x)
      (> state.ball.x player.x)))

(fn pong.update-countdown [self dt]
  (set state.timeleft (- state.timeleft dt))
  (if (<= state.timeleft 0)
      (do
        (print "timeleft:" state.timeleft)
        (set state.timeleft state.timeout)
        (set state.mode :playing))))
  
(fn pong.update [self dt]
  (state.p1:update dt)
  (state.p2:update dt)
  (if (= state.mode :countdown)
      (pong.update-countdown self dt)
      (state.ball:update dt)))

(fn pong.draw [self]
  (love.graphics.origin) 
  (love.graphics.scale state.scale_x state.scale_y)
  (state.p1:draw)
  (state.p2:draw)
  (if (= state.mode :countdown)
      (love.graphics.print (string.format "%.1f" state.timeleft) (- (/ state.vwidth 2) 50) (/ state.vheight 2))
      (state.ball:draw))
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
