require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe OrdersController, type: :controller do
  let (:user) { create(:user) }

  # This should return the minimal set of attributes required to create a valid
  # Order. As you add validations to Order, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {kind: 'buy', quantity: 1, price: 1, stock_id: create(:stock).id, user: user}
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # OrdersController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  before do
    sign_in user
  end

  describe "GET #index" do
    it "assigns all orders as @orders" do
      order = Order.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:orders)).to eq([order])
    end
  end

  describe "GET #new" do
    it "assigns a new order as @order" do
      get :new, {}, valid_session
      expect(assigns(:order)).to be_a_new(Order)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Order" do
        expect {
          post :create, {:order => valid_attributes}, valid_session
        }.to change(Order, :count).by(1)
      end

      it "assigns a newly created order as @order" do
        post :create, {:order => valid_attributes}, valid_session
        expect(assigns(:order)).to be_a(Order)
        expect(assigns(:order)).to be_persisted
      end

      it "redirects back to orders" do
        post :create, {:order => valid_attributes}, valid_session
        expect(response).to redirect_to(orders_path)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved order as @order" do
        post :create, {:order => invalid_attributes}, valid_session
        expect(assigns(:order)).to be_a_new(Order)
      end

      it "re-renders the 'new' template" do
        post :create, {:order => invalid_attributes}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested order" do
      order = Order.create! valid_attributes
      expect {
        delete :destroy, {:id => order.to_param}, valid_session
      }.to change(Order, :count).by(-1)
    end

    it "redirects to the orders list" do
      order = Order.create! valid_attributes
      delete :destroy, {:id => order.to_param}, valid_session
      expect(response).to redirect_to(orders_url)
    end
  end

end
