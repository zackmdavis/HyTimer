(import math)
(import time)
(import re)
(import functools)

(import tkinter)
(import tkinter.messagebox)

(defclass HyTimerWindow [tkinter.Tk]
  [[--init--
    (fn [self initial]
      (.--init-- tkinter.Tk self)
      (self.title "HyTimer")
      (setv self.initial initial)
      (setv self.remaining initial)
      (setv self.remaining-label (tkinter.StringVar))
      (.set self.remaining-label (self.format-from-seconds self.remaining))
      (setv self.running false)
      (setv self.update-period 100)

      (setv self.display (apply tkinter.Label [self]
                                {"textvariable" self.remaining-label
                                 "font" ["Helvetica" 22]}))
      (apply self.display.grid [] {"row" 0})
      (.bind self.display "<Double-Button-1>"
             (fn [event]
               (self.edit-initial)))

      (setv self.initial-text (.StringVar tkinter))
      (.set self.initial-text (self.format-from-seconds self.initial))
      (setv self.initial-field
            (apply tkinter.Entry [self]
                   {"textvariable" self.initial-text
                    "font" ["Helvetica" 22]
                    "width" 8}))
      (apply self.initial-field.grid [] {"row" 0})
      (.grid-remove self.initial-field)
      (.bind self.initial-field "<Return>"
             (fn [event]
               (self.save-initial)))

      (setv self.start-button (apply tkinter.Button [self]
                                       {"text" "START"
                                        "command" self.start}))
      (setv self.stop-button (apply tkinter.Button [self]
                                      {"text" "STOP"
                                       "command" self.stop
                                       "state" tkinter.DISABLED}))
      (setv self.reset-button (apply tkinter.Button [self]
                                       {"text" "RESET"
                                        "command" self.reset}))
      (for [index&button (enumerate [self.start-button
                                     self.stop-button
                                     self.reset-button])]
        (apply .grid [(second index&button)]
                     {"row" (+ 1 (first index&button))}))

      (.mainloop self))]

   [start
    (fn [self]
      (setv self.running true)
      (setv self.last-updated (.time time))
      (.update self)
      (apply self.stop-button.configure []
               {"state" tkinter.NORMAL})
      (apply self.start-button.configure []
               {"state" tkinter.DISABLED}))]

   [stop
    (fn [self]
      (setv self.running false)
      (apply self.start-button.configure []
               {"state" tkinter.NORMAL})
      (apply self.stop-button.configure []
               {"state" tkinter.DISABLED}))]

   [reset
    (fn [self]
      (setv self.remaining self.initial)
      (setv self.last-updated (.time time))
      (.set self.remaining-label (self.format-from-seconds self.remaining)))]

    [format-from-seconds
     (with-decorator staticmethod
       (fn [seconds]
         (.format "{}:{:02}:{:04.1f}"
                  (math.floor (/ seconds 3600))
                  (% (math.floor (/ seconds 60)) 60)
                  (% seconds 60))))]

    [unformat-to-seconds
     (with-decorator staticmethod
       (fn [s&m&h]
         (functools.reduce (fn [x y] (+ x y))
                           (map (fn [power&figure]
                                  (* (** 60 (first power&figure))
                                     (second power&figure)))
                                (enumerate s&m&h))
                           0)))]

    [parse
     (fn [self formatted]
       (setv time-regex (.compile re "(\d+):?(\d{2}):(\d{2})"))
       (setv s&m&h (map (fn [x] (if (empty? x) 0 (int x)))
                        (.group (.match time-regex formatted)
                                3 2 1)))
       (self.unformat-to-seconds s&m&h))]

    [update
     (fn [self]
       (setv now (.time time))
       (setv elapsed (- now self.last-updated))
       (setv self.last-updated now)
       (setv self.remaining (- self.remaining elapsed))
       (.set self.remaining-label (self.format-from-seconds
                                   self.remaining))
       (if self.running
         (if (<= self.remaining 0)
           (.chime self)
           (.after self self.update-period self.update))))]

     [chime
      (fn [self]
        (.stop self)
        (.set self.remaining-label "time")
        (.showinfo tkinter.messagebox "!" "And time!"))]

    [edit-initial
     (fn [self]
       (.grid self.initial-field)
       (.focus-set self.initial-field)
       (.grid-remove self.display))]

    [save-initial
     (fn [self]
       (.grid self.display)
       (.grid-remove self.initial-field)
       (try
        (do
         (setv self.initial (self.parse (.get self.initial-text)))
         (self.reset))
        (catch [e Exception]
          (print e))))]])

(if (= --name-- "__main__")
  (HyTimerWindow (* 20 60)))
