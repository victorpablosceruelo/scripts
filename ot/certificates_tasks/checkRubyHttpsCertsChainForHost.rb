#!ruby

require 'uri'
require 'net/http'

begin
  require 'openssl'
rescue LoadError
  abort "Oh no! Your Ruby doesn't have OpenSSL, so it can't connect to the requested host. " \
    "You'll need to recompile or reinstall Ruby with OpenSSL support and try again."
end

begin
  # Some versions of Ruby need this require to do HTTPS
  require 'net/https'
rescue LoadError
  puts "Impossible to load net/https. Results might be wrong. "
end

if ARGV.include?("-h") || ARGV.include?("--help") || ARGV.empty?
  puts " "
  puts "USAGE: ruby checkRubyHttpsCertsChainForHost.rb [HOSTNAME] [TLS_VERSION] [VERIFY]"
#  puts "  default: check.rb rubygems.org auto VERIFY_PEER"
  puts "  default: checkRubyHttpsCertsChainForHost.rb NONE TLSv1_2 VERIFY_PEER "
  puts "  examples: "
  puts "         ruby checkRubyHttpsCertsChainForHost.rb github.com TLSv1_2 VERIFY_NONE"
  puts "         ruby checkRubyHttpsCertsChainForHost.rb gitlab-ic.scae.redsara.es "
  puts " "
  exit 0
end

host = ARGV.shift 
uri = URI("https://#{host}")
ssl_version = ARGV.shift || 'TLSv1_2'
verify_mode = ARGV.any? ? OpenSSL::SSL.const_get(ARGV.shift) : OpenSSL::SSL::VERIFY_PEER

# puts "uri host:port: #{uri.host}:#{uri.port}"
# puts 

puts " "
puts "Try 1: "
puts " "
begin
  # Try to connect using HTTPS
  Net::HTTP.new(uri.host, uri.port).tap do |http|
    http.use_ssl = true
    http.ssl_version = ssl_version.to_sym if ssl_version
    http.verify_mode = verify_mode

    if http.use_ssl?
	    use_ssl_aux='true'
    else
	    use_ssl_aux='false'
    end

    puts "uri host:port  #{uri.host}:#{uri.port} " 
    puts "use_ssl        #{use_ssl_aux} "
    puts "ssl_version    #{http.ssl_version} "
    puts "verify_mode    #{http.verify_mode} "

  end.start

  puts "Ruby net/http connection to #{host}: success ✅"
  puts
rescue => error
  puts "Ruby net/http connection to #{host}: failed  ❌"
  puts
  puts "Unfortunately, this Ruby can't connect to #{host}. 😡"

  case error.message
  # Check for certificate errors
  when /certificate verify failed/
    abort "Your Ruby can't connect to #{host} because you are missing the certificate " \
      "files OpenSSL needs to verify you are connecting to the genuine #{host} servers."
  # Check for TLS version errors
  when /read server hello A/, /tlsv1 alert protocol version/
    abort "Your Ruby can't connect to #{host} because your version of OpenSSL is too old. " \
      "You'll need to upgrade your OpenSSL install and/or recompile Ruby to use a newer OpenSSL."
  else
    puts "Even worse, we're not sure why. 😕"
    puts
    puts "Here's the full error information:"
    puts "#{error.class}: #{error.message}"
    puts "  " << error.backtrace.join("\n  ")
    puts
    puts "You might have more luck using Mislav's SSL doctor.rb script. You can get it here:"
    puts "https://github.com/mislav/ssl-tools/blob/8b3dec4/doctor.rb"
    puts "Read more about the script and how to use it in this blog post:"
    puts "https://mislav.net/2013/07/ruby-openssl/"
    abort
  end
end

puts "Try 2:"
begin

	http = Net::HTTP.new(uri.host, uri.port)
	http.use_ssl = true
	http.verify_mode = verify_mode

	if http.use_ssl?
        	use_ssl_aux='true'
	else
        	use_ssl_aux='false'
	end

	puts "uri host:port  #{uri.host}:#{uri.port} " 
	puts "use_ssl        #{use_ssl_aux} "
	puts "ssl_version    #{http.ssl_version} "
	puts "verify_mode    #{http.verify_mode} "

	response = http.request(Net::HTTP::Get.new(uri.request_uri))

	puts "Ruby net/http connection to #{host}: success ✅"
	puts

rescue => error

	puts "Here's the full error information:"
	puts "#{error.class}: #{error.message}"
	puts "  " << error.backtrace.join("\n  ")
	puts

end

puts " "
puts "END"
puts " "
