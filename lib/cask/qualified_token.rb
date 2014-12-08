module Cask::QualifiedToken
  def self.repo_prefix
    'homebrew-'
  end

  def self.user_regexp
    # per https://github.com/Homebrew/homebrew/blob/4c7bc9ec3bca729c898ee347b6135ba692ee0274/Library/Homebrew/cmd/tap.rb#L121
    %r{[a-z_\-]+}
  end

  def self.repo_regexp
    # per https://github.com/Homebrew/homebrew/blob/4c7bc9ec3bca729c898ee347b6135ba692ee0274/Library/Homebrew/cmd/tap.rb#L121
    %r{(?:#{repo_prefix})?\w+}
  end

  def self.token_regexp
    # per https://github.com/caskroom/homebrew-cask/blob/master/CONTRIBUTING.md#generating-a-token-for-the-cask
    %r{[a-z0-9\-]+}
  end

  def self.tap_regexp
    %r{#{user_regexp}[/\-]#{repo_regexp}}
  end

  def self.qualified_token_regexp
    @qualified_token_regexp ||= %r{#{tap_regexp}/#{token_regexp}}
  end

  def self.qualified?(token)
    return nil unless token.kind_of?(String)
    token.downcase.match(%r{^#{qualified_token_regexp}$})
  end

  def self.short_token_from(qualified_token)
    qualified_token.gsub(/^.*\//, '')
  end

  def self.medium_token_from(qualified_token)
    parse(qualified_token, { :strict => false }).compact.join('/')
  end

  def self.generate_unique_tokens!(items, token_accessor,
    &result_acceptor)
    UniqueTokenGenerator.generate!(items, token_accessor,
      result_acceptor)
  end

  def self.simplified_search_term(term)
    term.sub(/\.rb$/i, '').gsub(/[^a-z0-9]+/i, '') if term
  end

  def self.parse(token, options = {})
    defaults = { :strict => true }
    options = defaults.merge(options)

    if qualified?(token)
      parse_strict(token)
    else
      options[:strict] ? nil : [token]
    end
  end

  def self.parse_strict(qualified_token)
    path_elements = qualified_token.downcase.split('/')
    if path_elements.count == 2
      # eg phinze-cask/google-chrome.
      # Not certain this form is needed, but it was supported in the past.
      token = path_elements[1]
      dash_elements = path_elements[0].split('-')
      repo = dash_elements.pop
      dash_elements.pop if dash_elements.count > 1 and dash_elements[-1] + '-' == repo_prefix
      user = dash_elements.join('-')
    else
      # eg caskroom/cask/google-chrome
      # per https://github.com/Homebrew/homebrew/wiki/brew-tap
      user, repo, token = path_elements
    end
    repo.sub!(%r{^#{repo_prefix}}, '')
    odebug "[user, repo, token] might be [#{user}, #{repo}, #{token}]"
    [user, repo, token]
  end

  class UniqueTokenGenerator
    attr_reader :items, :token_accessor, :result_acceptor

    def self.generate!(*args)
      self.new(*args).generate!
    end

    def initialize(items, token_accessor, result_acceptor)
      raise MissingCallbackError.new unless result_acceptor

      @items = items
      @token_accessor = token_accessor || lambda { |token| token }
      @result_acceptor = result_acceptor
    end

    def generate!
      groups = group_by_short_token(items)
      deliver_unique_tokens!(groups)
    end

    private

    def group_by_short_token(items)
      items.group_by do |item|
        qualified_token = token_accessor.call(item)
        Cask::QualifiedToken.short_token_from(qualified_token)
      end
    end

    def deliver_unique_tokens!(groups)
      groups.each do |short_token, matching_items|
        if matching_items.length == 1
          deliver_short_token!(matching_items, short_token)
        else
          deliver_medium_tokens!(matching_items)
        end
      end
    end

    def deliver_short_token!(matching_items, short_token)
      result_acceptor.call(matching_items[0], short_token)
    end

    def deliver_medium_tokens!(matching_items)
      matching_items.each do |item|
        qualified_token = token_accessor.call(item)
        medium_token = Cask::QualifiedToken.medium_token_from(qualified_token)
        result_acceptor.call(item, medium_token)
      end
    end
  end

  class MissingCallbackError < CaskError
    def to_s
      [
        'This initializer requires a callback proc that accepts ',
        'as arguments both the original item and the generated ',
        'unique token.'
      ].join
    end
  end
end
