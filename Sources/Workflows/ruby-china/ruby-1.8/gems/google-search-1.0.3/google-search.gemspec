# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{google-search}
  s.version = "1.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["TJ Holowaychuk"]
  s.date = %q{2012-08-29}
  s.description = %q{Google Search API}
  s.email = %q{tj@vision-media.ca}
  s.extra_rdoc_files = ["lib/google-search/item/base.rb", "lib/google-search/item/blog.rb", "lib/google-search/item/book.rb", "lib/google-search/item/image.rb", "lib/google-search/item/local.rb", "lib/google-search/item/news.rb", "lib/google-search/item/patent.rb", "lib/google-search/item/video.rb", "lib/google-search/item/web.rb", "lib/google-search/item.rb", "lib/google-search/response.rb", "lib/google-search/search/base.rb", "lib/google-search/search/blog.rb", "lib/google-search/search/book.rb", "lib/google-search/search/image.rb", "lib/google-search/search/local.rb", "lib/google-search/search/mixins/filter.rb", "lib/google-search/search/mixins/order_by.rb", "lib/google-search/search/mixins/safety_level.rb", "lib/google-search/search/mixins.rb", "lib/google-search/search/news.rb", "lib/google-search/search/patent.rb", "lib/google-search/search/video.rb", "lib/google-search/search/web.rb", "lib/google-search/search.rb", "lib/google-search/version.rb", "lib/google-search.rb", "README.rdoc", "tasks/docs.rake", "tasks/gemspec.rake", "tasks/spec.rake"]
  s.files = ["examples/image.rb", "examples/images.html", "examples/web.rb", "google-search.gemspec", "History.rdoc", "lib/google-search/item/base.rb", "lib/google-search/item/blog.rb", "lib/google-search/item/book.rb", "lib/google-search/item/image.rb", "lib/google-search/item/local.rb", "lib/google-search/item/news.rb", "lib/google-search/item/patent.rb", "lib/google-search/item/video.rb", "lib/google-search/item/web.rb", "lib/google-search/item.rb", "lib/google-search/response.rb", "lib/google-search/search/base.rb", "lib/google-search/search/blog.rb", "lib/google-search/search/book.rb", "lib/google-search/search/image.rb", "lib/google-search/search/local.rb", "lib/google-search/search/mixins/filter.rb", "lib/google-search/search/mixins/order_by.rb", "lib/google-search/search/mixins/safety_level.rb", "lib/google-search/search/mixins.rb", "lib/google-search/search/news.rb", "lib/google-search/search/patent.rb", "lib/google-search/search/video.rb", "lib/google-search/search/web.rb", "lib/google-search/search.rb", "lib/google-search/version.rb", "lib/google-search.rb", "Manifest", "Rakefile", "README.rdoc", "spec/fixtures/400-response.json", "spec/fixtures/blog-response.json", "spec/fixtures/book-response.json", "spec/fixtures/image-response.json", "spec/fixtures/invalid-response.json", "spec/fixtures/local-response.json", "spec/fixtures/news-response.json", "spec/fixtures/patent-response.json", "spec/fixtures/video-response.json", "spec/fixtures/web-2-response.json", "spec/fixtures/web-response.json", "spec/item_blog_spec.rb", "spec/item_book_spec.rb", "spec/item_image_spec.rb", "spec/item_local_spec.rb", "spec/item_news_spec.rb", "spec/item_patent_spec.rb", "spec/item_spec.rb", "spec/item_video_spec.rb", "spec/item_web_spec.rb", "spec/response_spec.rb", "spec/search_blog_spec.rb", "spec/search_book_spec.rb", "spec/search_image_spec.rb", "spec/search_local_spec.rb", "spec/search_news_spec.rb", "spec/search_patent_spec.rb", "spec/search_spec.rb", "spec/search_video_spec.rb", "spec/search_web_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "tasks/docs.rake", "tasks/gemspec.rake", "tasks/spec.rake"]
  s.homepage = %q{http://github.com/visionmedia/google-search}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Google-search", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{google-search}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Google Search API}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<json>, [">= 0"])
    else
      s.add_dependency(%q<json>, [">= 0"])
    end
  else
    s.add_dependency(%q<json>, [">= 0"])
  end
end
