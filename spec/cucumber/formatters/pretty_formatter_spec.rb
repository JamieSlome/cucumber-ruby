require File.dirname(__FILE__) + '/../../spec_helper'

module Cucumber
  module Formatters
    describe PrettyFormatter do
      
      def mock_step(stubs={})
        stub('step', {
          :keyword => 'Given', 
          :format => 'formatted yes',
          :name => 'example',
          :error => nil,
          :row? => false}.merge(stubs))
      end
      
      def mock_scenario(stubs={})
        stub('scenario', {
          :name => 'test',
          :row? => false }.merge(stubs))
      end
    
      def mock_error(stubs={})
        stub('error', {
          :message => 'failed', 
          :backtrace => 'example backtrace'}.merge(stubs))
      end
      
      def mock_proc
        stub(Proc, :to_comment_line => '# steps/example_steps.rb:11')
      end
            
      it "should print step file and line when passed" do
        io = StringIO.new
        formatter = PrettyFormatter.new io, StepMother.new
        step = stub('step',
          :error => nil, :row? => false, :keyword => 'Given', :format => 'formatted yes'
        )
        formatter.step_passed(step, nil, nil)
        io.string.should == "    Given formatted yes\n"
      end
      
      describe "show source option true" do
      
        %w{passed failed skipped}.each do |result|
          it "should display step source for passed step" do
            io = StringIO.new

            step_mother = mock('step_mother')
            formatter = PrettyFormatter.new io, step_mother, :source => true
            formatter.send("step_#{result}".to_sym, mock_step(:regexp_args_proc => [nil, nil, mock_proc], :error => StandardError.new, :padding_length => 2), nil, nil)
          
            io.string.should include("Given formatted yes  # steps/example_steps.rb:11")
          end
        end
        
        it "should display file and line for scenario" do
          io = StringIO.new

          step_mother = mock('step_mother')
          formatter = PrettyFormatter.new io, step_mother, :source => true
          formatter.scenario_executing(mock_scenario(:name => "title", :file => 'features/example.feature', :line => 2 , :padding_length => 2))
          
          io.string.should include("Scenario: title  # features/example.feature:2")
        end
                
        it "should align step comments" do
          io = StringIO.new
          
          step_1 = mock_step(:regexp_args_proc => [nil, nil, mock_proc], :format => "1", :padding_length => 10)
          step_4 = mock_step(:regexp_args_proc => [nil, nil, mock_proc], :format => "4444", :padding_length => 7)
          step_9 = mock_step(:regexp_args_proc => [nil, nil, mock_proc], :format => "999999999", :padding_length => 2)

          step_mother = mock('step_mother')
          formatter = PrettyFormatter.new io, step_mother, :source => true
          
          formatter.step_passed(step_1, nil, nil)
          formatter.step_passed(step_4, nil, nil)
          formatter.step_passed(step_9, nil, nil)
          
          io.string.should include("Given 1          # steps/example_steps.rb:11")
          io.string.should include("Given 4444       # steps/example_steps.rb:11")
          io.string.should include("Given 999999999  # steps/example_steps.rb:11")
        end
                
        it "should align step comments with respect to their scenario's comment" do
          io = StringIO.new
      
          step = mock_step(:regexp_args_proc => [nil, nil, mock_proc], :error => StandardError.new, :padding_length => 6)

          step_mother = mock('step_mother')
          formatter = PrettyFormatter.new io, step_mother, :source => true
                  
          formatter.scenario_executing(mock_scenario(:name => "very long title", :file => 'features/example.feature', :line => 5, :steps => [step], :padding_length => 2))
          formatter.step_passed(step, nil, nil)
          
          io.string.should include("Scenario: very long title  # features/example.feature:5")
          io.string.should include("  Given formatted yes      # steps/example_steps.rb:11")
        end
          
        it "should NOT display step source for pending step" do
          io = StringIO.new
          step_mother = mock('step_mother')

          formatter = PrettyFormatter.new io, step_mother, :source => true
          formatter.step_pending(mock_step(:regexp_args_proc => [nil, nil, mock_proc]), nil, nil)
          
          io.string.should_not include("steps/example_steps.rb:11")
        end
        
      end
    end
  end
end
