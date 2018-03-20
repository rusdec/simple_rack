class MyTime
  TIME_PATTERNS = { second: '%S',
                    minute: '%M',
                    hour:   '%H',
                    day:    '%d',
                    month:  '%m',
                    year:   '%Y' }.freeze

  DEFAULT_FORMAT = 'day-month-year hour:minute:second'.freeze

  def time(format)
    format ||= DEFAULT_FORMAT
    unformat = unformat_time_patterns(format)
    raise "Bad time format" unless time_patterns_found?(format)
    raise "Unknown time format [#{unformat.join(',')}]" unless unformat.empty?
    format_time(format)
  end

  private

  def format_time(format)
    format = CGI.unescape(format)
    TIME_PATTERNS.each { |time, pattern| format.gsub!(time.to_s, pattern) }
    Time.now.strftime(format)
  end

  def unformat_time_patterns(format)
    separator = /\W/
    format.split(separator).reject do |substr|
      substr =~ separator || substr.empty?
    end - time_patterns_keys
  end

  def time_patterns_found?(format)
    pattern = /(#{time_patterns_keys.join('|')})/
    pattern.match?(format)
  end

  def time_patterns_keys
    TIME_PATTERNS.keys.map(&:to_s)
  end
end
