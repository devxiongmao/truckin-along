class ShipmentPolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

  attr_reader :user, :shipment

  def initialize(user, shipment)
    @user = user
    @shipment = shipment
  end

  def index?
    user.customer?
  end

  def show?
    true # Anyone can view a shipment
  end

  def new?
    user.customer?
  end

  def edit?
    user.customer? || shipment.company_id == user.company_id
  end

  def create?
    user.customer?
  end

  def update?
    user.customer? || shipment.company_id == user.company_id
  end

  def destroy?
    user.customer? && !shipment.claimed?
  end

  def copy?
    user.customer?
  end

  def close?
    user.admin? || user.driver?
  end

  def assign?
    user.admin? || user.driver?
  end

  def assign_shipments_to_truck?
    user.admin? || user.driver?
  end

  def initiate_delivery?
    user.admin? || user.driver?
  end
end
