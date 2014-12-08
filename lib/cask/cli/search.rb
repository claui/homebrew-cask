class Cask::CLI::Search < Cask::CLI::Base; end

require 'cask/search'
require 'cask/search/results_renderer'

class Cask::CLI::Search
  def self.run(*args)
    search_terms = remove_options(args)
    options = {}
    options[:token] = true if args.include?('--token')

    results = Cask::Search.results(search_terms, options)
    Cask::Search::ResultsRenderer.render!(results)
  end

  def self.help
    "searches all known Casks"
  end
end
