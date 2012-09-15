# encoding: utf-8
module Sinatra
  module FormHelpers
    def checked?(icon,name)
      if name == icon
        "checked"
      else
        false
      end
    end
  end
end

