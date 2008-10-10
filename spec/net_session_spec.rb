require File.dirname(__FILE__) + '/spec_helper'

describe "net_session" do
  it "seriously needs some more specs. Seriously."

  it "works" do
    net = Net::Session.new('gnexp.com')
    net.get('/')
  end
end