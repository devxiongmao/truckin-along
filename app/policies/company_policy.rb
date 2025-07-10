class CompanyPolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

  attr_reader :user, :company

  def initialize(user, company)
    @user = user
    @company = company
  end

  def new?
    user.admin? && user.company.nil?
  end

  def create?
    user.admin? && user.company.nil?
  end

  def edit?
    user.admin?
  end

  def update?
    user.admin?
  end

  def show?
    true # Anyone can view company details
  end
end
