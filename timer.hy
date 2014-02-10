(import tkinter)
(import time)
(import math)

(defclass HyTimerWindow [tkinter.Tk]
  [[__init__
    (fn [self initial]
      (.__init__ tkinter.Tk self)
      (self.title "HyTimer")
      (setv self.initial initial)
      (setv self.remaining initial)
      (setv self.remaining_label (tkinter.StringVar))
      (.set self.remaining_label (self.format_seconds self.remaining))
      (setv self.running False)
      (setv self.update_period 100) 
      (setv self.display (kwapply (.Label tkinter self)
                                  {"textvariable" self.remaining_label
                                   "font" ["Helvetica" 22]}))
      (setv self.start_button (kwapply (.Button tkinter self)
                                       {"text" "START"
                                        "command" self.start}))
      (setv self.stop_button (kwapply (.Button tkinter self)
                                      {"text" "STOP"
                                       "command" self.stop
                                       "state" tkinter.DISABLED}))
      (setv self.reset_button (kwapply (.Button tkinter self)
                                       {"text" "RESET"
                                        "command" self.reset}))
      (kwapply (.grid self.display) {"row" 0})

      (for [index&button (enumerate [self.start_button
                                     self.stop_button
                                     self.reset_button])]
        (kwapply (.grid (second index&button))
                        {"row" (+ 1 (first index&button))}))
      (.mainloop self))]

   [start
    (fn [self]
      (setv self.running True)
      (setv self.last_updated (.time time))
      (.update self)
      (kwapply (.configure self.stop_button)
               {"state" tkinter.NORMAL})
      (kwapply (.configure self.start_button)
               {"state" tkinter.DISABLED}))]

   [stop
    (fn [self]
      (setv self.running False)
      (kwapply (.configure self.start_button)
               {"state" tkinter.NORMAL})
      (kwapply (.configure self.stop_button)
               {"state" tkinter.DISABLED}))]

   [reset
    (fn [self]
      (setv self.remaining self.initial)
      (setv self.last_updated (.time time))
      (.set self.remaining_label (self.format_seconds self.remaining)))]

    [format_seconds
     (with-decorator staticmethod
       (fn [seconds]
         (.format "{}:{:02}:{:04.1f}" 
                  (math.floor (/ seconds 3600))
                  (% (math.floor (/ seconds 60)) 60)
                  (% seconds 60))))]

    [update
     (fn [self]
       (setv now (.time time))
       (setv elapsed (- now self.last_updated))
       (setv self.last_updated now)
       (setv self.remaining (- self.remaining elapsed))
       (.set self.remaining_label (self.format_seconds self.remaining))
       (if self.running
         (.after self self.update_period self.update)))]

])

(if (= __name__ "__main__")
  (HyTimerWindow (* 20 60)))
