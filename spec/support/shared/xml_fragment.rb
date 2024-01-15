# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples "an XML-fragment producer" do
  subject(:document) { Nokogiri::XML(markup.doc.to_xml) }

  let(:markup) { entity.to_xml(Nokogiri::XML::Builder.new) }

  it "can generate some XML" do
    expect(document.to_s).not_to be_empty
  end

  it "has the expected shape" do
    path, value = probe

    expect(document.at(path)).to have_attributes({ text: value })
  end
end
