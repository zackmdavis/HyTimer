(import tkinter)

(defclass HyTimerWindow [tkinter.Tk]
  [[--init--
    (fn [self initial]
      (.--init-- tkinter.Tk self)
      (setv initial_label (str initial))
      (self.title (+ "HyTimer " initial_label))
      (setv self.time_label (kwapply (.Label tkinter self)
                                     {"text" initial_label
                                      "font" ["Helvetica" 22]}))
      (setv self.start_button (kwapply (.Button tkinter self)
                                       {"text" "START"}))
      (setv self.stop_button (kwapply (.Button tkinter self)
                                       {"text" "STOP"}))
      (.pack self.time_label)
      (.pack self.start_button)
      (.pack self.stop_button)
      (.mainloop self))]])

(if (= __name__ "__main__")
  (HyTimerWindow 20))
