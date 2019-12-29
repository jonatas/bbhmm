require 'spec_helper'
require 'core'

RSpec.describe Core do
  describe "expense" do
    let(:pizza_night) do
      Core.expense description: 'pizza night', amount: 100
    end

    let(:jonatas) { "jonatas" }
    let(:henrisch) { "henrisch" }
    let(:boi) { "boi" }

    let(:pizza_split) do
      Core.split(pizza_night, [henrisch, jonatas])
    end

    context 'split a pizza' do
      it 'sets suggested amount with a simple round' do
        expect(pizza_split.suggested_amount).to eq(50)
      end

      it 'sets initial shares with value to pay' do
        expect(pizza_split.shares.map(&:to_pay)).to eq([50,50])
      end

      it 'sets initial shares without any paid values' do
        expect(pizza_split.shares.map(&:paid)).to eq([0,0])
      end
    end

    describe 'paying the pizza' do
      let(:henrisch_share) { pizza_split.share_for(henrisch) }

      context 'when henrish pay his part partially' do
        before do
          pizza_split.add_payment(henrisch, 10)
        end

        it 'register amount paid to henrish share' do
          expect(henrisch_share.paid).to eq(10)
        end

        it 'calculate the missing value' do
          expect(pizza_split.missing_value).to eq(90)
        end
      end

      context 'when a user pay his part completely' do
        before do
          pizza_split.add_payment(henrisch, 50)
        end

        it 'register amount paid to henrish share' do
          expect(henrisch_share.paid).to eq(50)
        end
      end

      context 'when both members pay everything' do
        before do
          pizza_split.add_payment(henrisch, 50)
          pizza_split.add_payment(jonatas, 50)
        end

        it "allow us to check if it's fully paid" do
          expect(pizza_split).to be_completed
        end
      end
    end

    describe 'adding more people to split the pizza' do
      before do
        pizza_split.split_also_with(boi)
      end

      it do
        expect(pizza_split.shares.map(&:to_pay)).to eq([33.33,33.33,33.33])
      end
    end

    describe 'consider user pay a different amount' do
      before do
        pizza_split.split_also_with(boi)
        pizza_split.consider(boi, pay_value: 20)
      end

      it 'make the split inconsistent' do
        expect(pizza_split).to be_inconsistent
      end

      context 'when align the split' do
        before do
          pizza_split.consider(jonatas, pay_value: 40)
          pizza_split.consider(henrisch, pay_value: 40)
        end

        it 'make the split consistent' do
          expect(pizza_split).not_to be_inconsistent
        end
      end
    end
  end

  describe "house aggregated expenses" do
    let(:house_rental) do
      Core.expense description: 'house monthly fee', amount: 4500
    end
    let(:rent_split) do
      Core.split(house_rental, %w[henrisch, carioca, johan, jonatas, parah])
    end

  end
end
