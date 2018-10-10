require 'spec_helper'

describe PushFormats::Bibtex do

  let(:bibtex) { PushFormats::Bibtex.new }

  describe '#initialize' do
    subject { bibtex }
    it { is_expected.to be_an_instance_of PushFormats::Bibtex }
    its(:name) { is_expected.to eql 'Service' }
    its(:id) { is_expected.to eql 'service' }
    its(:action) { is_expected.to eql '' }
    its(:method) { is_expected.to eql 'POST' }
    its(:enctype) { is_expected.to eql 'application/x-www-form-urlencoded' }
    its(:element_name) { is_expected.to eql 'data' }
    its(:filename) { is_expected.to eql 'export.bib' }
    its(:to_format) { is_expected.to eql 'bibtex' }
    its(:mimetype) { is_expected.to eql 'application/x-bibtex' }
  end

  describe '#redirect_to_external?' do
    subject { bibtex.redirect_to_external? }
    it { is_expected.to be false }
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
    it { is_expected.to be true }
  end

end
