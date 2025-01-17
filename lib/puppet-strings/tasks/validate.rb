# frozen_string_literal: true

require 'puppet-strings'
require 'tempfile'

namespace :strings do
  namespace :validate do
    desc 'Validate the reference is up to date'
    task :reference, [:patterns, :debug, :backtrace] do |t, args|
      filename = 'REFERENCE.md'

      unless File.exist?(filename)
        STDERR.puts "#{filename} does not exist"
        exit 1
      end

      patterns = args[:patterns]
      patterns = patterns.split if patterns
      patterns ||= PuppetStrings::DEFAULT_SEARCH_PATTERNS

      generated = Tempfile.create do |file|
        options = {
          debug: args[:debug] == 'true',
          backtrace: args[:backtrace] == 'true',
          json: false,
          markdown: true,
          path: file,
        }
        PuppetStrings.generate(patterns, options)

        file.read
      end

      existing = File.read(filename)

      if generated != existing
        STDERR.puts "#{filename} is outdated"
        exit 1
      end
    end
  end
end
