module Schulze
  module RenderPartial
    def partial(page, options = {})
      page = ('_' + page.to_s).to_sym
      haml page, options.merge(layout: false)
    end
  end

  helpers RenderPartial
end
