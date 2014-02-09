(import tkinter)
(import time)
(import math)

(defclass HyTimerWindow [tkinter.Tk]
  [[__init__
    (fn [self initial]
      (.__init__ tkinter.Tk self)
      (self.title "HyTimer")
      (setv self.remaining initial)
      (setv self.remaining_label (tkinter.StringVar))
      (.set self.remaining_label (self.format_seconds self.remaining))
      (setv self.running False)
      (setv self.update_period 150) 
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
      (.pack self.display)
      (.pack self.start_button)
      (.pack self.stop_button)
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
