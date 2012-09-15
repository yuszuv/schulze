# encoding: utf-8
module Sinatra
  module RenderPartial
    def partial(page, options = {})
      locals = options.delete(:locals)
      page = ('_' + page.to_s).to_sym
      haml page, options.merge(layout: false), locals
    end

    def icon(name)
      capture_haml do
        haml_tag :i, class: "icon-#{name}"
      end
    end
  end
end
