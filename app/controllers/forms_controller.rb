class FormsController < ApplicationController
  def show_modal
    authorize :form, :show_modal?
    @form = Form.for_company(current_company).find(params[:id])
    partial_path = "forms/completed_#{@form.form_type.downcase.gsub(/[^a-z0-9]+/, '_')}_form"

    render partial: partial_path, locals: { form: @form }, layout: false
  end
end
