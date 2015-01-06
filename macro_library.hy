(defmacro @ [decorator &rest code]
  `(with-decorator ~decorator
     ~@code))
