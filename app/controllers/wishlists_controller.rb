class WishlistsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_wishlist!, only: %i(destroy edit update)

  def index
    authorize! :index, Wishlist
    @wishlists = Wishlist.created_by(current_user)
  end

  def new
    @wishlist = Wishlist.new(wishlist_params)
    authorize! :new, @wishlist
  end

  def create
    @wishlist = Wishlist.new(wishlist_params)
    authorize! :create, @wishlist
    if @wishlist.save
      redirect_to wishlists_path, notice: t(".success")
    else
      render :new
    end
  end

  def destroy
    authorize! :destroy, @wishlist
    @wishlist.destroy!
    redirect_to wishlists_path, notice: t(".success")
  rescue CanCan::AccessDenied, ActiveRecord::RecordNotDestroyed
    redirect_to wishlists_path, alert: t("generic_error")
  end

  def edit
    authorize! :edit, @wishlist
  rescue CanCan::AccessDenied
    redirect_to wishlists_path, alert: t("generic_error")
  end

  def update
    authorize! :update, @wishlist
    @wishlist.update_attributes!(wishlist_params)
    redirect_to wishlists_path, notice: t(".success")
  rescue CanCan::AccessDenied
    redirect_to wishlists_path, alert: t("generic_error")
  rescue ActiveRecord::RecordInvalid
    render :edit
  end

  private

  def wishlist_params
    params[:wishlist] ||= {}
    params[:wishlist][:user_id] = current_user.id
    params.require(:wishlist).permit(:user_id, :name, :description)
  end

  def set_wishlist!
    @wishlist = Wishlist.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to wishlists_path, alert: t("generic_error")
  end
end
