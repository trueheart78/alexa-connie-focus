require 'sinatra'
require 'json'
require 'alexa_rubykit'

class ResponseHandler
  class << self
    def next
      load_responses
      response = responses.shuffle.pop
      save_responses
      response
    end

    def reset
      @responses = response_list
      save_responses
    end

    private

    attr_reader :responses

    def load_responses
      @responses = File.readlines(filename).map(&:rstrip)
      @responses = response_list if responses.empty?
    rescue Errno::ENOENT
      @responses = response_list
    end

    def save_responses
      File.unlink filename if File.exist? filename
      File.open filename, 'w' do |file|
        file.write responses.join("\n")
      end
    end

    def filename
      'remaining-statements.txt'
    end

    def response_list
      [
        'Keep your eyes on the prize Connie',
        'Make it happen girl',
        'You can do it!',
        'Stop distracting her by talking to me Lynda',
        'Shh. Be very very quiet. She\'s doing your dressings',
        'Can\'t stop won\'t stop',
        'YOLO',
        'Keep it together girl',
        'You got this',
        'Would you like me to call another nurse?',
        'Slower please',
        'Help',
        'One thing at a time Connie',
        'hmmm. ok. yeah. sure.',
        'I\'m not here',
        'Whachoo talkin about Lynda?',
        'What\'s the number for nine one one?',
        'If you need help I take cash or credit card',
        'How many times do I have to tell you Lynda that I can\'t reach her from here',
        'This is going great. No seriously. Really great. wink wink',
        'Tape it like you mean it',
        'You can\'t make this stuff up',
        'I don\'t think I can do that Lynda. You\'re on your own'
      ]
    end
  end
end

def reset?(request_body)
  req = AlexaRubykit::Request.new JSON.parse(request_body)
  req.json['request']['type'] == 'IntentRequest' && req.json['request']['intent']['name'] == 'AMAZON.StartOverIntent'
rescue JSON::ParserError
end

post '/pay_attention' do
  ResponseHandler.reset if reset? request.body.read
  response = AlexaRubykit::Response.new
  response.add_speech ResponseHandler.next
  return response.build_response
end

post '/reset' do
  ResponseHandler.reset
  [200, [], '']
end
