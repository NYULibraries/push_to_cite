require 'spec_helper'

describe PushFormats::Refworks do

  let(:bibtex) { PushFormats::Refworks.new }

  describe '#initialize' do
    subject { bibtex }
    it { is_expected.to be_an_instance_of PushFormats::Refworks }
    its(:name) { is_expected.to eql 'Service' }
    its(:id) { is_expected.to eql 'service' }
    its(:action) { is_expected.to eql 'http://www.refworks.com/express/ExpressImport.asp?vendor=Primo&filter=RefWorks%20Tagged%20Format&encoding=65001&url=' }
    its(:method) { is_expected.to eql 'POST' }
    its(:enctype) { is_expected.to eql 'application/x-www-form-urlencoded' }
    its(:element_name) { is_expected.to eql 'ImportData' }
    its(:push_to_external) { is_expected.to eql true }
    its(:redirect) { is_expected.to eql true }
    its(:filename) { is_expected.to eql 'export' }
    its(:to_format) { is_expected.to eql 'refworks_tagged' }
    its(:mimetype) { is_expected.to eql 'text/plain' }
  end

end
