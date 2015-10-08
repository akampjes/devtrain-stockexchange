require 'rails_helper'

RSpec.describe Stock, type: :model do
  it 'is vaild with a name and symbol' do
    subject.name = 'testname'
    subject.symbol = 'test'
  end
  context 'invalid conditions' do
    it 'is invalid without a name and symbol' do
      expect(subject).to be_invalid
    end
  end
end
