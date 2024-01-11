# frozen_string_literal: true

module ASP
  class Builder < Nokogiri::XML::Builder
    # NOTE: the linter wants us to implement respond_to_missing? here
    # which is not relevant: we're not adding methods we're just
    # tapping into Nokogiri's builder interface to override the XML
    # tag that results from its method_missing.
    #
    # Our logic **starts** when Nokogiri misses the method, because
    # that's when we know we're building XML and all we want is to
    # uppercase the tag. The responding bit that comes before has
    # nothing to do with it.

    # rubocop:disable Style/MissingRespondToMissing
    def method_missing(method, *args, &)
      super(method.to_s.upcase, *args, &)
    end
    # rubocop:enable Style/MissingRespondToMissing
  end
end
