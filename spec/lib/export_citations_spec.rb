require 'spec_helper'

describe ExportCitations do
  let(:data) { 'http://test.com?rft.rfr_id=test' }
  let(:cite_to) { 'ris' }
  let(:export_citations) { ExportCitations.new(data, cite_to) }

  describe '.export_citations_url' do
    subject { ExportCitations.export_citations_url }
    it { is_expected.to include 'http' }
  end

  describe '.new' do
    subject { export_citations }
    it { is_expected.to be_an_instance_of(ExportCitations) }
    its(:data) { is_expected.to eql data }
    its(:cite_to) { is_expected.to eql cite_to }
  end

  describe '#redirect_link' do
    subject { export_citations.redirect_link }
    context 'when data is a valid url' do
      it { is_expected.to include '?to_format=ris&rft.rfr_id=test' }
      context 'and url has extra empty fields' do
        let(:data) { 'http://test.com?au=&te=&be=&rft.au=Me' }
        it { is_expected.to include '?to_format=ris&rft.au=Me' }
        it { is_expected.not_to include 'be=' }
      end
    end
    context 'when data is an invalid url' do
      let(:data) { 'http://test.com/&be=baddata' }
      it 'should raise an invalid uri error' do
        expect { subject }.to raise_error ExportCitations::InvalidUriError
      end
    end
  end
end
