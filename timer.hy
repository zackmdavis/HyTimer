(import datetime)
(import math)
(import time)
(import re)
(import functools)
(import subprocess)

(import tkinter)
(import tkinter.messagebox)


(defclass HyTimerWindow [tkinter.Tk]
    (defn --init-- [self initial]
      (.--init-- tkinter.Tk self)
      (self.title "HyTimer")
      (setv self.initial initial)
      (setv self.remaining initial)
      (setv self.remaining-label (tkinter.StringVar))
      (.set self.remaining-label (self.format-from-seconds self.remaining))
      (setv self.running False)
      (setv self.update-period 100)

      (setv self.display (tkinter.Label #*[self]
                                #**{"textvariable" self.remaining-label
                                    "font" ["Helvetica" 22]}))
      (self.display.grid #*[] #**{"row" 0})
      (.bind self.display "<Double-Button-1>"
             (fn [event]
               (self.edit-initial)))

      (setv self.initial-text (.StringVar tkinter))
      (.set self.initial-text (self.format-from-seconds self.initial))
      (setv self.initial-field
            (tkinter.Entry #*[self]
                   #**{"textvariable" self.initial-text
                       "font" ["Helvetica" 22]
                       "width" 8}))
      (self.initial-field.grid #*[] #**{"row" 0})
      (.grid-remove self.initial-field)
      (.bind self.initial-field "<Return>"
             (fn [event]
               (self.save-initial)))

      (setv self.start-button (tkinter.Button #*[self]
                                       #**{"text" "START"
                                           "command" self.start}))
      (setv self.stop-button (tkinter.Button #*[self]
                                      #**{"text" "STOP"
                                          "command" self.stop
                                          "state" tkinter.DISABLED}))
      (setv self.reset-button (tkinter.Button #*[self]
                                       #**{"text" "RESET"
                                           "command" self.reset}))
      (for [index&button (enumerate [self.start-button
                                     self.stop-button
                                     self.reset-button])]
        (setv kwargs {"row" (+ 1 (first index&button))})
        (.grid (second index&button) #** kwargs))

      (.mainloop self))

    (defn start [self]
      (setv self.running True)
      (setv self.last-updated (.time time))
      (.update self)
      (self.stop-button.configure
               #**{"state" tkinter.NORMAL})
      (self.start-button.configure
               #**{"state" tkinter.DISABLED}))

    (defn stop [self]
      (setv self.running False)
      (self.start-button.configure
               #**{"state" tkinter.NORMAL})
      (self.stop-button.configure
               #**{"state" tkinter.DISABLED}))

    (defn reset [self]
      (setv self.remaining self.initial)
      (setv self.last-updated (.time time))
      (.set self.remaining-label (self.format-from-seconds self.remaining)))

    (defn format-from-seconds [self seconds]
      (.format "{}:{:02}:{:04.1f}"
               (math.floor (/ seconds 3600))
               (% (math.floor (/ seconds 60)) 60)
               (% seconds 60)))

     (defn unformat-to-seconds [self s&m&h]
         (functools.reduce (fn [x y] (+ x y))
                           (map (fn [power&figure]
                                  (* (** 60 (first power&figure))
                                     (second power&figure)))
                                (enumerate s&m&h))
                           0))

     (defn parse [self formatted]
       (setv time-regex (.compile re "(\d+):?(\d{2}):(\d{2})"))
       (setv s&m&h (map (fn [x] (if (empty? x) 0 (int x)))
                        (.group (.match time-regex formatted)
                                3 2 1)))
       (self.unformat-to-seconds s&m&h))

     (defn update [self]
       (setv now (.time time))
       (setv elapsed (- now self.last-updated))
       (setv self.last-updated now)
       (setv self.remaining (- self.remaining elapsed))
       (.set self.remaining-label (self.format-from-seconds
                                   self.remaining))
       (if self.running
         (if (<= self.remaining 0)
           (.chime self)
           (.after self self.update-period self.update))))

     (defn chime [self]
        (.stop self)
       (.set self.remaining-label "time")
       (subprocess.run ["xrefresh" "-solid" "black"])
       (subprocess.run ["notify-send" "And time!"])
       (setv speaker (subprocess.Popen ["espeak" "'and time'"]))
       (.showinfo tkinter.messagebox "!" (.format "And time!\n\n{}"
                                                  (.strftime (.now datetime.datetime) "%H%M")))
       (.terminate speaker))

     (defn edit-initial [self]
       (.grid self.initial-field)
       (.focus-set self.initial-field)
       (.grid-remove self.display))

     (defn save-initial [self]
       (.grid self.display)
       (.grid-remove self.initial-field)
       (try
        (do
         (setv self.initial (self.parse (.get self.initial-text)))
         (self.reset))
        (except [e Exception]
          (print e)))))


(if (= --name-- "__main__")
  (HyTimerWindow (* 20 60)))
