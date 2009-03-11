module QueryReviewer
  # a collection of SQL SELECT queries  
  class SqlQueryCollection
    COMMANDS = %w(SELECT DELETE INSERT UPDATE)

    attr_reader :queries
    def initialize(queries)
      @queries = queries
    end
    
    def analyze!
      self.queries.collect(&:analyze!)

      @warnings = []

      crit_severity = 9# ((QueryReviewer::CONFIGURATION["critical_severity"] + 10)/2).to_i
      warn_severity = QueryReviewer::CONFIGURATION["critical_severity"] - 1 # ((QueryReviewer::CONFIGURATION["warn_severity"] + QueryReviewer::CONFIGURATION["critical_severity"])/2).to_i

      COMMANDS.each do |command|
        count = count_of_command(command)
        if count > QueryReviewer::CONFIGURATION["critical_#{command.downcase}_count"]
          warn(:severity => crit_severity, :problem => "#{count} #{command} queries on this page", :description => "Too many #{command} queries can severely slow down a page")
        elsif count > QueryReviewer::CONFIGURATION["warn_#{command.downcase}_count"]
          warn(:severity => warn_severity, :problem => "#{count} #{command} queries on this page", :description => "Too many #{command} queries can slow down a page")
        end
      end
    end
    
    def warn(options)
      @warnings << QueryWarning.new(options)
    end
    
    def warnings
      self.queries.collect(&:warnings).flatten.sort{|a,b| b.severity <=> a.severity}
    end

    def without_warnings
      self.queries.reject{|q| q.has_warnings?}.sort{|a,b| b.duration <=> a.duration}
    end
    
    def collection_warnings
      @warnings
    end
    
    def max_severity
      warnings.empty? && collection_warnings.empty? ? 0 : [warnings.empty? ? 0 : warnings.collect(&:severity).flatten.max, collection_warnings.empty? ? 0 : collection_warnings.collect(&:severity).flatten.max].max
    end

    def only_of_command(command, only_no_warnings = false)
      qs = only_no_warnings ? self.without_warnings : self.queries
      qs.select{|q| q.command == command}
    end

    def count_of_command(command, only_no_warnings = false)
      only_of_command(command, only_no_warnings).size
    end
    
    def total_severity
      warnings.collect(&:severity).sum
    end
    
    def total_with_warnings
      queries.select(&:has_warnings?).length
    end

    def total_without_warnings
      queries.length - total_with_warnings
    end
    
    def percent_with_warnings
      queries.empty? ? 0 : (100.0 * total_with_warnings / queries.length).to_i
    end

    def percent_without_warnings
      queries.empty? ? 0 : (100.0 * total_without_warnings / queries.length).to_i
    end
  end
end