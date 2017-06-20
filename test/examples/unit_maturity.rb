  module Examples
    Log_paths = Dir['log/unit/2.2/2.2.3p173/silence/*.log']
    Log_read_returns = Log_paths.map {|path| RubyLinesStorage.read(path) }
  end # Examples
  include Examples

