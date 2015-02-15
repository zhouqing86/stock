module Stock
  module Logger
    def self.new(dest, verbose = false)
      ::Logger.new(dest).tap do |logger|
        logger.level = verbose ? ::Logger::DEBUG : ::Logger::INFO
      end
    end
  end
end