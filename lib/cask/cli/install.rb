class Cask::CLI::Install < Cask::CLI::Base
  def self.run(*args)
    cask_tokens = cask_tokens_from(args)
    raise CaskUnspecifiedError if cask_tokens.empty?
    force = args.include? '--force'
    retval = install_casks cask_tokens, force
    # retval is ternary: true/false/nil
    if retval.nil?
      raise CaskError.new("nothing to install")
    elsif ! retval
      raise CaskError.new("install incomplete")
    end
  end

  def self.install_casks(cask_tokens, force)
    count = 0
    cask_tokens.each do |cask_token|
      begin
        cask = Cask.load(cask_token)
        Cask::Installer.new(cask).install(force)
        count += 1
       rescue CaskAlreadyInstalledError => e
         opoo e.message
         count += 1
      rescue CaskUnavailableError => e
        warn_unavailable_with_suggestions cask_token, e
      end
    end
    count == 0 ? nil : count == cask_tokens.length
  end

  def self.warn_unavailable_with_suggestions(cask_token, e)
    results = Cask::Search.results([cask_token])
    results.format_conflicting_tokens!

    errmsg = e.message
    if results.length == 1
      errmsg.concat(". Did you mean: #{ suggestions(results) }")
    elsif results.length > 1
      errmsg.concat(". Did you mean one of:\n#{ suggestions(results) }\n")
    end
    onoe errmsg
  end

  def self.suggestions(results)
    formatted_matches = []

    if results.exact?
      formatted_matches << format_suggestion(results.exact_match)
    end

    if results.partial?
      partial_matches = results.partial_matches.take(20).map do |match|
        format_suggestion(match)
      end
      formatted_matches.concat(partial_matches)
    end

    formatted_matches.join("\n")
  end

  def self.format_suggestion(match)
    suggestion = ["#{ Tty.green }#{ match.formatted_token }#{ Tty.reset }"]
    unless [match.token, match.qualified_token].include?(match.value)
      suggestion << "(#{ match.value })"
    end
    suggestion.join(' ')
  end

  def self.help
    "installs the given Cask"
  end
end
