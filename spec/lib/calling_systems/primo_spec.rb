require 'spec_helper'

describe CallingSystems::Primo, vcr: true do

  let(:primo_id) { 'nyu_aleph004508721' }
  let(:institution) { 'NYU' }
  let(:primo) { CallingSystems::Primo.new(primo_id, institution) }

  describe '.new' do
    subject { primo }
    it { is_expected.to be_an_instance_of CallingSystems::Primo }
    its(:primo_id) { is_expected.to eql primo_id }
    its(:institution) { is_expected.to eql institution }
  end

  describe '#get_pnx_json' do
    subject { primo.get_pnx_json }
    context 'when link field is populated' do
      its(['pnxId']) { is_expected.to eql primo_id }
    end
  end

  describe '#pnx_json_api_endpoint' do
    subject { primo.pnx_json_api_endpoint }
    it { is_expected.to include "/primo_library/libweb/webservices/rest/v1/pnxs/L/#{primo_id}" }
  end

  describe '#error?' do
    subject { primo.error? }
    context 'when the aleph ID is valid' do
      it { is_expected.to eql false }
    end
    context 'when the aleph ID is invalid' do
      let(:primo_id) { 'nyu_aleph' }
      it { is_expected.to eql true }
    end
  end

  describe '#openurl' do
    subject { primo.openurl }
    it { is_expected.to include "rfr_id=info:sid/primo.exlibrisgroup.com:primo-#{primo_id}" }
  end

end
