(import math)
(import time)
(import re)
(import functools)

(import tkinter)
(import tkinter.messagebox)

(defclass HyTimerWindow [tkinter.Tk]
  [[__init__
    (fn [self initial]
      (.__init__ tkinter.Tk self)
      (self.title "HyTimer")
      (setv self.initial initial)
      (setv self.remaining initial)
      (setv self.remaining_label (tkinter.StringVar))
      (.set self.remaining_label (self.format_from_seconds self.remaining))
      (setv self.running False)
      (setv self.update_period 100) 

      (setv self.display (kwapply (.Label tkinter self)
                                  {"textvariable" self.remaining_label
                                   "font" ["Helvetica" 22]}))
      (kwapply (.grid self.display) {"row" 0})
      (.bind self.display "<Double-Button-1>"
             (fn [event]
               (self.edit_initial)))

      (setv self.initial_text (.StringVar tkinter))
      (.set self.initial_text (self.format_from_seconds self.initial))
      (setv self.initial_field
            (kwapply (.Entry tkinter self)
                     {"textvariable" self.initial_text
                      "font" ["Helvetica" 22]
                      "width" 8}))
      (kwapply (.grid self.initial_field) {"row" 0})
      (.grid_remove self.initial_field)
      (.bind self.initial_field "<Return>"
             (fn [event]
               (self.save_initial)))

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
      (.set self.remaining_label (self.format_from_seconds self.remaining)))]

    [format_from_seconds
     (with-decorator staticmethod
       (fn [seconds]
         (.format "{}:{:02}:{:04.1f}" 
                  (math.floor (/ seconds 3600))
                  (% (math.floor (/ seconds 60)) 60)
                  (% seconds 60))))]

    [unformat_to_seconds
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
       (setv time_regex (.compile re "(\d+):?(\d{2}):(\d{2})"))
       (setv s&m&h (map (fn [x] (if (empty? x) 0 (int x)))
                        (.group (.match time_regex formatted)
                                3 2 1)))
       (self.unformat_to_seconds s&m&h))]

    [update
     (fn [self]
       (setv now (.time time))
       (setv elapsed (- now self.last_updated))
       (setv self.last_updated now)
       (setv self.remaining (- self.remaining elapsed))
       (.set self.remaining_label (self.format_from_seconds
                                   self.remaining))
       (if self.running
         (if (<= self.remaining 0)
           (.chime self)
           (.after self self.update_period self.update))))]

     [chime
      (fn [self]
        (.stop self)
        (.set self.remaining_label "time")
        (.showinfo tkinter.messagebox "!" "And time!"))]

    [edit_initial
     (fn [self]
       (.grid self.initial_field)
       (.focus_set self.initial_field)
       (.grid_remove self.display))]

    [save_initial
     (fn [self]
       (.grid self.display)
       (.grid_remove self.initial_field)
       (try
         (do
           (setv self.initial (self.parse (.get self.initial_text)))
           (self.reset))
         (catch [e Exception]
             (print e)))
       )]

])

(if (= __name__ "__main__")
  (HyTimerWindow (* 20 60)))
