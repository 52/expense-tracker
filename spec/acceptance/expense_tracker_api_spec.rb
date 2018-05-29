require "rack/test"
require_relative "../../app/api"

module ExpenseTracker
  RSpec.describe "Expense Tracker API", :db do
    include Rack::Test::Methods

    def app
      ExpenseTracker::API.new
    end

    def post_expense_as_json expense
      header "Content-Type", "application/json"
      post "/expenses", JSON.generate(expense)

      expect(last_response.status).to eq(200)

      response = expect_response include("expense_id" => a_kind_of(Integer))
      expense.merge "id" => response["expense_id"]
    end

    it "records submitted expenses (as JSON)" do
      # POST coffee, zoo, and groceries expenses
      coffee = post_expense_as_json(
        "payee"  => "Starbucks",
        "amount" => 5.75,
        "date"   => "2017-06-10"
      )

      zoo = post_expense_as_json(
        "payee"  => "Zoo",
        "amount" => 15.25,
        "date"   => "2017-06-10"
      )

      groceries = post_expense_as_json(
        "payee"  => "Whole food",
        "amount" => 95.20,
        "date"   => "2017-06-11"
      )

      # GET expenses by date
      get "expenses/2017-06-10"
      expect(last_response.status).to eq(200)

      expect_response contain_exactly(coffee, zoo)
    end

    def post_expense_as_xml expense
      xml = Ox::Document.new
      expense.each do |key, value|
        element = Ox::Element.new key
        element << value.to_s
        xml << element
      end

      header "Content-Type", "text/xml"
      post "/expenses", Ox.dump(xml)

      expect(last_response.status).to eq(200)
      response = expect_response include("expense_id" => a_kind_of(Integer))
      expense.merge "id" => response["expense_id"]
    end

    it "records submitted expenses (as XML)" do
      # POST coffee, zoo, and groceries expenses
      coffee = post_expense_as_xml(
        "payee"  => "Starbucks",
        "amount" => 5.75,
        "date"   => "2017-06-10"
      )

      zoo = post_expense_as_xml(
        "payee"  => "Zoo",
        "amount" => 15.25,
        "date"   => "2017-06-10"
      )

      groceries = post_expense_as_xml(
        "payee"  => "Whole food",
        "amount" => 95.20,
        "date"   => "2017-06-11"
      )

      # GET expenses by date
      get "expenses/2017-06-10"
      expect(last_response.status).to eq(200)

      expect_response contain_exactly(coffee, zoo)
    end
  end
end
