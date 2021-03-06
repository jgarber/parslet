require 'spec_helper'

require 'parslet'

describe Parslet::ErrorTree, 'instance' do
  let(:parslet) { flexmock(Parslet.any, :cause => 'foo') }
  let(:error_tree) { Parslet::ErrorTree.new(parslet) }

  subject { error_tree }
  its(:nodes) { should == 1 }
  its(:to_s) { should == error_tree.ascii_tree }
  its(:cause) { should == 'foo' }
  its(:children) { should be_empty }
  
  it "should have a simple ascii tree" do
    error_tree.ascii_tree.should include(subject.cause)
  end
  
  context "when a parslet doesn't have a cause" do
    let(:parslet) { flexmock(Parslet.any, :cause => nil) }

    its(:ascii_tree) { should == "`- Unknown error in .\n" }
  end
  context "when children don't have a cause" do
    let(:nocause) { flexmock(Parslet.any, :cause => nil) }
    before(:each) { 
      error_tree.children << 
        Parslet::ErrorTree.new(nocause)
    }
    its(:ascii_tree) { should == "`- foo\n   `- Unknown error in .\n" }
  end
  context "with two children" do
    before(:each) do
      error_tree.children << 
        Parslet::ErrorTree.new(parslet) << 
        Parslet::ErrorTree.new(parslet)
    end

    its(:nodes) { should == 3 }
    its(:to_s) { should == error_tree.ascii_tree }
    its(:ascii_tree) { should == "`- foo\n   |- foo\n   `- foo\n" }
  end
end