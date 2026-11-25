require "rails_helper"

RSpec.describe "StockItems", type: :request do
  let(:contractor) { create(:user, :contractor) }
  let(:admin) { create(:user, :admin) }
  let(:employee) { create(:user, :employee) }
  let!(:stock_item) { create(:stock_item, name: "Cables") }
  let!(:stock_sub_item) { create(:stock_sub_item, stock_item: stock_item, name: "HDMI Cable") }

  describe "when signed in as a contractor" do
    before { sign_in contractor }

    it "shows Stock Directory in sidebar and Add button on index without admin-only links" do
      get stock_items_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Stock Directory")
      expect(response.body).to include("Add New Stock Item")
      expect(response.body).not_to include("Staff Management")
      expect(response.body).not_to include("Equipment Directory")
    end

    it "shows Edit and Delete buttons on show" do
      get stock_item_path(stock_item)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(edit_stock_item_path(stock_item))
      expect(response.body).to include("Delete Item")
    end

    it "allows accessing new and creating a stock item with sub-items" do
      get new_stock_item_path
      expect(response).to have_http_status(:ok)

      expect {
        post stock_items_path, params: {
          stock_item: {
            name: "Adapters",
            stock_sub_items_attributes: {
              "0" => { name: "USB-C to HDMI" }
            }
          }
        }
      }.to change(StockItem, :count).by(1).and change(StockSubItem, :count).by(1)

      expect(response).to redirect_to(stock_items_path)
    end

    it "allows accessing edit and updating a stock item" do
      get edit_stock_item_path(stock_item)
      expect(response).to have_http_status(:ok)

      patch stock_item_path(stock_item), params: {
        stock_item: {
          name: "Updated Cables",
          stock_sub_items_attributes: {
            "0" => { id: stock_sub_item.id, name: "DisplayPort Cable" }
          }
        }
      }

      expect(response).to redirect_to(stock_items_path)
      expect(stock_item.reload.name).to eq("Updated Cables")
      expect(stock_sub_item.reload.name).to eq("DisplayPort Cable")
    end

    it "allows deleting a stock item" do
      expect {
        delete stock_item_path(stock_item)
      }.to change(StockItem, :count).by(-1)

      expect(response).to redirect_to(stock_items_path)
    end

    it "allows creating and deleting stock sub-items directly" do
      expect {
        post stock_item_stock_sub_items_path(stock_item), params: {
          stock_sub_item: { name: "VGA Cable" }
        }
      }.to change(StockSubItem, :count).by(1)
      expect(response).to redirect_to(edit_stock_item_path(stock_item))

      created_sub_item = StockSubItem.order(:id).last
      expect {
        delete stock_item_stock_sub_item_path(stock_item, created_sub_item)
      }.to change(StockSubItem, :count).by(-1)
      expect(response).to redirect_to(edit_stock_item_path(stock_item))
    end
  end

  describe "when signed in as an admin" do
    before { sign_in admin }

    it "still allows creating a stock item" do
      expect {
        post stock_items_path, params: {
          stock_item: {
            name: "Toners",
            stock_sub_items_attributes: {
              "0" => { name: "Black Toner" }
            }
          }
        }
      }.to change(StockItem, :count).by(1)

      expect(response).to redirect_to(stock_items_path)
    end
  end

  describe "when signed in as a regular employee" do
    before { sign_in employee }

    it "does not show Add button on index" do
      get stock_items_path

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include("Add New Stock Item")
    end

    it "denies access to new, create, edit, update, destroy, and sub-item actions" do
      get new_stock_item_path
      expect(response).to redirect_to(root_path)

      expect {
        post stock_items_path, params: {
          stock_item: { name: "Unauthorized", stock_sub_items_attributes: { "0" => { name: "Sub" } } }
        }
      }.not_to change(StockItem, :count)
      expect(response).to redirect_to(root_path)

      get edit_stock_item_path(stock_item)
      expect(response).to redirect_to(root_path)

      patch stock_item_path(stock_item), params: { stock_item: { name: "Hacked" } }
      expect(response).to redirect_to(root_path)
      expect(stock_item.reload.name).to eq("Cables")

      expect {
        delete stock_item_path(stock_item)
      }.not_to change(StockItem, :count)
      expect(response).to redirect_to(root_path)

      expect {
        post stock_item_stock_sub_items_path(stock_item), params: { stock_sub_item: { name: "Sub" } }
      }.not_to change(StockSubItem, :count)
      expect(response).to redirect_to(root_path)
    end
  end
end
