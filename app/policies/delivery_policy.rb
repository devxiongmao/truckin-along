class DeliveryPolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

  attr_reader :user, :delivery

  def initialize(user, delivery)
    @user = user
    @delivery = delivery
  end

  def index?
    user.admin? || user.driver?
  end

  def show?
    (delivery.truck.company == user.company) && (user.admin? || user.driver?)
  end

  def close?
    (delivery.truck.company == user.company) && (user.admin? || user.driver?)
  end

  def load_truck?
    user.admin? || user.driver?
  end

  def start?
    user.admin? || user.driver?
  end
end
