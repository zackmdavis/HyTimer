(import tkinter)

(defclass HyTimerWindow [tkinter.Tk]
  [[--init--
    (fn [self initial]
      (.--init-- tkinter.Tk self)
      (self.title (+ "HyTimer " (str initial)))
      (.mainloop self))]])

(if (= __name__ "__main__")
  (HyTimerWindow 20))
