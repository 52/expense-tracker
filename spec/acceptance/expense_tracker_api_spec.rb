require "rack/test"
require "json"
require_relative "../../app/api"

module ExpenseTracker
  RSpec.describe "Expense Tracker API" do
    include Rack::Test::Methods

    def app
      ExpenseTracker::API.new
    end

    def post_expense expense
      post "/expenses", JSON.generate(expense)
      expect(last_response.status).to eq(200)

      response = JSON.parse last_response.body
      expect(response).to include("expense_id" => a_kind_of(Integer))

      expense.merge "id" => response["expense_id"]
    end

    it "records submitted expenses" do
      pending "need to persist expenses"
      # POST coffee, zoo, and groceries expenses
      coffee = post_expense(
        "payee"  => "Starbucks",
        "amount" => 5.75,
        "date"   => "2017-06-10"
      )

      zoo = post_expense(
        "payee"  => "Zoo",
        "amount" => 15.25,
        "date"   => "2017-06-10"
      )

      groceries = post_expense(
        "payee"  => "Whole food",
        "amount" => 95.20,
        "date"   => "2017-06-11"
      )

      # GET expenses by date
      get "expenses/2017-06-10"
      expect(last_response.status).to eq(200)

      response = JSON.parse last_response.body
      expect(response).to contain_exactly(coffee, zoo)
    end
  end
end
