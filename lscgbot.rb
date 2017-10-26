require 'slack-ruby-bot'
require "net/https"
require "uri"

class LSCGBot < SlackRubyBot::Bot
  match(/(\[[0-9]{9}|#\d+)/i) do |client, data, issues|
    puts data.text
    results = []
    tomatch = data.text
    
    # Remove links from text, since they're already links, by grabbing everything between < and >
    # tomatch = tomatch.sub /(<.+>)/i, ''
    # Removed because links could still be useful now

    # Also remove emoji, because skin-tone-2 and similar were showing up
    tomatch = tomatch.sub /:\b\S*\b:/, ''
    
    # Now grab everything that looks like a JIRA ticket, dump it into an array, grab uniques.
    
    tomatch.scan(/(\[[0-9]{9}|#\d+)/i) do |i,j|
    	results << i.upcase
    end
    results.uniq.each do |ticket|
=begin 
Disabling all of this jira-specific stuff for now
        url = ENV["JIRA_PREFIX"]+"rest/api/latest/issue/"+ticket
        direct = ENV["JIRA_PREFIX"]+"browse/"+ticket
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        request = Net::HTTP::Get.new(uri.request_uri)
        request.basic_auth(ENV["JIRA_USER"],ENV["JIRA_PASS"])
        response = http.request(request)
        body = JSON.parse(response.body)
        if response.code != "404"
            if response.code == "200"
                # Check if this is already a link in the message. If so, don't bother sending a link
                if tomatch.include?(direct)
                    message = "#{ticket}: #{body['fields']['summary']}\n#{body['fields']['status']['name']} (#{body['fields']['issuetype']['name']})"
                else
                    message = "#{ticket}: #{body['fields']['summary']}\n#{direct}\n#{body['fields']['status']['name']} (#{body['fields']['issuetype']['name']})"
                end
            else
                message = direct
            end
            client.say(channel: data.channel, text: message)
        end
=end
      if ticket =~ /#/
	ticket = ticket[1..-1]
        message = 'https://help.chem.ucsb.edu/rt/Ticket/Display.html?id='+ticket
      else 
	ticket = ticket[1..-1]
        message = 'https://www.lscg.ucsb.edu/helpdesk/tech/editTicket.php?taskid='+ticket
      end
      client.say(channel: data.channel, text: message)
    end
  end
end

LSCGBot.run
