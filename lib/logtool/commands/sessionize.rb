module Logtool
  module Command
    class Sessionize

      def run(args)

        if i = args.index('-o')
          args.delete_at(i)
          output_dir = args.delete_at(i)
        else
          $stderr.puts "usage: #{$0} -o <output-directory> <logfile(s)>"
          exit 1
        end

        if File.exist?(output_dir)
          $stderr.puts "output directory already exists, refusing to clobber it"
          exit 1
        end

        FileUtils.mkdir_p(output_dir)

        ip_addrs_by_session_id = {}
        file_basenames_by_ip_addr = {}
        session_id = 0

        sources = args.map{|arg| Logtool::Source.new(arg) }
        Logtool::RailsCollator.new(sources).run do |buffer|
          ip_addr = nil
          buffer.lines.first(6).each do |line|
            case line
              when /INFO <root> - Started .* for (\d+\.\d+\.\d+\.\d+)/
                ip_addr = $1
              when /rails session id: (.+)/
                session = $1
                if ip_addr
                  unless ip_addrs_by_session_id[session]
                    ip_addrs_by_session_id[session] ||= ip_addr
                  end
                else
                  ip_addr = ip_addrs_by_session_id[session]
                end
            end
          end

          unless file_basename = file_basenames_by_ip_addr[ip_addr]
            file_basename = file_basenames_by_ip_addr[ip_addr] =
              "#{output_dir}/session-%05d" % session_id
            puts "sessionize: discovered session #{session_id}"
            session_id += 1
          end

          File.open("#{file_basename}.raw.log", 'a') do |f|
            f.puts buffer.lines
            f.puts
          end

          summary_lines = buffer.lines.grep(/<root> - Started|<actioncontroller> - (Processing|Parameters|current user|rails session|user agent|Redirected to|Completed)|<omniauth>|FATAL/)

          File.open("#{file_basename}.summary.log", 'a') do |f|
            f.puts summary_lines
            f.puts
          end

          summary_lines.each do |line|
            line.sub!(/^\[\S+\] \[\d+\] /, '')
            line.sub!(/ for \d+\.\d+\.\d+\.\d+ at .*/, '')
            line.gsub!(/"(([^p]|p[^r])[^"]+)"=>"[^"]*"/, '"\1"=>"..."')
            line.sub!(/user agent: (Mozilla|Learnist).*/, 'user agent: \1')
            line.sub!(/(Completed .*) in [0-9.]+ms.*/, '\1')
            line.gsub!(/(oauth_token|oauth_verifier)=[a-zA-Z0-9]+/, '\1=...')
            line.sub!(/login_response=[a-f0-9]+/, 'login_response=...')
            line.sub!(/(rails session id:) [a-z0-9]+/, '\1 ...')

            line.sub!(/current user: [0-9].*\(Guest, \)/, 'current user: guest')
            line.sub!(/current user: [0-9].*/, 'current user: member')

            line.sub!('?mobile=true&', '?')
            line.sub!('?mobile=true', '')
            line.sub!('"mobile"=>"...", ', '')
          end

          File.open("#{file_basename}.normal.log", 'a') do |f|
            f.puts summary_lines
            f.puts
          end
        end
      end

    end
  end
end
