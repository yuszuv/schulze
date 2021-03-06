module Sinatra
  module LinkHelpers
    def link_to(name,url=nil,options={},&block)
      if block_given?
        options = url
        url = name
        name = capture_haml(&block)
      end
      options.merge!(href: url)
      capture_haml do
        haml_tag :a, name, options
      end
    end

    def link_to_article(article)
      if article.url.present?
        article.url = "http://" + article.url unless article.url =~ /^\w+:\/\//
        link_to article.newspaper, article.url
      else
        article.newspaper
      end
    end

    def link_to_unless_current(name,url,options={})
      if request.path == url
        name
      else
        link_to name, url, options
      end
    end

    def link_in_li(name, url, options={})
      capture_haml do
        haml_tag :li, class: request.path == url && "active"  do
          haml_concat link_to(name,url,options)
        end
      end
    end
  end
end
