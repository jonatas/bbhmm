# frozen_string_literal: true

require 'spec_helper'
require 'core'

module Core
  RSpec.describe Simplify do
    let(:jonatas) { 'jonatas' }
    let(:henrisch) { 'henrisch' }
    let(:boi) { 'boi' }

    describe 'simplify' do
      context 'when 2 debts from the same user to the same user' do
        it 'simplify the debts' do
          debts = [
            Core::Debt.new(henrisch, jonatas, 30),
            Core::Debt.new(henrisch, jonatas, 50)
          ]

          simplified_debts = [Core::Debt.new(henrisch, jonatas, 80)]
          expect(Core.simplify(debts)).to match_array(simplified_debts)
        end
      end
      context 'when 2 users owe eachother' do
        it 'simplify the debts' do
          debts = [
            Core::Debt.new(henrisch, jonatas, 30),
            Core::Debt.new(jonatas, henrisch, 50)
          ]

          simplified_debts = [Core::Debt.new(jonatas, henrisch, 20)]
          expect(Core.simplify(debts)).to match_array(simplified_debts)
        end
      end

      context 'with a more complex scenario' do
        it 'simplify the debts' do
          debts = [
            Core::Debt.new(boi, henrisch, 150),
            Core::Debt.new(jonatas, henrisch, 50),
            Core::Debt.new(jonatas, boi, 30),
            Core::Debt.new(boi, jonatas, 30),
            Core::Debt.new(henrisch, boi, 30)
          ]

          simplified_debts = [
            Core::Debt.new(boi, henrisch, 120),
            Core::Debt.new(jonatas, henrisch, 50)
          ]
          expect(Core.simplify(debts)).to match_array(simplified_debts)
        end
      end
    end
  end
end
