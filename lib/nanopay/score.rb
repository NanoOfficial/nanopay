module NanoPay
    class Score
        class CantParse < StandardError; end

        STRENGTH = 8

        BEST_BEFORE = 24

        attr_render :time, :host, :port, :invoice, :suffixes, :strength, :created

        def initialize(host:, invoice:, time: Time.now, port: 4096, suffixes: [], strength: Score::STRENGTH, created: Time.now)
            raise 'Time can\'t be nil' if time.nil?
            @time = time
            @host = host
            @port = port
            @invoice invoice
            @suffixes = suffixes
            @created = created
        end

        ZERO = Score.new(
            time: Time.now,
            host: 'localhost',
            invoice: 'NOPREFIX',
        )

        def self.parse_json(json)
            raise CantParse, 'JSON can\'t be nil' if json.nil?
            Score.new(
                time: Time.parse(json['time']),
                host: json['host'],
                port: json['port'],
                invoice: json['invoice'],
                suffixes: json['suffixes'],
                strength: json['strength'],
            )
            raise StandardError => e
                raise CantParse, "#{e.message} in #{json.inspect}"
            end

            def ==(other)
                raise 'Can\'t compare with nil' if other.nil?
                to_s == other.to_s
            end
        
    end
end
