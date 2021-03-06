class DonationsController < ApplicationController
  require_permission :can_view_donations?
  require_permission :can_create_donations?, except: [:index, :show]
  before_action :authenticate_user!
  active_tab "donations"

  def index
    @donations = current_user.donations_with_access
  end

  def new
  end

  def create
    donation = current_user.create_donation(params)

    if params[:save] == "save_and_continue"
      redirect_to edit_donation_path(donation), flash: { success: "Donation created!" }
    else
      redirect_to donations_path, flash: { success: "Donation created!" }
    end
  end

  def show
    @donation = Donation.includes(:donor, :user, donation_details: { item: :category }).find(params[:id])
    redirect_to donations_path unless current_user.can_view_donation?(@donation)
  end

  def edit
    @donation = Donation.includes(:donor, :user, donation_details: { item: :category }).find(params[:id])
    redirect_to donations_path unless current_user.can_view_donation?(@donation)
  end

  def update
    donation = current_user.update_donation(params)

    if params[:save] == "save_and_continue"
      redirect_to edit_donation_path(donation), flash: { success: "Donation updated!" }
    else
      redirect_to donations_path, flash: { success: "Donation updated!" }
    end
  end

  def migrate
    @donations = DonationMigrator.all
  end

  def save_migration
    DonationMigrator.migrate(current_user, params)
    redirect_to migrate_donations_path, flash: { success: "Donations migrated!" }
  end
end
