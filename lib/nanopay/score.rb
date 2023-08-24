require 'openssl'
require 'score_suffix/score_suffix'
require 'time'

module NanoPay
  class Score
    class CantParse < StandardError; end

    STRENGTH = 8

    BEST_BEFORE = 24

    attr_reader :time, :host, :port, :invoice, :suffixes, :strength, :created

    def initialize(host:, invoice:, time: Time.now, port: 4096, suffixes: [], strength: Score::STRENGTH, created: Time.now)
      raise 'Time can\'t be nil' if time.nil?
      raise "Time must be Time, while #{time.class.name} is provided" unless time.is_a?(Time)

      @time = time
      raise 'Host can\'t be nil' if host.nil?
      raise "Host \"#{host}\" is in a wrong format" unless /^[0-9a-z.-]+$/.match?(host)

      @host = host
      raise 'Port can\'t be nil' if port.nil?
      raise "Port must be Integer, while #{port.class.name} is provided" unless port.is_a?(Integer)
      raise "Port must be less than 65535, while #{port} is provided" if port > 65_535
      raise "Port must be positive integer, while #{port} is provided" unless port.positive?

      @port = port
      raise 'Invoice can\'t be nil' if invoice.nil?
      raise "Invoice \"#{invoice}\" is wrong" unless /^[a-zA-Z0-9]{8,32}@[a-f0-9]{16}$/.match?(invoice)

      @invoice = invoice
      raise 'Suffixes can\'t be nil' if suffixes.nil?
      raise 'Suffixes are not an array' unless suffixes.is_a?(Array)

      @suffixes = suffixes
      raise 'Strength can\'t be nil' if strength.nil?
      raise "Strength must be positive integer, while #{strength} is provided" unless strength.positive?

      @strength = strength
      raise 'Created can\'t be nil' if created.nil?
      raise "Created must be Time, while #{created.class.name} is provided" unless created.is_a?(Time)

      @created = created
    end

    ZERO = Score.new(
      time: Time.now, 
      host: 'localhost',
      invoice: 'NOPREFIX@ffffffffffffffff'
    )

    def self.parse_json(json)
      raise CantParse, 'JSON can\'t be nil' if json.nil?

      Score.new(
        time: Time.parse(json['time']),
        host: json['host'],
        port: json['port'],
        invoice: json['invoice'],
        suffixes: json['suffixes'],
        strength: json['strength']
      )
    rescue StandardError => e
      raise CantParse, "#{e.message} in #{json.inspect}"
    end

    def ==(other)
      raise 'Can\'t compare with nil' if other.nil?

      to_s == other.to_s
    end

    def <(other)
      raise 'Can\'t compare with nil' if other.nil?

      value < other.value
    end

    def >(other)
      raise 'Can\'t compare with nil' if other.nil?

      value > other.value
    end

    def <=>(other)
      raise 'Can\'t compare with nil' if other.nil?

      value <=> other.value
    end

    def to_s
      pfx, bnf = @invoice.split('@')
      [
        @strength,
        @time.to_i.to_s(16),
        @host,
        @port.to_s(16),
        pfx,
        bnf,
        @suffixes.join(' ')
      ].join(' ')
    end

    def self.parse(text)
      raise 'Can\'t parse nil' if text.nil?

      begin
        parts = text.split(' ', 7)
        raise 'Invalid score, not enough parts' if parts.length < 6

        Score.new(
          time: Time.at(parts[1].hex),
          host: parts[2],
          port: parts[3].hex,
          invoice: "#{parts[4]}@#{parts[5]}",
          suffixes: parts[6] ? parts[6].split : [],
          strength: parts[0].to_i
        )
      rescue StandardError => e
        raise CantParse, "#{e.message} in #{text.inspect}"
      end
    end

    def hash
      raise 'Score has zero value, there is no hash' if @suffixes.empty?

      @suffixes.reduce(prefix) do |pfx, suffix|
        OpenSSL::Digest.new('SHA256', "#{pfx} #{suffix}").hexdigest
      end
    end

    def to_mnemo
      "#{value}:#{@time.strftime('%H%M')}"
    end

    def to_h
      {
        value: value,
        host: @host,
        port: @port,
        invoice: @invoice,
        time: @time.utc.iso8601,
        suffixes: @suffixes,
        strength: @strength,
        hash: value.zero? ? nil : hash,
        expired: expired?,
        valid: valid?,
        age: (age / 60).round,
        created: @created.utc.iso8601
      }
    end

    def reduced(max = 4)
      raise 'Max can\'t be nil' if max.nil?
      raise "Max can't be negative: #{max}" if max.negative?

      Score.new(
        time: @time, host: @host, port: @port, invoice: @invoice,
        suffixes: @suffixes[0..[max, suffixes.count].min - 1],
        strength: @strength
      )
    end

    def next
      raise 'This score is not valid' unless valid?

      if expired?
        return Score.new(
          time: Time.now, host: @host, port: @port, invoice: @invoice,
          suffixes: [], strength: @strength
        )
      end
      suffix = ScoreSuffix.new(suffixes.empty? ? prefix : hash, @strength)
      Score.new(
        time: @time, host: @host, port: @port, invoice: @invoice,
        suffixes: @suffixes + [suffix.value], strength: @strength
      )
    end

    def age
      Time.now - @time
    end

    def expired?(hours = BEST_BEFORE)
      raise 'Hours can\'t be nil' if hours.nil?

      age > hours * 60 * 60
    end

    def prefix
      "#{@time.utc.iso8601} #{@host} #{@port} #{@invoice}"
    end

    def valid?
      (@suffixes.empty? || hash.end_with?('0' * @strength)) && @time < Time.now
    end

    def value
      @suffixes.length
    end

    def zero?
      @suffixes.empty?
    end
  end
end
