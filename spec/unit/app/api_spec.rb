require "rack/test"
require_relative "../../../app/api"

module ExpenseTracker
  RSpec.describe API do
    include Rack::Test::Methods

    let(:ledger){instance_double "ExpenseTracker::Ledger"}

    def app
      ExpenseTracker::API.new ledger: ledger
    end

    describe "POST /expenses" do
      context "when the expense is successfully recorded" do
        let(:expense){{"some" => "data"}}

        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(true, 417, nil))
        end

        it "responds with a 200 (OK)" do
          post "/expenses", JSON.generate(expense)

          expect(last_response.status).to eq(200)
        end

        it "return the expense id" do
          post "/expenses", JSON.generate(expense)

          expect_response include("expense_id" => 417)
        end
      end

      context "when the expense fails validation" do
        let(:expense){{"some" => "data"}}

        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(false, 417, "Expense incomplete"))
        end

        it "responds with a 422 (Unprocessable entity)" do
          post "/expenses", JSON.generate(expense)

          expect(last_response.status).to eq(422)
        end

        it "returns an error message" do
          post "/expenses", JSON.generate(expense)

          expect_response include("error_message" => "Expense incomplete")
        end
      end
    end

    describe "GET /expenses/:date" do
      context "when expenses exist on the given date" do
        let(:date){"2017-06-10"}

        before do
          allow(ledger).to receive(:expenses_on)
            .with(date)
            .and_return(["expense_1", "expense_2"])
        end

        it "responses with a 200 (OK)" do
          get "expenses/#{date}"
          expect(last_response.status).to eq(200)
        end

        it "returns the expenses record as JSON" do
          get "expenses/#{date}"
          expect_response contain_exactly("expense_1", "expense_2")
        end
      end

      context "when there are no expense on the given date" do
        let(:date){"2017-06-10"}

        before do
          allow(ledger).to receive(:expenses_on)
            .with(date)
            .and_return([])
        end

        it "responses with a 200 (OK)" do
          get "expenses/#{date}"
          expect(last_response.status).to eq(200)
        end

        it "returns an empty array as JSON" do
          get "expenses/#{date}"
          expect_response eq([])
        end
      end
    end
  end
end
