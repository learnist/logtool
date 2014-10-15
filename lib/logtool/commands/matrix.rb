module Logtool
  module Command
    class Matrix

      def run(args)

        ############################################################################
        # Parse the log files. The contents of the files are presumed to be in the
        # predigested form produced by the summarize-unicorn-logs.rb script.

        $stderr.puts "processing log files..."

        endpoint_totals = Hash.new {|h, k| h[k] = Hash.new(0) }
        client_totals = Hash.new {|h, k| h[k] = Hash.new(0) }
        current_endpoint = nil

        Logtool::Processor.new(args).run do |line|
          case line
            when /Processing by (\S+)/
              current_endpoint = $1

            when /user agent: (.*)/
              user_agent = $1
              client = case user_agent
                when /^Learnist\/(\d+)/      then "iOS #{$1}"
                when /^com.learnist\/(\d+)/  then "Android #{$1}"
                when /^Dalvik/      then 'Android 0'
                when /Googlebot/    then 'Google'
                when /Prerender/    then 'Prerender'
                when /bot|spider/i  then 'Bot'
                when /\+http:\/\//  then 'Bot'
                when /Mobile/       then 'SPA (mobile)'
                when /Opera Mini/   then 'SPA (mobile)'
                when /Mozilla/      then 'SPA'
                else                'Bot'
              end
              client_totals[client][current_endpoint] += 1
              endpoint_totals[current_endpoint][client] += 1
          end
        end


        #########################################################################################
        # Invoke the Rails router to determine what all of our known endpoints are called.

        defined_endpoints = Rails.application.routes.routes.to_a
        defined_endpoints.reject!{|route| route.defaults[:controller].nil? }
        defined_endpoints.reject!{|route| route.defaults[:action].nil? }
        defined_endpoints.reject!{|route| route.defaults[:action] =~ /^:/ }
        defined_endpoints.map! {|route|
          controller_class = "#{route.defaults[:controller]}_controller".camelize.constantize
          action = route.defaults[:action]
          "#{controller_class}##{action}"
        }
        defined_endpoints.sort!


        #########################################################################################
        # Report on whether the endpoints that appear in the logs match those defined in
        # the application.

        discovered_endpoints = endpoint_totals.keys.sort
        missing_endpoints = (discovered_endpoints - defined_endpoints).sort
        unused_endpoints = (defined_endpoints - discovered_endpoints).sort

        if missing_endpoints.any?
          $stderr.puts "warning, the following endpoints appear in the logs but do not exist in the code:"
          missing_endpoints.each do |endpoint|
            $stderr.puts " - #{endpoint}"
          end
          $stderr.puts
        end

        if unused_endpoints.any?
          $stderr.puts "good news, the following endpoints are not mentioned in the logs; it may be possible to remove them from the code:"
          unused_endpoints.each do |endpoint|
            $stderr.puts " - #{endpoint}"
          end
          $stderr.puts
        end


        #########################################################################################
        # Produce a CSV report, suitable for importing into your favorite spreadsheet program.
        # Or whatever, really.

        client_names = client_totals.keys

        puts [ 'Endpoint', *client_names.sort, 'Total' ].join(',')

        (defined_endpoints + discovered_endpoints).sort.uniq.each do |endpoint|
          cumulative_total = 0
          print endpoint
          client_names.each do |client|
            total = endpoint_totals[endpoint][client]
            cumulative_total += total
            total = nil if total == 0
            print ",%s" % total
          end
          puts ",#{cumulative_total}"
        end
      end

    end
  end
end
