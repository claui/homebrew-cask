class Cask::Search; end

require 'cask/search/delegate'
require 'cask/search/match'
require 'cask/search/literal_search'
require 'cask/search/regexp_search'
require 'cask/search/results'

class Cask::Search::ByToken
  def self.value_from(cask)
    cask.token
  end
end

class Cask::Search::ByName
  def self.value_from(cask)
    # todo
    # cask.full_name.first if cask.full_name
  end
end

class Cask::Search
  attr_reader :delegate, :search_terms, :options

  CONFIG = {
    :token => [:all_as_proxies, ByToken],
    :name  => [:all_named_casks, ByName]
  }

  def self.results(search_terms, options = {})
    search_regexp = Delegate.extract_regexp(search_terms.first)
    delegate = search_regexp ? RegexpSearch : LiteralSearch
    self.new(delegate, search_terms, options).results
  end

  def initialize(delegate, search_terms, options)
    @delegate = delegate
    @search_terms = search_terms
    @options = Hash.new(!options.value?(true))
    @options.merge!(options)
  end

  def results
    scope.map(&method(:sub_results)).reduce(:merge)
  end

  def sub_results(args)
    source, context = args
    search = delegate.new(search_terms, Cask.send(source), context)

    search.exclude_fonts! if delegate.exclude_fonts?
    search.find_exact_match!
    search.find_partial_matches!
    search.results
  end

  def scope
    selected_scope = CONFIG.select { |option, _| options[option] }
    if selected_scope.respond_to?(:values)
      selected_scope.values
    else
      # For Ruby 1.8.7 compatibility
      selected_scope.map { |k, v| [v] }
    end
  end
end
