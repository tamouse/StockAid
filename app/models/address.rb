class Address < ApplicationRecord
  after_update :email_address_changes, if: :changed?

  def to_s
    address
  end

  private

  def email_address_changes
    return if DonorAddress.where(address: self).exists?

    admins_to_email = system_admins + org_admins

    admins_to_email.each do |admin|
      AddressChangeMailer.change(admin, organization, changes[:address][0], changes[:address][1]).deliver_now
    end
  end

  def system_admins
    User.where(role: "admin")
  end

  def org_admins
    User.joins(:organization_users).where(
      organization_users: { organization: organization, role: "admin" }
    )
  end
end
