class Autoloader
  @autoload_paths = %w[sys controllers lib config]

  class << self
    def load
      autoload_paths.each do |path|
        Dir.glob(rbfiles(path)).each { |file| require_relative file }
      end
    end

    private

    attr_reader :autoload_paths

    def rbfiles(path)
      File.join('**', path, '*.rb')
    end
  end
end
Autoloader.load
