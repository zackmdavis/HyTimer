(import tkinter)
(import time)

(defclass HyTimerWindow [tkinter.Tk]
  [[__init__
    (fn [self initial]
      (.__init__ tkinter.Tk self)
      (setv self.remaining initial)
      (setv self.running False)
      (self.title (+ "HyTimer " (str self.remaining)))
      (setv self.time_label (kwapply (.Label tkinter self)
                                     {"text" (str self.remaining)
                                      "font" ["Helvetica" 22]}))
      (setv self.start_button (kwapply (.Button tkinter self)
                                       {"text" "START"
                                        "command" self.start}))
      (setv self.stop_button (kwapply (.Button tkinter self)
                                      {"text" "STOP"
                                       "command" self.stop
                                       "state" tkinter.DISABLED}))
      (.pack self.time_label)
      (.pack self.start_button)
      (.pack self.stop_button)
      (.mainloop self))]

   [start
    (fn [self]
      (setv self.running True)
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

])

(if (= __name__ "__main__")
  (HyTimerWindow 20))
