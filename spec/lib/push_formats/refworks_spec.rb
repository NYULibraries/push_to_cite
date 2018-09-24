require 'spec_helper'

describe PushFormats::Refworks do

  let(:bibtex) { PushFormats::Refworks.new }

  describe '' do
    subject { bibtex }
    it { is_expected.to be_an_instance_of PushFormats::Refworks }
    its(:name) { is_expected.to eql 'Service' }
    its(:id) { is_expected.to eql 'service' }
    its(:action) { is_expected.to eql '' }
    its(:method) { is_expected.to eql 'POST' }
    its(:enctype) { is_expected.to eql 'application/x-www-form-urlencoded' }
    its(:element_name) { is_expected.to eql 'data' }
    its(:push_to_external) { is_expected.to eql false }
    its(:redirect) { is_expected.to eql false }
    its(:filename) { is_expected.to eql 'export' }
    its(:to_format) { is_expected.to eql 'refworks_tagged' }
    its(:mimetype) { is_expected.to eql 'text/plain' }
  end

end
