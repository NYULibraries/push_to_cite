require 'spec_helper'

describe CallingSystems::Primo, vcr: true do

  let(:local_id) { 'nyu_aleph004508721' }
  let(:institution) { 'NYU' }
  let(:primo) { CallingSystems::Primo.new(local_id, institution) }

  describe '.new' do
    subject { primo }
    it { is_expected.to be_an_instance_of CallingSystems::Primo }
    its(:local_id) { is_expected.to eql local_id }
    its(:institution) { is_expected.to eql institution }
  end

  describe '#get_pnx_json' do
    subject { primo.get_pnx_json }
    context 'when link field is populated' do
      its(['pnxId']) { is_expected.to eql local_id }
    end
  end

  describe '#pnx_json_api_endpoint' do
    subject { primo.pnx_json_api_endpoint }
    it { is_expected.to include "/primo_library/libweb/webservices/rest/v1/pnxs/L/#{local_id}" }
  end

  describe '#error?' do
    subject { primo.error? }
    context 'when the aleph ID is valid' do
      it { is_expected.to eql false }
    end
    context 'when the aleph ID is invalid' do
      let(:local_id) { 'nyu_aleph' }
      it { is_expected.to eql true }
    end
  end

  describe '#openurl' do
    subject { primo.openurl }
    it { is_expected.to include "rfr_id=info:sid/primo.exlibrisgroup.com:primo-#{local_id}" }
  end

end
