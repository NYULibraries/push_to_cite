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

  describe '#links' do
    subject { primo.links }
    its(["lln10"]) { is_expected.to include "rfr_id=info:sid/primo.exlibrisgroup.com:primo-#{primo_id}" }
    its(["lln11"]) { is_expected.to include "institution=NYUAD" }
    its(["lln12"]) { is_expected.to include "institution=NYUSH" }
    its(["lln13"]) { is_expected.to include "institution=CU" }
    its(["linktoholdings"]) { is_expected.to include "doc_number=#{}" }
  end

  describe '#whitelisted_attributes' do
    subject { primo.whitelisted_attributes }
    it { is_expected.to be_an_instance_of Hash }
    its([:addau]) { is_expected.to include "Gale Group" }
    its([:institution]) { is_expected.to eql 'NYU' }
    its([:oclcnum]) { is_expected.to eql '632164824' }
    its([:subject]) { is_expected.to include 'Caulfield, Holden (Fictitious character)' }
  end

end
