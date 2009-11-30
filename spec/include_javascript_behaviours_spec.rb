require 'lib/include_javascript_behaviours'

class Context
  include IncludeJavascriptBehaviours
end

describe IncludeJavascriptBehaviours do
  before :all do
    unless defined?(Rails)
      Rails = mock('rails')
      Rails.should_receive(:root).any_number_of_times.and_return('')
    end
  end

  before :each do
    @template = mock('template')
    @response = mock('response')
    @response.should_receive(:template).any_number_of_times.and_return(@template)

    @context = Context.new
    @context.should_receive(:response).any_number_of_times.and_return(@response)
  end

  context 'when including javascripts,' do
    before :each do
      @context.should_receive(:javascript_include_tag).any_number_of_times.with(
        instance_of(String), instance_of(Hash)
      ).and_return do |js, options|
        "/javascripts/#{js}.js"
      end
    end

    context 'when :global specified' do
      it 'should include global.js' do
        File.should_receive(:exists?).with('public/javascripts/global.js').and_return(true)
        @context.include_javascript_behaviours(:global).should =~ /global.js/
      end
    end

    context 'when run from view' do
      before :each do
        @context.should_receive(:controller_name).and_return('messages')
      end

      it 'should include controller js' do
        @context.should_receive(:action_name).and_return(nil)
        File.should_receive(:exists?).with('public/javascripts/messages.js').and_return(true)
        File.should_receive(:exists?).with('public/javascripts/messages_.js').and_return(false)
        @context.include_javascript_behaviours.split("\n").should include '/javascripts/messages.js'
      end

      context 'inside an action' do
        before :each do
          @context.should_receive(:action_name).and_return('new')
          File.should_receive(:exists?).with('public/javascripts/messages.js').and_return(false)
        end

        it 'should include controller action js' do
          File.should_receive(:exists?).with('public/javascripts/messages_new.js').and_return(true)
          @context.include_javascript_behaviours.split("\n").should include '/javascripts/messages_new.js'
        end

        it 'should include partial js' do
          @partials = mock('partials')
          @partials.should_receive(:keys).and_return([['messages/form']])
          @template.should_receive(:instance_variable_get).with('@_memoized__pick_partial_template').and_return(@partials)
          File.should_receive(:exists?).with('public/javascripts/messages_new.js').and_return(false)
          File.should_receive(:exists?).with('public/javascripts/_messages_form.js').and_return(true)
          @context.include_javascript_behaviours.split("\n").should include '/javascripts/_messages_form.js'
        end
      end
    end
  end
end
