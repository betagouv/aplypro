# frozen_string_literal: true

describe ASP::Builder do
  def markup_for(&block)
    described_class.new do |xml|
      xml.root do
        block.call(xml)
      end
    end.to_xml
  end

  it "transform the tag names to uppercase" do
    markup = markup_for do |xml|
      xml.foo("bar")
    end

    expect(markup).to include "<FOO>bar</FOO>"
  end

  it "removes accentuated characters" do
    markup = markup_for do |xml|
      xml.name("Éléonore")
    end

    expect(markup).to include "<NAME>Eleonore</NAME>"
  end
end
