require 'spec_helper'

describe PushFormats::Endnote do

  let(:bibtex) { PushFormats::Endnote.new }

  describe '#initialize' do
    subject { bibtex }
    it { is_expected.to be_an_instance_of PushFormats::Endnote }
    its(:name) { is_expected.to eql 'EndNote' }
    its(:id) { is_expected.to eql 'endnote' }
    its(:action) { is_expected.to eql 'http://www.myendnoteweb.com/?func=directExport&partnerName=Primo&dataIdentifier=1&dataRequestUrl=' }
    its(:method) { is_expected.to eql 'POST' }
    its(:enctype) { is_expected.to eql 'application/x-www-form-urlencoded' }
    its(:element_name) { is_expected.to eql 'data' }
    its(:filename) { is_expected.to eql 'export' }
    its(:to_format) { is_expected.to eql 'ris' }
    its(:mimetype) { is_expected.to eql 'text/plain' }
  end

  describe '#redirect_to_external?' do
    subject { bibtex.redirect_to_external? }
    it { is_expected.to be true }
  end

  describe '#post_form_to_external?' do
    subject { bibtex.post_form_to_external? }
    it { is_expected.to be false }
  end

  describe '#redirect_to_data?' do
    subject { bibtex.redirect_to_data? }
    it { is_expected.to be false }
  end

  describe '#download?' do
    subject { bibtex.download? }
    it { is_expected.to be false }
  end

end
