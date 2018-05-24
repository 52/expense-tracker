require "rack/test"
require_relative "../../../app/api"

module ExpenseTracker
  RecordResult = Struct.new :success?, :expense_id, :error_message

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

          response = JSON.parse last_response.body
          expect(response).to include("expense_id" => 417)
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

          response = JSON.parse last_response.body
          expect(response).to include("error_message" => "Expense incomplete")
        end
      end
    end
  end
end
